// routes/averages.js
const express = require('express');
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');
const router = express.Router();


// GET /api/averages/:industryCode - 특정 산업의 평균 데이터 가져오기
router.get('/:industryCode', authMiddleware, async (req, res) => {
    try {
        const { industryCode } = req.params;
        const { rows } = await db.query(
            'SELECT * FROM industry_averages WHERE industry_code = $1',
            [industryCode]
        );

        if (rows.length === 0) {
            return res.status(200).json({ success: true, averages: null }); // 404 대신, 데이터가 없음을 알림
        }
        res.status(200).json({ success: true, averages: rows[0] });
    } catch (error) {
        console.error('산업 평균 데이터 조회 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});


// GET /api/diagnoses/:id/results - 특정 진단에 대한 종합 결과 데이터 가져오기
router.get('/:id/results', authMiddleware, async (req, res) => {
    const { id } = req.params;
    const userId = req.user.id;

    try {
        // 1. 기본 진단 정보 및 점수 가져오기 (사용자 정보 포함)
        const diagnosisQuery = `
            SELECT 
                d.id, d.user_id, d.industry_codes, d.created_at, d.updated_at, d.status,
                d.total_score, d.e_score, d.s_score, d.g_score,
                u.company_name
            FROM diagnoses d
            JOIN users u ON d.user_id = u.id
            WHERE d.id = $1 AND d.user_id = $2;
        `;
        const diagnosisRes = await db.query(diagnosisQuery, [id, userId]);

        if (diagnosisRes.rows.length === 0) {
            return res.status(404).json({ success: false, message: '해당 진단을 찾을 수 없거나 권한이 없습니다.' });
        }
        const diagnosisData = diagnosisRes.rows[0];

        // 2. 사용자의 모든 답변 가져오기
        const answersRes = await db.query(
            'SELECT question_code, answer_value FROM diagnosis_answers WHERE diagnosis_id = $1',
            [id]
        );
        const userAnswers = answersRes.rows;

        // 3. 대표 산업코드의 업종 평균 데이터 가져오기
        const primaryIndustryCode = diagnosisData.industry_codes ? diagnosisData.industry_codes[0] : null;
        let industryAverages = null;
        if (primaryIndustryCode) {
            const avgRes = await db.query(
                'SELECT * FROM industry_averages WHERE industry_code = $1',
                [primaryIndustryCode]
            );
            if (avgRes.rows.length > 0) {
                industryAverages = avgRes.rows[0];
            }
        }

        // 4. 모든 정보를 종합하여 최종 결과 데이터 구성
        const resultData = {
            diagnosis: diagnosisData,
            userAnswers: userAnswers,
            industryAverages: industryAverages
        };

        res.status(200).json({ success: true, results: resultData });

    } catch (error) {
        console.error('진단 결과 조회 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

module.exports = router;