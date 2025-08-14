// routes/auth.js (로그인 기능 추가 최종본)
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db');
const crypto = require('crypto'); // 토큰 및 난수 생성을 위한 내장 모듈
const sendEmail = require('../utils/mailer'); // 이전에 만든 이메일 발송 헬퍼
const authMiddleware = require('../middleware/authMiddleware'); 

// 인증 코드를 임시 저장할 객체 (서버 메모리 사용)
const verificationCodes = {};

const router = express.Router();

const saltRounds = 10;

// POST /api/auth/register (회원가입) - 최종본
router.post('/register', async (req, res) => {
    try {
        // 1. 요청 데이터 가져오기 (referral_code 추가)
        const {
            email, password, verificationCode, companyName, representative, address, businessLocation, managerName,
            industryCodes = [],
            interests = [],
            referral_code
        } = req.body;
        let managerPhone = req.body.managerPhone ? req.body.managerPhone.replace(/\D/g, '') : null;

        // 2. 필수 값 및 인증번호 유효성 검사 (기존과 동일)
        if (!email || !password || !verificationCode) {
            return res.status(400).json({ success: false, message: '이메일, 비밀번호, 인증코드는 필수입니다.' });
        }
        const stored = verificationCodes[email];
        if (!stored || Date.now() > stored.expires || stored.code !== verificationCode) {
             // 에러 메시지를 통합하거나, 기존처럼 상세하게 유지할 수 있습니다.
            return res.status(400).json({ success: false, message: '인증번호가 유효하지 않습니다.' });
        }

        // 3. 비밀번호 규칙 검사 (기존과 동일)
        const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
        if (!passwordRegex.test(password)) {
            return res.status(400).json({
                success: false,
                message: '비밀번호는 8자 이상이며, 대문자, 소문자, 숫자, 특수문자를 모두 포함해야 합니다.'
            });
        }

        // 4. 이메일 중복 가입 방지 (기존과 동일)
        const existingUser = await db.query('SELECT * FROM users WHERE email = $1', [email]);
        if (existingUser.rows.length > 0) {
            return res.status(409).json({ success: false, message: '이미 사용 중인 이메일입니다.' });
        }

        // --- 👇 [추가] 추천 코드 유효성 검증 로직 👇 ---
        let recommendingOrgId = null;
        if (referral_code) {
            const codeRes = await db.query(
                'SELECT * FROM referral_codes WHERE code = $1 AND (expires_at IS NULL OR expires_at > NOW())',
                [referral_code]
            );
            if (codeRes.rows.length === 0) {
                return res.status(400).json({ success: false, message: '유효하지 않거나 만료된 추천 코드입니다.' });
            }
            recommendingOrgId = codeRes.rows[0].linked_admin_id; // 추천 단체(관리자) ID 저장
        }
        // --- 👆 여기까지 추가 👆 ---

        // 5. 모든 검증 통과 후, 사용자 정보 DB에 저장
        const hashedPassword = await bcrypt.hash(password, 10); // saltRounds를 10으로 직접 명시
        
        // [수정] INSERT 쿼리에 추천 코드 관련 컬럼 추가
        const newUserQuery = `
            INSERT INTO users (
                email, password, company_name, industry_codes, representative, address, 
                business_location, manager_name, manager_phone, interests, is_verified,
                used_referral_code, recommending_organization_id
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, TRUE, $11, $12)
            RETURNING id, email, company_name;
        `;
        const values = [
            email, hashedPassword, companyName, industryCodes, representative, address, 
            businessLocation, managerName, managerPhone, interests,
            referral_code || null, recommendingOrgId
        ];
        
        await db.query(newUserQuery, values);

        // 6. 사용한 인증번호는 메모리에서 삭제
        delete verificationCodes[email];

        // 7. 최종 성공 응답
        res.status(201).json({ success: true, message: '회원가입이 성공적으로 완료되었습니다.' });

    } catch (error) {
        console.error('회원가입 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

// POST /api/auth/signup - 회원가입
router.post('/signup', async (req, res) => {
    // body에서 agreeMarketing 값을 추가로 받습니다.
    const { email, password, companyName, representative, agreeTerms, agreePrivacy, agreeMarketing } = req.body;
    
    if (!agreeTerms || !agreePrivacy) {
        return res.status(400).json({ success: false, message: '필수 약관에 동의해야 합니다.' });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const query = `
            INSERT INTO users (email, password, company_name, representative, agreed_to_terms_at, agreed_to_privacy_at, agreed_to_marketing)
            VALUES ($1, $2, $3, $4, NOW(), NOW(), $5)
            RETURNING id;
        `;
        const values = [email, hashedPassword, companyName, representative, !!agreeMarketing];
        
        await db.query(query, values);
        res.status(201).json({ success: true, message: '회원가입이 완료되었습니다.' });
    } catch (error) {
        if (error.code === '23505') { // unique_violation (이메일 중복)
            return res.status(409).json({ success: false, message: '이미 사용 중인 이메일입니다.' });
        }
        console.error("회원가입 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});


// --- ▼▼▼ 로그인 API 구현 (새로운 부분) ▼▼▼ ---
// POST /api/auth/login (로그인)
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // 1. 이메일과 비밀번호가 모두 입력되었는지 확인
    if (!email || !password) {
      return res.status(400).json({ success: false, message: '이메일과 비밀번호를 모두 입력해주세요.' });
    }

    // 2. 데이터베이스에서 이메일로 사용자 정보 조회
    const userResult = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userResult.rows.length === 0) {
      // 보안을 위해 "이메일이 존재하지 않습니다" 대신 통합된 메시지 사용
      return res.status(401).json({ success: false, message: '이메일 또는 비밀번호가 올바르지 않습니다.' });
    }

    const user = userResult.rows[0];

    // --- ▼▼▼ 이메일 인증 여부 확인 코드 추가 ▼▼▼ ---
    if (!user.is_verified) {
        return res.status(401).json({ success: false, message: '이메일 인증이 필요합니다. 메일함의 인증 링크를 클릭해주세요.' });
    }
    
    // 3. 입력된 비밀번호와 DB에 저장된 암호화된 비밀번호를 비교
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      // 비밀번호가 일치하지 않는 경우
      return res.status(401).json({ success: false, message: '이메일 또는 비밀번호가 올바르지 않습니다.' });
    }
    
    // 4. 로그인 성공 시, JWT(JSON Web Token) 생성
    // 토큰에 담을 정보 (민감한 정보는 제외)
    const payload = {
      userId: user.id,
      email: user.email,
      companyName: user.company_name,
      role: user.role // ★★★ 사용자의 역할(role) 정보를 토큰에 추가 ★★★
    };
    
    // .env 파일의 비밀 키를 사용하여 토큰 서명
    const token = jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '1h' } // 토큰 만료 시간 (예: 1시간)
    );

    // 5. 로그인 성공 응답 (토큰 포함)
    res.status(200).json({
        success: true,
        message: '로그인 성공!',
        token: token,
        user: {
            company_name: user.company_name
        }
    });

  } catch (error) {
    console.error('로그인 에러:', error);
    res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
  }
});

// --- ▼▼▼ 이메일 중복 확인 API 추가 ▼▼▼ ---
// POST /api/auth/check-email
router.post('/check-email', async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ message: '이메일을 입력해주세요.' });
        }

        const existingUser = await db.query('SELECT id FROM users WHERE email = $1', [email]);
        
        if (existingUser.rows.length > 0) {
            // 이메일이 이미 존재함
            res.json({ isAvailable: false });
        } else {
            // 이메일 사용 가능
            res.json({ isAvailable: true });
        }
    } catch (error) {
        console.error('이메일 중복 확인 API 에러:', error);
        res.status(500).json({ message: '서버 에러가 발생했습니다.' });
    }
});

