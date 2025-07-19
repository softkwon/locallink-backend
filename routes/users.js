// routes/users.js (최종본)
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');    // 토큰 해석을 위해 추가   
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');
const multer = require('multer');
const sharp = require('sharp'); 
const path = require('path');
const fs = require('fs');
const s3 = require('../config/s3-client');

// multer 인스턴스 생성 (메모리 저장 방식 사용)
const storage = multer.memoryStorage();
const upload = multer({ storage: storage, limits: { fileSize: 5 * 1024 * 1024 } });
const router = express.Router();

// GET /api/users/me - 로그인된 내 정보 가져오기 (레벨 계산 포함)
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const { userId } = req.user;
    
    const query = `
        SELECT 
            u.id, u.email, u.company_name, u.representative, u.role, u.profile_image_url,
            u.address, u.business_location, u.manager_name, u.manager_phone, u.industry_codes, u.interests, u.agreed_to_marketing,
            EXISTS (SELECT 1 FROM diagnoses WHERE user_id = u.id AND status = 'completed') as has_completed_diagnosis,
            (
                SELECT status FROM user_applications 
                WHERE user_id = u.id 
                ORDER BY 
                    CASE status
                        WHEN '완료' THEN 1 
                        WHEN '진행' THEN 2 
                        WHEN '접수' THEN 3
                        ELSE 4
                    END
                LIMIT 1
            ) as highest_application_status
        FROM users u
        WHERE u.id = $1
    `;
    const { rows } = await db.query(query, [userId]);

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: '사용자를 찾을 수 없습니다.' });
    }

    const user = rows[0];
    let userLevel = 1;
    if (user.has_completed_diagnosis) userLevel = 2;
    if (user.highest_application_status) {
        userLevel = 3; // 신청/접수
        if (user.highest_application_status === '진행') userLevel = 4;
        if (user.highest_application_status === '완료') userLevel = 5;
    }
    user.level = userLevel;

    res.status(200).json({ success: true, user: user });
  } catch (error) {
    console.error('내 정보 조회 에러:', error);
    res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
  }
});

// ★★★ 2. 프로필 이미지를 업로드하고 DB에 저장하는 새로운 API를 추가합니다. ★★★
router.post('/me/profile-image', authMiddleware, upload.single('profileImage'), async (req, res) => {
    const { userId } = req.user;
    if (!req.file) {
        return res.status(400).json({ success: false, message: '업로드할 파일이 없습니다.' });
    }

    try {
        // 1. Sharp를 이용해 이미지를 리사이징하고 jpeg로 변환합니다.
        const processedImageBuffer = await sharp(req.file.buffer)
            .resize(100, 100, { fit: 'cover' })
            .toFormat('jpeg', { quality: 90 })
            .toBuffer();

        // 2. S3에 업로드하기 위한 파라미터를 설정합니다.
        const uploadParams = {
            Bucket: process.env.AWS_S3_BUCKET_NAME,
            Key: `profiles/profile-${userId}-${Date.now()}.jpeg`, // S3에 저장될 파일 경로 및 이름
            Body: processedImageBuffer,                         // 처리된 이미지 데이터
            ContentType: 'image/jpeg',                          // 파일 타입
            ACL: 'public-read'                                  // 공개 읽기 권한
        };

        // 3. S3에 이미지를 업로드합니다.
        const s3UploadResult = await s3.upload(uploadParams).promise();

        // 4. 업로드된 이미지의 최종 URL을 가져옵니다.
        const fileUrl = s3UploadResult.Location;

        // 5. DB에 최종 S3 URL을 업데이트합니다.
        await db.query('UPDATE users SET profile_image_url = $1 WHERE id = $2', [fileUrl, userId]);

        res.status(200).json({ 
            success: true, 
            message: '프로필 이미지가 변경되었습니다.', 
            profileImageUrl: fileUrl 
        });

    } catch (error) {
        console.error('프로필 이미지 업로드 에러:', error);
        res.status(500).json({ success: false, message: '이미지 처리 중 오류 발생' });
    }
});

