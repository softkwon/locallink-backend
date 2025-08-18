const express = require('express');
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/check-eligibility', authMiddleware, async (req, res) => {
    const { userId, role } = req.user;
    console.log(`[Check Eligibility] User ID: ${userId}, Role: ${role}`); // 디버깅용 로그

    try {
        const adminRoles = ['super_admin', 'vice_super_admin', 'content_manager', 'user_manager'];
        if (adminRoles.includes(role)) {
            console.log(`[Check Eligibility] Admin user. Access granted.`);
            return res.status(200).json({ success: true, eligible: true });
        }

        const userRes = await db.query('SELECT used_referral_code FROM users WHERE id = $1', [userId]);
        
        if (userRes.rows.length === 0) {
            return res.status(404).json({ success: false, message: '사용자 정보를 찾을 수 없습니다.' });
        }

        const userReferralCode = userRes.rows[0].used_referral_code;

        if (!userReferralCode) {
            console.log(`[Check Eligibility] User has no referral code. Access denied.`);
            return res.status(200).json({ success: true, eligible: false, message: '등록된 추천 코드가 없습니다.' });
        }

        const codeRes = await db.query(
            'SELECT id FROM referral_codes WHERE code = $1 AND (expires_at IS NULL OR expires_at > NOW())',
            [userReferralCode]
        );

        if (codeRes.rows.length > 0) {
            console.log(`[Check Eligibility] User has a valid code. Access granted.`);
            res.status(200).json({ success: true, eligible: true });
        } else {
            console.log(`[Check Eligibility] User's code is invalid or expired. Access denied.`);
            res.status(200).json({ success: true, eligible: false, message: '등록된 추천 코드가 유효하지 않습니다.' });
        }

    } catch (error) {
        console.error('진단 자격 확인 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

router.get('/my-history', authMiddleware, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { rows } = await db.query(
            'SELECT id, total_score, created_at FROM diagnoses WHERE user_id = $1 ORDER BY created_at DESC',
            [userId]
        );
        res.status(200).json({ success: true, history: rows });
    } catch (error) {
        console.error('진단 이력 조회 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

router.get('/count', authMiddleware, async (req, res) => {
    try {
        const userId = req.user.userId;
        const userRole = req.user.role; 

        const limits = {
            user: 1,
            content_manager: 5,
            user_manager: 5,
            super_admin: 10
        };

        const maxAttempts = limits[userRole] || 1;

        const { rows } = await db.query('SELECT COUNT(id) as count FROM diagnoses WHERE user_id = $1', [userId]);
        const currentCount = parseInt(rows[0].count);

        res.status(200).json({ success: true, count: currentCount, limit: maxAttempts });

    } catch (error) {
        console.error("진단 횟수 조회 에러:", error);
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});


router.post('/', authMiddleware, async (req, res) => {
    const { userId } = req.user;
    const {
        companyName, representativeName, industryCodes, establishmentYear,
        employeeCount, productsServices, recentSales, recentOperatingProfit,
        exportPercentage, isListed, companySize, mainBusinessRegion
    } = req.body;

    try {
        let isFree = false;
        const userRes = await db.query('SELECT used_referral_code FROM users WHERE id = $1', [userId]);
        const userReferralCode = userRes.rows[0]?.used_referral_code;

        if (userReferralCode) {
            const codeRes = await db.query(
                'SELECT id FROM referral_codes WHERE code = $1 AND (expires_at IS NULL OR expires_at > NOW())',
                [userReferralCode]
            );
            if (codeRes.rows.length > 0) {
                isFree = true;
            }
        }

        const query = `
            INSERT INTO diagnoses (
                user_id, company_name, representative_name, industry_codes, establishment_year,
                employee_count, products_services, recent_sales, recent_operating_profit,
                export_percentage, is_listed, company_size, main_business_region,
                diagnosis_type, status, is_free
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, 'simple', 'in_progress', $14)
            RETURNING id;
        `;
        const values = [
            userId, companyName, representativeName, industryCodes, establishmentYear,
            employeeCount, productsServices, recentSales, recentOperatingProfit,
            exportPercentage, isListed, companySize, mainBusinessRegion,
            isFree // is_free 값 추가
        ];

        const result = await db.query(query, values);
        res.status(201).json({ 
            success: true, 
            message: '새로운 진단이 시작되었습니다.',
            diagnosisId: result.rows[0].id 
        });
    } catch (error) {
        console.error('진단 시작(Step 1) 데이터 저장 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

router.put('/:id', authMiddleware, async (req, res) => {
    const { id: diagnosisId } = req.params;
    const userId = req.user.userId;
    const {
        companyName, representativeName, industryCodes, establishmentYear,
        employeeCount, productsServices, recentSales, recentOperatingProfit,
        exportPercentage, isListed, companySize, mainBusinessRegion
    } = req.body;

    try {
        const query = `
            UPDATE diagnoses 
            SET 
                company_name = $1, representative_name = $2, industry_codes = $3, establishment_year = $4,
                employee_count = $5, products_services = $6, recent_sales = $7, recent_operating_profit = $8,
                export_percentage = $9, is_listed = $10, company_size = $11, main_business_region = $12
            WHERE id = $13 AND user_id = $14
            RETURNING id;
        `;
        const values = [
            companyName, representativeName, industryCodes, establishmentYear,
            employeeCount, productsServices, recentSales, recentOperatingProfit,
            exportPercentage, isListed, companySize, mainBusinessRegion,
            diagnosisId, userId
        ];

        const result = await db.query(query, values);

        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, message: '해당 진단을 찾을 수 없거나 수정할 권한이 없습니다.' });
        }
        res.status(200).json({ success: true, message: '진단 정보가 성공적으로 업데이트되었습니다.', diagnosisId: result.rows[0].id });
    } catch (error) {
        console.error('진단 정보 수정 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

router.get('/:id', authMiddleware, async (req, res) => {
    const { id: diagnosisId } = req.params;
    const userId = req.user.userId;

    try {
        const query = 'SELECT * FROM diagnoses WHERE id = $1 AND user_id = $2';
        const { rows } = await db.query(query, [diagnosisId, userId]);

        if (rows.length === 0) {
            return res.status(404).json({ success: false, message: '해당 진단을 찾을 수 없거나 조회할 권한이 없습니다.' });
        }
        res.status(200).json({ success: true, diagnosis: rows[0] });
    } catch (error) {
        console.error('특정 진단 정보 조회 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});


router.post('/:id/answers', authMiddleware, async (req, res) => {
    const { id: diagnosisId } = req.params;
    const { userId } = req.user;
    const answers = req.body;
    const client = await db.pool.connect();
    try {
        await client.query('BEGIN');
        
        const diagnosisCheck = await client.query('SELECT user_id, industry_codes FROM diagnoses WHERE id = $1', [diagnosisId]);
        if (diagnosisCheck.rows.length === 0 || diagnosisCheck.rows[0].user_id !== userId) { throw new Error('권한이 없습니다.'); }
        
        const primaryIndustryCode = diagnosisCheck.rows[0].industry_codes ? diagnosisCheck.rows[0].industry_codes[0] : null;

        const [questionsResult, rulesResult, benchmarkRulesResult, avgResult] = await Promise.all([
            client.query('SELECT * FROM survey_questions'),
            client.query('SELECT * FROM scoring_rules'),
            client.query('SELECT * FROM benchmark_scoring_rules'),
            primaryIndustryCode ? client.query('SELECT * FROM industry_averages WHERE industry_code = $1', [primaryIndustryCode]) : Promise.resolve({ rows: [] })
        ]);
        const allQuestions = questionsResult.rows, scoringRules = rulesResult.rows, benchmarkRules = benchmarkRulesResult.rows, industryAverages = avgResult.rows[0] || null;

        await client.query('DELETE FROM diagnosis_answers WHERE diagnosis_id = $1', [diagnosisId]);
        
        const answerInsertPromises = [];
        
        for (const questionCode in answers) {
            if (answers[questionCode]) {
                const userAnswer = answers[questionCode];
                const question = allQuestions.find(q => q.question_code === questionCode);
                if (!question) continue;

                let score = 0;
                let rule = scoringRules.find(r => r.question_code === questionCode && r.answer_condition === userAnswer);
                if (!rule) {
                    rule = scoringRules.find(r => r.question_code === questionCode && r.answer_condition === '*');
                }

                if (rule) {
                    const score_rule = rule.score;
                    if (score_rule === 'BENCHMARK_GHG' || score_rule === 'BENCHMARK_ENERGY' || score_rule === 'BENCHMARK_WASTE') {
                        const metricName = industryAverages ? Object.keys(industryAverages).find(key => key.startsWith(score_rule.split('_')[1].toLowerCase())) : null;
                        if (metricName && industryAverages) {
                            const avg = parseFloat(industryAverages[metricName]);
                            const userVal = parseFloat(userAnswer);
                            if (!isNaN(avg) && !isNaN(userVal) && avg > 0) {
                                const ratio = userVal / avg;
                                const tiers = benchmarkRules.filter(r => r.metric_name === metricName).sort((a,b) => a.upper_bound - b.upper_bound);
                                for (const tier of tiers) {
                                    if (tier.is_inverted && ratio <= tier.upper_bound) {
                                        score = parseFloat(tier.score);
                                        break;
                                    }
                                }
                            }
                        }
                    } else {
                        score = parseFloat(score_rule);
                    }
                }
                
                const query = 'INSERT INTO diagnosis_answers (diagnosis_id, question_code, answer_value, score) VALUES ($1, $2, $3, $4)';
                answerInsertPromises.push(client.query(query, [diagnosisId, questionCode, userAnswer, score]));
            }
        }
        await Promise.all(answerInsertPromises);
        
        const questionsMap = new Map(allQuestions.map(q => [q.question_code, q.esg_category]));
        const answersRes = await client.query('SELECT question_code, score FROM diagnosis_answers WHERE diagnosis_id = $1', [diagnosisId]);

        const totalScores = { e: 0, s: 0, g: 0 };
        const questionCounts = { e: 0, s: 0, g: 0 };
        const mainQuestionsAnswered = { e: new Set(), s: new Set(), g: new Set() };

        answersRes.rows.forEach(answer => {
            const category = (questionsMap.get(answer.question_code) || '').toLowerCase();
            const score = parseFloat(answer.score) || 0;
            if (totalScores[category] !== undefined) {
                totalScores[category] += score;
                const mainQuestionCode = answer.question_code.split('_')[0];
                mainQuestionsAnswered[category].add(mainQuestionCode);
            }
        });

        questionCounts.e = mainQuestionsAnswered.e.size;
        questionCounts.s = mainQuestionsAnswered.s.size;
        questionCounts.g = mainQuestionsAnswered.g.size;

        const averageScores = {
            e: questionCounts.e > 0 ? totalScores.e / questionCounts.e : 0,
            s: questionCounts.s > 0 ? totalScores.s / questionCounts.s : 0,
            g: questionCounts.g > 0 ? totalScores.g / questionCounts.g : 0,
        };
        averageScores.total = (averageScores.e + averageScores.s + averageScores.g) / 3;

        const updateQuery = `
            UPDATE diagnoses SET
                status = 'completed',
                total_score = $1,
                e_score = $2, s_score = $3, g_score = $4,
                e_total_score = $5, s_total_score = $6, g_total_score = $7,
                updated_at = NOW()
            WHERE id = $8
        `;
        await client.query(updateQuery, [
            averageScores.total.toFixed(2),
            averageScores.e.toFixed(2), averageScores.s.toFixed(2), averageScores.g.toFixed(2),
            totalScores.e.toFixed(2), totalScores.s.toFixed(2), totalScores.g.toFixed(2),
            diagnosisId
        ]);
        
        await client.query('COMMIT');
        res.status(200).json({ success: true, message: '설문이 성공적으로 제출되었으며, 채점이 완료되었습니다.', diagnosisId: diagnosisId });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('설문(Step 2) 답변 저장 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    } finally {
        client.release();
    }
});


router.get('/:id/results', authMiddleware, async (req, res) => {
    const { id } = req.params; // URL에서 진단 ID를 가져옵니다.
    const userId = req.user.userId; // 로그인된 사용자 ID를 가져옵니다.

    try {
    const diagnosisPromise = db.query(`SELECT d.*, u.company_name FROM diagnoses d JOIN users u ON d.user_id = u.id WHERE d.id = $1 AND d.user_id = $2;`, [id, userId]);
    const answersPromise = db.query(`
        SELECT da.question_code, da.answer_value, da.score, sq.question_text, sq.options, sq.criteria_text, sq.esg_category, sq.display_order
        FROM diagnosis_answers da
        JOIN survey_questions sq ON da.question_code = sq.question_code
        WHERE da.diagnosis_id = $1 AND sq.diagnosis_type = 'simple'
    `, [id]);
    const rulesPromise = db.query('SELECT * FROM scoring_rules');
    const questionsPromise = db.query("SELECT * FROM survey_questions WHERE diagnosis_type = 'simple' ORDER BY display_order ASC");

    const [diagnosisRes, rulesRes, questionsRes] = await Promise.all([diagnosisPromise, answersPromise, rulesPromise, questionsPromise]);
    const answersRes = await db.query(
    `SELECT da.question_code, da.answer_value, da.score, sq.question_text, sq.options, sq.criteria_text, sq.esg_category, sq.display_order
     FROM diagnosis_answers da
     JOIN survey_questions sq ON da.question_code = sq.question_code
     WHERE da.diagnosis_id = $1`, // ORDER BY는 JS에서 처리하므로 삭제
    [id]
    );
    
    if (diagnosisRes.rows.length === 0) {
        return res.status(404).json({ success: false, message: '진단을 찾을 수 없습니다.' });
    }
    const diagnosisData = diagnosisRes.rows[0];
    const userAnswers = answersRes.rows;
    const scoringRules = rulesRes.rows;
    const allQuestions = questionsRes.rows; // ★★★ 가져온 질문 목록

    const primaryIndustryCode = diagnosisData.industry_codes ? diagnosisData.industry_codes[0] : null;
    let industryAverages = null;
    if (primaryIndustryCode) {
        const avgRes = await db.query('SELECT * FROM industry_averages WHERE industry_code = $1', [primaryIndustryCode]);
        if (avgRes.rows.length > 0) industryAverages = avgRes.rows[0];
    }
    res.status(200).json({ 
        success: true, 
        results: {
            diagnosis: diagnosisData,
            userAnswers: userAnswers,
            industryAverages: industryAverages,
            scoringRules: scoringRules,
            allQuestions: allQuestions // ★★★ 응답에 전체 질문 목록 추가 ★★★
        } 
    });
} catch (error) {
    console.error('진단 결과 조회 에러:', error);
    res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
}
});


router.delete('/:id', authMiddleware, async (req, res) => {
    const { id: diagnosisId } = req.params;
    const userId = req.user.userId;
    const client = await db.pool.connect();
    try {
        await client.query('BEGIN');
        
        await client.query('DELETE FROM diagnosis_answers WHERE diagnosis_id = $1', [diagnosisId]);
        
        const { rowCount } = await client.query('DELETE FROM diagnoses WHERE id = $1 AND user_id = $2', [diagnosisId, userId]);
        
        if (rowCount === 0) {
            return res.status(404).json({ success: false, message: '삭제할 진단이 없거나 권한이 없습니다.' });
        }
        
        await client.query('COMMIT');
        res.status(200).json({ success: true, message: '진단 기록이 삭제되었습니다.' });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('진단 삭제 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    } finally {
        client.release();
    }
});



module.exports = router;