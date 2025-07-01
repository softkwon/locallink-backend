// routes/content.js (2025-07-01 14:45:00)
const express = require('express');
const db = require('../db');
const router = express.Router();

// GET /api/content/main_page_sections - 메인 페이지 콘텐츠 조회
router.get('/main_page_sections', async (req, res) => {
    try {
        const { rows } = await db.query("SELECT content_value FROM site_content WHERE content_key = 'main_page_sections'");
        
        // ★★★ JSON.parse()를 제거합니다. ★★★
        // DB 드라이버가 JSONB 타입을 이미 자바스크립트 객체로 변환해주므로, 그대로 사용합니다.
        const content = rows.length > 0 ? rows[0].content_value : [];
        
        res.status(200).json({ success: true, content: content });
    } catch (e) {
        console.error("메인 페이지 콘텐츠 조회 에러:", e);
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

// GET /api/content/partners - 협력사 목록 조회
router.get('/partners', async (req, res) => {
    try {
        const { rows } = await db.query("SELECT * FROM partners ORDER BY display_order");
        res.status(200).json({ success: true, partners: rows });
    } catch (e) {
        console.error("협력사 목록 조회 에러:", e);
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

// GET /api/content/footer-data - 푸터에 필요한 모든 정보 조회
router.get('/footer-data', async (req, res) => {
    try {
        const [infoRes, sitesRes] = await Promise.all([
            db.query("SELECT content FROM site_content WHERE id = 1"),
            db.query("SELECT name, url FROM related_sites ORDER BY display_order")
        ]);
        res.status(200).json({
            success: true,
            footerInfo: infoRes.rows[0]?.content || {},
            relatedSites: sitesRes.rows
        });
    } catch (e) {
        console.error("푸터 데이터 조회 에러:", e);
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

// GET /api/content/legal/:type - 약관/개인정보/마케팅 동의 내용 조회
router.get('/legal/:type', async (req, res) => {
    const { type } = req.params;
    let columnName = '';
    if (type === 'terms') columnName = 'terms_of_service';
    else if (type === 'privacy') columnName = 'privacy_policy';
    else if (type === 'marketing') columnName = 'marketing_consent_text';
    else return res.status(400).json({ success: false, message: '잘못된 타입입니다.' });

    try {
        const { rows } = await db.query(`SELECT ${columnName} as content FROM site_content WHERE id = 1`);
        res.status(200).json({ success: true, content: rows[0]?.content || '' });
    } catch (e) { 
        res.status(500).json({ success: false, message: '서버 에러' }); 
    }
});

module.exports = router;
