// routes/survey.js (최종 수정본)
const express = require('express');
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');
const checkPermission = require('../middleware/permissionMiddleware'); // ★★★ 이 줄을 추가합니다. ★★★

const router = express.Router();

// GET /api/survey/all - 설문에 필요한 모든 데이터(질문, 채점규칙 등) 가져오기 (기존 기능 유지)
router.get('/all', authMiddleware, async (req, res) => {
    try {
        const questionsPromise = db.query('SELECT * FROM survey_questions ORDER BY display_order ASC');
        const rulesPromise = db.query('SELECT * FROM scoring_rules');
        
        const [questionsResult, rulesResult] = await Promise.all([questionsPromise, rulesPromise]);

        res.status(200).json({ 
            success: true, 
            questions: questionsResult.rows,
            scoringRules: rulesResult.rows 
        });
    } catch (error) {
        console.error('설문 전체 데이터 조회 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

// GET /api/survey/:type - 특정 타입의 설문 정보 가져오기 (새로운 기능)
router.get(
    '/:type', // :type에는 'simple' 또는 'advanced'가 들어옵니다.
    authMiddleware,
    checkPermission(['user', 'content_manager', 'user_manager', 'super_admin']),
    async (req, res) => {
        const { type } = req.params;
        try {
            const query = 'SELECT * FROM survey_questions WHERE diagnosis_type = $1 ORDER BY display_order ASC';
            const { rows } = await db.query(query, [type]);
            res.status(200).json({ success: true, questions: rows });
        } catch (error) {
            console.error(`${type} 설문 데이터 조회 에러:`, error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

module.exports = router;