// PUT /api/users/me - 내 정보 수정하기
router.put('/me', authMiddleware, async (req, res) => {
    const { userId } = req.user;
    const { companyName, representativeName, address, businessLocation, managerName, managerPhone, industryCodes, interests, agreed_to_marketing } = req.body;
    try {
        const query = `
            UPDATE users SET 
                company_name = $1, representative = $2, address = $3, business_location = $4, 
                manager_name = $5, manager_phone = $6, industry_codes = $7, interests = $8,
                agreed_to_marketing = $9, updated_at = NOW()
            WHERE id = $10 RETURNING *;
        `;
        const values = [companyName, representativeName, address, businessLocation, managerName, managerPhone, industryCodes, interests, agreed_to_marketing, userId];
        const result = await db.query(query, values);
        if (result.rows.length === 0) return res.status(404).json({ success: false, message: '사용자를 찾을 수 없습니다.' });
        
        const { password, ...userWithoutPassword } = result.rows[0];
        res.status(200).json({ success: true, message: '회원 정보가 성공적으로 업데이트되었습니다.', user: userWithoutPassword });
    } catch (error) {
        console.error("내 정보 업데이트 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});


// DELETE /api/users/me - 회원 탈퇴
router.delete('/me', authMiddleware, async (req, res) => {
    try {
        const { password } = req.body;
        const userId = req.user.userId;

        if (!password) {
            return res.status(400).json({ success: false, message: '비밀번호를 입력해주세요.' });
        }

        // ★★★ 1. 삭제하기 전에, S3에서 지워야 할 이미지 URL과 비밀번호를 DB에서 가져옵니다. ★★★
        const userResult = await db.query('SELECT password, profile_image_url FROM users WHERE id = $1', [userId]);
        if (userResult.rows.length === 0) {
            return res.status(404).json({ success: false, message: '사용자 정보를 찾을 수 없습니다.' });
        }
        
        const user = userResult.rows[0];
        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            return res.status(401).json({ success: false, message: '비밀번호가 올바르지 않습니다.' });
        }

        // ★★★ 2. S3에서 프로필 이미지를 삭제합니다. ★★★
        if (user.profile_image_url) {
            await deleteImageFromS3(user.profile_image_url);
        }

        // 3. 실제 DB에서 사용자 데이터를 삭제합니다.
        await db.query('DELETE FROM users WHERE id = $1', [userId]);
        
        res.status(200).json({ success: true, message: '회원 탈퇴가 성공적으로 처리되었습니다.' });

    } catch (error) {
        console.error('회원 탈퇴 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

// --- ▼▼▼ 마지막으로 완료된 진단 ID 가져오기 API 추가 ▼▼▼ ---
router.get('/me/last-diagnosis', authMiddleware, async (req, res) => {
    try {
        const userId = req.user.userId;
        
        // diagnoses 테이블에서 현재 로그인된 사용자의 진단 중, 
        // status가 'completed'인 것을 찾아 가장 최신순으로 정렬한 뒤, 
        // 맨 위에 있는 1개의 id만 가져옵니다.
        const query = `
            SELECT id FROM diagnoses 
            WHERE user_id = $1 AND status = 'completed' 
            ORDER BY updated_at DESC 
            LIMIT 1;
        `;
        const { rows } = await db.query(query, [userId]);

        if (rows.length > 0) {
            // 찾았으면 진단 ID를 보내줍니다.
            res.status(200).json({ success: true, diagnosisId: rows[0].id });
        } else {
            // 완료된 진단이 없으면 없다고 알려줍니다.
            res.status(404).json({ success: false, message: '완료된 진단이 없습니다.' });
        }
    } catch (error) {
        console.error('마지막 진단 ID 조회 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});



// GET /api/users/me/diagnosis-status - 현재 사용자의 진단 완료 상태 및 추천 프로그램 ID 목록 조회
router.get('/me/diagnosis-status', authMiddleware, async (req, res) => {
    const { userId } = req.user;
    const { diagId } = req.query;

    if (!diagId) {
        return res.status(400).json({ success: false, message: '진단 ID가 필요합니다.' });
    }

    const client = await db.pool.connect();
    try {
        await client.query('BEGIN');

        // --- 1. 진단 정보와 답변, 규칙 등 추천에 필요한 모든 데이터를 가져옵니다. ---
        const diagnosisRes = await client.query('SELECT * FROM diagnoses WHERE id = $1 AND user_id = $2', [diagId, userId]);
        if (diagnosisRes.rows.length === 0) {
            return res.status(404).json({ success: false, message: '해당 진단 정보를 찾을 수 없거나 권한이 없습니다.' });
        }
        const diagnosis = diagnosisRes.rows[0];

        const [answersRes, rulesRes] = await Promise.all([
            client.query('SELECT * FROM diagnosis_answers WHERE diagnosis_id = $1', [diagId]),
            client.query('SELECT * FROM strategy_rules')
        ]);
        const userAnswers = answersRes.rows;
        const allRules = rulesRes.rows;

        // --- 2. Step4와 동일한 추천 엔진 로직을 실행합니다. ---
        let recommendedProgramCodes = new Set();
        allRules.forEach(rule => {
            let ruleMet = false;
            const conditions = rule.conditions;
            if (!conditions || !conditions.rules) return;

            const ruleResults = conditions.rules.map(subRule => {
                if (subRule.type === 'category_score') {
                    const userScore = parseFloat(diagnosis[`${subRule.item.toLowerCase()}_score`]);
                    if (subRule.operator === '<') return userScore < subRule.value;
                    if (subRule.operator === '<=') return userScore <= subRule.value;
                    if (subRule.operator === '>') return userScore > subRule.value;
                    if (subRule.operator === '>=') return userScore >= subRule.value;
                    if (subRule.operator === '==') return userScore == subRule.value;
                }
                if (subRule.type === 'question_score') {
                    const userAnswer = userAnswers.find(ans => ans.question_code === subRule.item);
                    if (userAnswer && userAnswer.score !== null) {
                        const userAnswerScore = parseFloat(userAnswer.score);
                        if (subRule.operator === '==') return userAnswerScore == subRule.value;
                        if (subRule.operator === '>=') return userAnswerScore >= subRule.value;
                        if (subRule.operator === '>') return userAnswerScore > subRule.value;
                        if (subRule.operator === '<=') return userAnswerScore <= subRule.value;
                        if (subRule.operator === '<') return userAnswerScore < subRule.value;
                    }
                }
                return false;
            });

            if (conditions.operator === 'AND') {
                ruleMet = ruleResults.every(res => res === true);
            } else if (conditions.operator === 'OR') {
                ruleMet = ruleResults.some(res => res === true);
            }

            if (ruleMet) {
                recommendedProgramCodes.add(rule.recommended_program_code);
            }
        });
        
        // 3. 추천된 프로그램 코드에 해당하는 프로그램의 ID 목록을 조회합니다.
        const programCodes = Array.from(recommendedProgramCodes);
        let recommended_program_ids = [];
        if (programCodes.length > 0) {
            const programsRes = await client.query('SELECT id FROM esg_programs WHERE program_code = ANY($1::text[])', [programCodes]);
            recommended_program_ids = programsRes.rows.map(r => r.id);
        }
        
        await client.query('COMMIT');
        res.status(200).json({
            success: true,
            has_completed_diagnosis: true,
            recommended_program_ids: recommended_program_ids
        });

    } catch (error) {
        await client.query('ROLLBACK');
        console.error("사용자 진단 상태 조회 에러:", error);
        res.status(500).json({ success: false, message: "서버 에러" });
    } finally {
        client.release();
    }
});

/**
 * @api {get} /api/users/me/dashboard
 * @description [V4 최종 수정] 로그인된 사용자의 대시보드 정보를 조회합니다. (안정성 강화)
 */
router.get('/me/dashboard', authMiddleware, async (req, res) => {
    const { userId } = req.user;
    const client = await db.pool.connect();

    try {
        // --- 1. 진단, 답변, 질문 유형 등 계산에 필요한 모든 데이터를 한 번에 가져옵니다. ---
        const [diagRes, questionsRes, programsRes] = await Promise.all([
            client.query(`SELECT id, total_score, e_score, s_score, g_score FROM diagnoses WHERE user_id = $1 AND status = 'completed' ORDER BY created_at DESC LIMIT 1`, [userId]),
            client.query(`SELECT question_code, esg_category FROM survey_questions`),
            client.query(
                `SELECT ua.id AS application_id, ua.status, p.title AS program_title,
                 COALESCE(json_agg(am.* ORDER BY am.display_order) FILTER (WHERE am.id IS NOT NULL), '[]'::json) AS timeline
                 FROM user_applications ua
                 JOIN esg_programs p ON ua.program_id = p.id
                 LEFT JOIN application_milestones am ON ua.id = am.application_id
                 WHERE ua.user_id = $1
                 GROUP BY ua.id, p.title, ua.status
                 ORDER BY ua.created_at DESC`,
                [userId]
            )
        ]);

        if (diagRes.rows.length === 0) {
            return res.status(404).json({ success: false, message: '완료된 진단이 없어 대시보드를 표시할 수 없습니다.' });
        }

        const diagnosis = diagRes.rows[0];
        const questionsMap = new Map(questionsRes.rows.map(q => [q.question_code, q.esg_category]));
        const userAnswersRes = await client.query('SELECT question_code, score FROM diagnosis_answers WHERE diagnosis_id = $1', [diagnosis.id]);
        const userAnswersMap = new Map(userAnswersRes.rows.map(a => [a.question_code, parseFloat(a.score)]));

        // --- 2. 점수 계산 로직 ---
        const initialScores = {
            total: parseFloat(diagnosis.total_score),
            e: parseFloat(diagnosis.e_score),
            s: parseFloat(diagnosis.s_score),
            g: parseFloat(diagnosis.g_score)
        };
        const improvementScores = { total: 0, e: 0, s: 0, g: 0 };

        programsRes.rows.forEach(program => {
            program.potentialImprovement = { total: 0, e: 0, s: 0, g: 0 }; // 프로그램별 개선 점수 초기화
            program.timeline.forEach(milestone => {
                if (milestone.linked_question_codes && Array.isArray(milestone.linked_question_codes)) {
                    milestone.linked_question_codes.forEach(code => {
                        const initialScore = userAnswersMap.get(code) || 0;
                        const targetScore = milestone.score_value || 0;
                        const improvement = targetScore - initialScore;
                        const category = (questionsMap.get(code) || '').toLowerCase();

                        if (improvement > 0 && category) {
                            if (milestone.is_completed) {
                                improvementScores[category] += improvement;
                            } else {
                                program.potentialImprovement[category] += improvement;
                                program.potentialImprovement.total += improvement;
                            }
                        }
                    });
                }
            });
            improvementScores.total = improvementScores.e + improvementScores.s + improvementScores.g;
        });

        const realtimeScores = {
            total: initialScores.total + improvementScores.total,
            e: initialScores.e + improvementScores.e,
            s: initialScores.s + improvementScores.s,
            g: initialScores.g + improvementScores.g
        };
        
        res.status(200).json({
            success: true,
            dashboard: { initialScores, improvementScores, realtimeScores, programs: programsRes.rows }
        });

    } catch (error) {
        console.error('대시보드 데이터 조회 에러:', error);
        res.status(500).json({ success: false, message: '대시보드 정보를 가져오는 중 서버 오류가 발생했습니다.' });
    } finally {
        client.release();
    }
});



module.exports = router;