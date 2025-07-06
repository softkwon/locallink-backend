// routes/news.js (2025-07-01 09:30:00)

const express = require('express');
const db = require('../db');
const router = express.Router();

// S3 기본 URL. 실제 환경에서는 process.env.STATIC_BASE_URL 등을 사용해야 합니다.
const STATIC_BASE_URL = 'https://locallink-images.s3.us-east-2.amazonaws.com';

/**
 * 콘텐츠 데이터 안의 모든 상대 이미지 경로를 전체 URL로 변환하는 함수
 * @param {object} item - DB에서 가져온 데이터 한 줄 (post, program 등)
 * @returns {object} - 이미지 경로가 변환된 객체
 */
const convertContentImageUrls = (item) => {
    // 데이터나 content가 없으면 원본 그대로 반환
    if (!item || !item.content) {
        return item;
    }

    const newItem = { ...item };
    const content = (typeof newItem.content === 'string') ? JSON.parse(newItem.content) : newItem.content;

    if (Array.isArray(content)) {
        content.forEach(section => {
            if (section.images && Array.isArray(section.images)) {
                section.images = section.images.map(path => {
                    if (path && !path.startsWith('http')) {
                        return `${STATIC_BASE_URL}/${path}`;
                    }
                    return path;
                });
            }
        });
    }
    
    newItem.content = content;
    return newItem;
};


// GET /api/news - 게시물 목록 조회 (사용자용)
router.get('/', async (req, res) => {
    const { category, searchTerm, limit } = req.query;
    
    try {
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

        query += ' ORDER BY is_pinned DESC, created_at DESC';

        if (limit) {
            queryParams.push(parseInt(limit));
            query += ` LIMIT $${queryParams.length}`;
        }
        
        const { rows } = await db.query(query, queryParams);
        
        // ★★★ 수정된 부분 ★★★
        // 조회된 모든 게시물의 이미지 경로를 전체 URL로 변환합니다.
        const processedPosts = rows.map(convertContentImageUrls);

        res.status(200).json({ success: true, posts: processedPosts });
    } catch (error) {
        console.error("News posts 조회 에러:", error);
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});

// GET /api/news/:id - 특정 게시물 상세 조회 (사용자용)
router.get('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const query = 'SELECT id, title, category, status, created_at, content FROM news_posts WHERE id = $1 AND status = \'published\'';
        const { rows } = await db.query(query, [id]);
        if(rows.length === 0) return res.status(404).json({ success: false, message: "게시물을 찾을 수 없습니다."});

        // ★★★ 수정된 부분 ★★★
        // 조회된 게시물의 이미지 경로를 전체 URL로 변환합니다.
        const processedPost = convertContentImageUrls(rows[0]);

        res.status(200).json({ success: true, post: processedPost });
    } catch(error) { 
        console.error("News post 상세 조회 에러:", error);
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});

module.exports = router;