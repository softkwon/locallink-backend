// routes/simulator.js (2025-06-29 14:30:00)
const express = require('express');
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');
const router = express.Router();

// GET /api/simulator/parameters - 모든 시뮬레이터 매개변수 조회
router.get('/parameters', authMiddleware, async (req, res) => {
    try {
        const { rows } = await db.query('SELECT * FROM simulator_parameters ORDER BY id');
        
        // 프론트엔드에서 사용하기 쉽게 {이름: 값} 형태의 객체로 변환합니다.
        // 예: { "tax_rate_small": 9.9, "carbon_price": 25000, ... }
        const params = rows.reduce((obj, item) => {
            if (item.parameter_name) {
                obj[item.parameter_name] = parseFloat(item.parameter_value);
            }
            return obj;
        }, {});
        
        res.status(200).json({ success: true, parameters: params });
    } catch (error) {
        console.error("시뮬레이터 매개변수 조회 에러:", error);
        res.status(500).json({ success: false, message: "서버 에러가 발생했습니다." });
    }
});

module.exports = router;