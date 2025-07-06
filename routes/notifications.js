// routes/notifications.js (새 파일)

const express = require('express');
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');
const router = express.Router();

// GET /api/notifications - 내 모든 알림 목록 조회
router.get('/', authMiddleware, async (req, res) => {
    try {
        const { userId } = req.user;
        const query = 'SELECT *, TO_CHAR(created_at, \'YYYY-MM-DD HH24:MI\') as display_date FROM notifications WHERE user_id = $1 ORDER BY created_at DESC';
        const { rows } = await db.query(query, [userId]);
        res.status(200).json({ success: true, notifications: rows });
    } catch (error) {
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});

// POST /api/notifications/mark-as-read - 모든 알림을 읽음으로 처리
router.post('/mark-as-read', authMiddleware, async (req, res) => {
    try {
        const { userId } = req.user;
        const query = 'UPDATE notifications SET is_read = TRUE WHERE user_id = $1 AND is_read = FALSE';
        await db.query(query, [userId]);
        res.status(200).json({ success: true, message: '모든 알림을 읽음 처리했습니다.' });
    } catch (error) {
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});

module.exports = router;