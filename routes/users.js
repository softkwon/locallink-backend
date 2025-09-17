const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');     
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');
const multer = require('multer');
const sharp = require('sharp'); 
const path = require('path');
const fs = require('fs');
const s3 = require('../config/s3-client');

const storage = multer.memoryStorage();
const upload = multer({ storage: storage, limits: { fileSize: 5 * 1024 * 1024 } });
const router = express.Router();

router.get('/me', authMiddleware, async (req, res) => {
    try {
        const { userId } = req.user;
        
        const query = `
            SELECT 
                u.id, u.email, u.company_name, u.representative, u.role, u.profile_image_url,
                u.address, u.business_location, u.manager_name, u.manager_phone, u.industry_codes, u.interests, u.agreed_to_marketing,
                u.used_referral_code,
                recommender.company_name AS recommending_organization_name,
                EXISTS (SELECT 1 FROM diagnoses WHERE user_id = u.id AND status = 'completed') as has_completed_diagnosis,
                (
                    SELECT status FROM user_applications 
                    WHERE user_id = u.id 
                    ORDER BY 
                        CASE status WHEN '완료' THEN 1 WHEN '진행' THEN 2 WHEN '접수' THEN 3 ELSE 4 END
                    LIMIT 1
                ) as highest_application_status
            FROM users u
            LEFT JOIN users recommender ON u.recommending_organization_id = recommender.id
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
            userLevel = 3;
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


router.post('/me/profile-image', authMiddleware, upload.single('profileImage'), async (req, res) => {
    const { userId } = req.user;
    if (!req.file) {
        return res.status(400).json({ success: false, message: '업로드할 파일이 없습니다.' });
    }

    try {
        const processedImageBuffer = await sharp(req.file.buffer)
            .resize(100, 100, { fit: 'cover' })
            .toFormat('jpeg', { quality: 90 })
            .toBuffer();

        const uploadParams = {
            Bucket: process.env.AWS_S3_BUCKET_NAME,
            Key: `profiles/profile-${userId}-${Date.now()}.jpeg`, // S3에 저장될 파일 경로 및 이름
            Body: processedImageBuffer,                         // 처리된 이미지 데이터
            ContentType: 'image/jpeg',                          // 파일 타입
            ACL: 'public-read'                                  // 공개 읽기 권한
        };

        const s3UploadResult = await s3.upload(uploadParams).promise();

        const fileUrl = s3UploadResult.Location;

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


router.delete('/me', authMiddleware, async (req, res) => {
    try {
        const { password } = req.body;
        const userId = req.user.userId;

        if (!password) {
            return res.status(400).json({ success: false, message: '비밀번호를 입력해주세요.' });
        }

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

// GET /api/users/me/dashboard - 나의 ESG 활동 대시보드 데이터 조회 (V2)
router.get('/me/dashboard', authMiddleware, async (req, res) => {
    const { userId } = req.user;
    const client = await db.pool.connect();

    try {
        const [diagRes, questionsRes, programsRes] = await Promise.all([
            client.query(`SELECT id, e_score, s_score, g_score, e_total_score, s_total_score, g_total_score FROM diagnoses WHERE user_id = $1 AND status = 'completed' ORDER BY created_at DESC LIMIT 1`, [userId]),
            client.query(`SELECT question_code, esg_category FROM survey_questions`),
            client.query(
                `SELECT ua.id AS application_id, ua.status, p.title AS program_title, p.esg_category,
                 COALESCE(json_agg(am.* ORDER BY am.display_order) FILTER (WHERE am.id IS NOT NULL), '[]'::json) AS timeline
                 FROM user_applications ua
                 JOIN esg_programs p ON ua.program_id = p.id
                 LEFT JOIN application_milestones am ON ua.id = am.application_id
                 WHERE ua.user_id = $1
                 GROUP BY ua.id, p.title, p.esg_category, ua.status
                 ORDER BY ua.created_at DESC`,
                [userId]
            )
        ]);

        if (diagRes.rows.length === 0) {
            return res.status(404).json({ success: false, message: '완료된 진단이 없어 대시보드를 표시할 수 없습니다.' });
        }

        const diagnosis = diagRes.rows[0];
        
        // ★★★ [핵심 수정] E, S, G 각 카테고리별 "메인 질문"의 개수만 정확히 계산 ★★★
        const answeredQuestionsRes = await client.query('SELECT question_code FROM diagnosis_answers WHERE diagnosis_id = $1', [diagnosis.id]);
        const questionsMap = new Map(questionsRes.rows.map(q => [q.question_code, q.esg_category]));
        const mainQuestionsAnswered = { e: new Set(), s: new Set(), g: new Set() };

        answeredQuestionsRes.rows.forEach(ans => {
            const category = (questionsMap.get(ans.question_code) || '').toLowerCase();
            if (mainQuestionsAnswered[category]) {
                const mainQuestionCode = ans.question_code.split('_')[0]; // SQ1_1 -> SQ1
                mainQuestionsAnswered[category].add(mainQuestionCode);
            }
        });

        const questionCounts = {
            e: mainQuestionsAnswered.e.size,
            s: mainQuestionsAnswered.s.size,
            g: mainQuestionsAnswered.g.size
        };

        const initialScores = {
            e: parseFloat(diagnosis.e_score) || 0,
            s: parseFloat(diagnosis.s_score) || 0,
            g: parseFloat(diagnosis.g_score) || 0
        };
        initialScores.total = (initialScores.e + initialScores.s + initialScores.g) / 3;
        
        // ★★★ [핵심 수정] DB의 총점 값이 null일 경우, 평균 점수를 기반으로 총점을 "정확하게" 역산 ★★★
        const initialTotalScores = {
            e: parseFloat(diagnosis.e_total_score) || (initialScores.e * questionCounts.e),
            s: parseFloat(diagnosis.s_total_score) || (initialScores.s * questionCounts.s),
            g: parseFloat(diagnosis.g_total_score) || (initialScores.g * questionCounts.g)
        };

        const improvementScores = { e: 0, s: 0, g: 0 };
        programsRes.rows.forEach(program => {
            program.potentialImprovement = { e: 0, s: 0, g: 0 };
            program.timeline.forEach(milestone => {
                const improvement = milestone.score_value || 0;
                const category = (milestone.improvement_category || '').toLowerCase();
                if (improvement > 0 && ['e', 's', 'g'].includes(category)) {
                    if (milestone.is_completed) {
                        improvementScores[category] += improvement;
                    } else {
                        program.potentialImprovement[category] += improvement;
                    }
                }
            });
            program.potentialImprovement.total = (program.potentialImprovement.e + program.potentialImprovement.s + program.potentialImprovement.g);
        });
        
        const realtimeScores = { e: 0, s: 0, g: 0, total: 0 };
        const categories = ['e', 's', 'g'];
        categories.forEach(cat => {
            if (questionCounts[cat] > 0) {
                const improvedTotal = initialTotalScores[cat] + improvementScores[cat];
                realtimeScores[cat] = improvedTotal / questionCounts[cat];
            } else {
                realtimeScores[cat] = initialScores[cat];
            }
        });
        realtimeScores.total = (realtimeScores.e + realtimeScores.s + realtimeScores.g) / 3;
        
        // ★★★ [핵심 수정] 프론트엔드에 표시될 "개선 점수"는 평균 점수의 차이로 계산 ★★★
        const finalImprovementScores = {
            e: realtimeScores.e - initialScores.e,
            s: realtimeScores.s - initialScores.s,
            g: realtimeScores.g - initialScores.g,
        };
        finalImprovementScores.total = realtimeScores.total - initialScores.total;

        res.status(200).json({
            success: true,
            dashboard: { 
                initialScores, 
                improvementScores: finalImprovementScores, 
                realtimeScores, 
                rawTotalScores: initialTotalScores, 
                programs: programsRes.rows 
            }
        });

    } catch (error) {
        console.error('대시보드 데이터 조회 에러:', error);
        res.status(500).json({ success: false, message: '대시보드 정보를 가져오는 중 서버 오류가 발생했습니다.' });
    } finally {
        client.release();
    }
});

/**
 * @api {put} /api/users/me/referral
 * @description 추천 코드를 등록하거나 수정합니다.
 */
router.put('/me/referral', authMiddleware, async (req, res) => {
    const { userId } = req.user;
    const { referral_code } = req.body;

    if (!referral_code) {
        return res.status(400).json({ success: false, message: '추천 코드를 입력해주세요.' });
    }

    const client = await db.pool.connect();
    try {
        await client.query('BEGIN');

        // 1. 현재 사용자 정보 조회 (이미 코드가 있는지 확인)
        const currentUserRes = await client.query('SELECT used_referral_code FROM users WHERE id = $1', [userId]);
        if (currentUserRes.rows[0]?.used_referral_code) {
            return res.status(400).json({ success: false, message: '추천 코드는 한 번만 등록할 수 있습니다.' });
        }

        // 2. 추천 코드 유효성 검증
        const codeRes = await client.query(
            'SELECT linked_admin_id FROM referral_codes WHERE code = $1 AND (expires_at IS NULL OR expires_at > NOW())',
            [referral_code]
        );

        if (codeRes.rows.length === 0) {
            return res.status(400).json({ success: false, message: '유효하지 않거나 만료된 추천 코드입니다.' });
        }
        const recommendingOrgId = codeRes.rows[0].linked_admin_id;

        // 3. 사용자 정보에 추천 코드와 추천 단체 ID 업데이트
        await client.query(
            'UPDATE users SET used_referral_code = $1, recommending_organization_id = $2 WHERE id = $3',
            [referral_code, recommendingOrgId, userId]
        );

        await client.query('COMMIT');
        res.status(200).json({ success: true, message: '추천 코드가 성공적으로 등록되었습니다.' });

    } catch (error) {
        await client.query('ROLLBACK');
        console.error("추천 코드 등록 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    } finally {
        client.release();
    }
});


router.delete('/me/referral', authMiddleware, async (req, res) => {
    const { userId } = req.user;
    try {
        const query = `
            UPDATE users 
            SET used_referral_code = NULL, recommending_organization_id = NULL 
            WHERE id = $1
            RETURNING id;
        `;
        const { rowCount } = await db.query(query, [userId]);

        if (rowCount === 0) {
            return res.status(404).json({ success: false, message: '사용자를 찾을 수 없습니다.' });
        }
        res.status(200).json({ success: true, message: '추천 코드 정보가 삭제되었습니다.' });

    } catch (error) {
        console.error("추천 코드 삭제 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

module.exports = router;