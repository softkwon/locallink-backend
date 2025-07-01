// routes/industries.js
const express = require('express');
const db = require('../db');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');

// GET /api/industries - 모든 산업분류코드 목록 가져오기
router.get('/', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT * FROM industries ORDER BY code');
    res.status(200).json({ success: true, industries: rows });
  } catch (error) {
    console.error('산업분류코드 조회 에러:', error);
    res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
  }
});

// --- ▼▼▼ 나의 문의 내역 조회 API 추가 ▼▼▼ ---
router.get('/my-inquiries', authMiddleware, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { rows } = await db.query('SELECT * FROM inquiries WHERE user_id = $1 ORDER BY created_at DESC', [userId]);
        res.status(200).json({ success: true, inquiries: rows });
    } catch (error) {
        console.error("내 문의 내역 조회 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

module.exports = router;