/**
 * 파일명: routes/auth.js
 * 수정 위치: POST /request-password-reset
 * 수정 일시: 2025-07-03 16:11
 */
router.post('/request-password-reset', async (req, res) => {
    try {
        const { email } = req.body;
        const userResult = await db.query('SELECT * FROM users WHERE email = $1', [email]);

        if (userResult.rows.length > 0) {
            const token = crypto.randomBytes(32).toString('hex');
            const hashedToken = crypto.createHash('sha256').update(token).digest('hex');
            const expires = new Date(Date.now() + 15 * 60 * 1000);

            // ★★★ 디버깅 로그 추가 ★★★
            console.log('--- [1. TOKEN CREATED] ---');
            console.log('DB에 저장될 Hashed Token:', hashedToken);

            await db.query('UPDATE users SET reset_token = $1, reset_token_expires = $2 WHERE email = $3', [hashedToken, expires, email]);

            const resetLink = `${process.env.FRONTEND_URL}/main_login_reset-password.html?token=${token}`;
            const emailSubject = '[LocalLink] 비밀번호 재설정 요청';
            const emailHtml = `<p>비밀번호를 재설정하려면 아래 링크를 클릭해주세요. 이 링크는 15분간 유효합니다.</p><a href="${resetLink}">${resetLink}</a>`;
            
            await sendEmail(email, emailSubject, emailHtml);
        }
        
        res.json({ success: true, message: '비밀번호 재설정 이메일을 발송했습니다. 메일함을 확인해주세요.' });

    } catch (error) {
        console.error('비밀번호 재설정 요청 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});


/**
 * 파일명: routes/auth.js
 * 수정 위치: POST /api/auth/reset-password
 * 수정 일시: 2025-07-03 15:11
 */
router.post('/reset-password', async (req, res) => {
    const { token, password, passwordConfirm } = req.body;

    if (!token || !password || !passwordConfirm) {
        return res.status(400).json({ success: false, message: '모든 필드를 입력해주세요.' });
    }
    if (password !== passwordConfirm) {
        return res.status(400).json({ success: false, message: '비밀번호가 일치하지 않습니다.' });
    }

    try {
        // ★★★ 1. 사용자가 보내온 원본 토큰을 똑같이 암호화합니다. ★★★
        const hashedToken = crypto.createHash('sha256').update(token).digest('hex');

        // ★★★ 2. 암호화된 토큰으로 DB의 users 테이블을 검색합니다. ★★★
        const userQuery = 'SELECT * FROM users WHERE reset_token = $1 AND reset_token_expires > NOW()';
        const userResult = await db.query(userQuery, [hashedToken]);

        if (userResult.rows.length === 0) {
            return res.status(400).json({ success: false, message: '유효하지 않거나 만료된 토큰입니다.' });
        }
        const user = userResult.rows[0];

        // 3. 새 비밀번호를 해싱하여 users 테이블에 업데이트합니다.
        const newHashedPassword = await bcrypt.hash(password, 10);
        await db.query('UPDATE users SET password = $1 WHERE id = $2', [newHashedPassword, user.id]);

        // ★★★ 4. 사용된 토큰 정보를 users 테이블에서 초기화합니다. ★★★
        await db.query('UPDATE users SET reset_token = NULL, reset_token_expires = NULL WHERE id = $1', [user.id]);

        res.status(200).json({ success: true, message: '비밀번호가 성공적으로 변경되었습니다. 다시 로그인해주세요.' });

    } catch (error) {
        console.error("비밀번호 재설정 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

// --- ▼▼▼ 아이디 찾기 API 추가 ▼▼▼ ---
// POST /api/auth/find-id
router.post('/find-id', async (req, res) => {
    try {
        let { managerName, managerPhone } = req.body;

        if (!managerName || !managerPhone) {
            return res.status(400).json({ success: false, message: '담당자명과 연락처를 모두 입력해주세요.' });
        }
        managerPhone = managerPhone.replace(/\D/g, '');
        
        const userResult = await db.query(
            'SELECT email FROM users WHERE manager_name = $1 AND manager_phone = $2',
            [managerName, managerPhone]
        );

        if (userResult.rows.length === 0) {
            return res.status(404).json({ success: false, message: '입력하신 정보와 일치하는 사용자를 찾을 수 없습니다.' });
        }

        // 사용자를 찾았으면 이메일 정보를 응답으로 보내줍니다.
        const userEmail = userResult.rows[0].email;
        res.status(200).json({ success: true, email: userEmail });

    } catch (error) {
        console.error('아이디 찾기 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

// --- ▼▼▼ 이메일 인증 실행 API 추가 ▼▼▼ ---
// GET /api/auth/verify-email
router.get('/verify-email', async (req, res) => {
    try {
        const { token } = req.query; // URL ?token=... 에서 토큰을 가져옵니다.

        if (!token) {
            return res.status(400).json({ success: false, message: '인증 토큰이 제공되지 않았습니다.' });
        }

        const hashedToken = crypto.createHash('sha256').update(token).digest('hex');

        const userResult = await db.query(
            'SELECT * FROM users WHERE verification_token = $1 AND verification_token_expires > NOW()',
            [hashedToken]
        );

        if (userResult.rows.length === 0) {
            return res.status(400).json({ success: false, message: '유효하지 않거나 만료된 인증 링크입니다.' });
        }

        const user = userResult.rows[0];

        // 인증 상태 업데이트 및 토큰 정보 초기화
        await db.query(
            'UPDATE users SET is_verified = TRUE, verification_token = NULL, verification_token_expires = NULL WHERE id = $1',
            [user.id]
        );

        res.status(200).json({ success: true, message: '이메일 인증이 성공적으로 완료되었습니다.' });

    } catch (error) {
        console.error('이메일 인증 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

// --- ▼▼▼ 이메일 인증코드 발송 API 추가 ▼▼▼ ---
router.post('/send-verification-email', async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ success: false, message: '이메일 주소를 입력해주세요.' });
        }

        // 이메일 중복 체크
        const existingUser = await db.query('SELECT id FROM users WHERE email = $1', [email]);
        if (existingUser.rows.length > 0) {
            return res.status(409).json({ success: false, message: '이미 가입된 이메일입니다.' });
        }

        const code = crypto.randomInt(100000, 999999).toString(); // 6자리 난수 생성
        const expires = Date.now() + 5 * 60 * 1000; // 5분 후 만료

        // 생성된 코드와 만료 시간을 서버 메모리에 저장
        verificationCodes[email] = { code, expires };

        const emailSubject = '[LocalLink] 회원가입 이메일 인증번호';
        const emailHtml = `<p>LocalLink 회원가입을 위한 인증번호입니다.</p><h2>${code}</h2><p>이 인증번호는 5분간 유효합니다.</p>`;

        const emailSent = await sendEmail(email, emailSubject, emailHtml);

        if (emailSent) {
            res.json({ success: true, message: '인증번호를 발송했습니다. 이메일을 확인해주세요.' });
        } else {
            throw new Error('Email sending failed');
        }

    } catch (error) {
        console.error('이메일 인증코드 발송 에러:', error);
        res.status(500).json({ success: false, message: '인증번호 발송에 실패했습니다.' });
    }
});

// --- ▼▼▼ 토큰 갱신(연장) API 추가 ▼▼▼ ---
router.post('/refresh', authMiddleware, (req, res) => {
    const { userId, email, companyName, role } = req.user;
    
    try {
        const newToken = jwt.sign(
            { userId, email, companyName, role }, // 기존 정보를 그대로 사용
            process.env.JWT_SECRET,
            { expiresIn: '1h' } // 유효기간을 다시 1시간으로 설정
        );

        res.status(200).json({
            success: true,
            message: '토큰이 성공적으로 갱신되었습니다.',
            token: newToken
        });

    } catch (error) {
        console.error('토큰 갱신 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

// POST /api/auth/forgot-password - 비밀번호 재설정 요청 (이메일 발송)
router.post('/forgot-password', async (req, res) => {
    const { email } = req.body;
    if (!email) {
        return res.status(400).json({ success: false, message: '이메일을 입력해주세요.' });
    }

    try {
        const userResult = await db.query('SELECT * FROM users WHERE email = $1', [email]);
        if (userResult.rows.length === 0) {
            return res.status(200).json({ 
                success: true, 
                message: '입력하신 이메일로 비밀번호 재설정 안내 메일이 발송되었습니다.' 
            });
        }
        
        const user = userResult.rows[0];
        const token = crypto.randomBytes(32).toString('hex');
        const expiresAt = new Date(Date.now() + 3600000); // 1시간 후 만료

        await db.query(
            'INSERT INTO password_resets (user_id, token, expires_at) VALUES ($1, $2, $3)',
            [user.id, token, expiresAt]
        );

        // ★★★ 링크 주소를 ? 쿼리 파라미터 방식으로 되돌리고, /public 경로는 제거합니다. ★★★
        const frontendUrl = process.env.FRONTEND_URL || 'http://127.0.0.1:5500';
        const resetLink = `${frontendUrl}/main_login_reset-password.html?token=${token}`;
        
        console.log(`비밀번호 재설정 링크 (콘솔 출력): ${resetLink}`);

        res.status(200).json({ success: true, message: '비밀번호 재설정 이메일이 발송되었습니다. 메일함을 확인해주세요.' });

    } catch (error) {
        console.error("비밀번호 찾기 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});


// POST /api/auth/reset-password - 비밀번호 최종 재설정
router.post('/reset-password', async (req, res) => {
    const { token, password, passwordConfirm } = req.body;

    if (!token || !password || !passwordConfirm) {
        return res.status(400).json({ success: false, message: '모든 필드를 입력해주세요.' });
    }
    if (password !== passwordConfirm) {
        return res.status(400).json({ success: false, message: '비밀번호가 일치하지 않습니다.' });
    }

    const client = await db.pool.connect();
    try {
        await client.query('BEGIN');

        // 1. 토큰 유효성 검증
        const resetQuery = 'SELECT * FROM password_resets WHERE token = $1 AND expires_at > NOW()';
        const resetResult = await client.query(resetQuery, [token]);

        if (resetResult.rows.length === 0) {
            return res.status(400).json({ success: false, message: '유효하지 않거나 만료된 토큰입니다.' });
        }
        const userId = resetResult.rows[0].user_id;

        // 2. 새 비밀번호 해싱 및 users 테이블 업데이트
        const hashedPassword = await bcrypt.hash(password, 10);
        await client.query('UPDATE users SET password = $1 WHERE id = $2', [hashedPassword, userId]);

        // 3. 사용된 토큰 삭제
        await client.query('DELETE FROM password_resets WHERE token = $1', [token]);

        await client.query('COMMIT');
        res.status(200).json({ success: true, message: '비밀번호가 성공적으로 변경되었습니다. 다시 로그인해주세요.' });

    } catch (error) {
        await client.query('ROLLBACK');
        console.error("비밀번호 재설정 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    } finally {
        client.release();
    }
});

module.exports = router;