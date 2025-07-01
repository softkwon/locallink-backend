// routes/news.js (2025-07-01 09:30:00)

const express = require('express');
const db = require('../db');
const router = express.Router();

// GET /api/news - 게시물 목록 조회 (사용자용)
router.get('/', async (req, res) => {
    const { category, searchTerm, limit } = req.query;
    
    try {
        // ★★★ SELECT 절에서 image_url을 제거하고, is_pinned를 추가합니다. ★★★
        let query = `SELECT id, title, category, status, TO_CHAR(created_at, 'YYYY-MM-DD') as created_at, content, is_pinned FROM news_posts WHERE status = 'published'`;
        const queryParams = [];
        
        if (category) {
            queryParams.push(category);
            query += ` AND category = $${queryParams.length}`;
        }

        if (searchTerm) {
            queryParams.push(`%${searchTerm}%`);
            query += ` AND (title ILIKE $${queryParams.length} OR content::text ILIKE $${queryParams.length})`;
        }

        // 고정된 글을 먼저, 그 다음 최신순으로 정렬합니다.
        query += ' ORDER BY is_pinned DESC, created_at DESC';

        if (limit) {
            queryParams.push(parseInt(limit));
            query += ` LIMIT $${queryParams.length}`;
        }
        
        const { rows } = await db.query(query, queryParams);
        res.status(200).json({ success: true, posts: rows });
    } catch (error) {
        console.error("News posts 조회 에러:", error);
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});

// GET /api/news/:id - 특정 게시물 상세 조회 (사용자용)
router.get('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        // ★★★ SELECT 절에서 image_url을 제거합니다. ★★★
        const query = 'SELECT id, title, category, status, created_at, content FROM news_posts WHERE id = $1 AND status = \'published\'';
        const { rows } = await db.query(query, [id]);
        if(rows.length === 0) return res.status(404).json({ success: false, message: "게시물을 찾을 수 없습니다."});
        res.status(200).json({ success: true, post: rows[0] });
    } catch(error) { 
        console.error("News post 상세 조회 에러:", error);
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});

module.exports = router;