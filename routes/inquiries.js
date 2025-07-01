// routes/inquiries.js (2025-06-27 23:10:00 - 최종 완성본)
const express = require('express');
const jwt = require('jsonwebtoken'); // 토큰 해석을 위해 추가
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');
const router = express.Router();

// POST /api/inquiries - 새로운 문의 등록
router.post('/', async (req, res) => {
    
    // 1. 프론트엔드에서 보낸 모든 데이터를 일단 변수에 저장합니다.
    const { company_name, manager_name, phone, email, inquiry_type, content } = req.body;
    let userId = null;

    // ★★★ 디버깅을 위해 받은 데이터를 로그로 출력합니다. ★★★
    console.log('서버가 받은 문의 데이터:', req.body);

    try {
        // 2. 혹시 로그인한 사용자일 경우를 대비해, 헤더에서 토큰을 확인합니다.
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];

        if (token) {
            try {
                // 토큰이 유효하다면, 사용자 ID를 가져옵니다.
                const decoded = jwt.verify(token, process.env.JWT_SECRET);
                userId = decoded.userId;
            } catch (jwtError) {
                // 토큰이 만료되었거나 유효하지 않아도, 문의는 계속 진행되도록 오류를 무시합니다.
                console.log("문의 등록 중 만료된 토큰 발견:", jwtError.message);
            }
        }

        // 3. 데이터베이스에 저장할 최종 값을 준비합니다.
        const query = `
            INSERT INTO inquiries (user_id, company_name, manager_name, phone, email, inquiry_type, content) 
            VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`;
        const values = [userId, company_name, manager_name, phone, email, inquiry_type, content];
        
        await db.query(query, values);
        
        res.status(201).json({ success: true, message: '문의가 성공적으로 접수되었습니다.' });

    } catch (error) {
        console.error("문의 등록 최종 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

// GET /api/inquiries/my-inquiries - 나의 문의 내역 조회
router.get('/my-inquiries', authMiddleware, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { rows } = await db.query('SELECT * FROM inquiries WHERE user_id = $1 ORDER BY created_at DESC', [userId]);
        res.status(200).json({ success: true, inquiries: rows });
    } catch (error) {
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

module.exports = router;