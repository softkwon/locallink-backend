// routes/programs.js (새 파일)
const express = require('express');
const db = require('../db');
const router = express.Router();

// GET /api/programs - 발행된 모든 프로그램 목록 조회 (공개용)
router.get('/', async (req, res) => {
    try {
        // ★★★ SELECT * 로 변경하여 이미지, 서비스 지역 등 모든 정보를 가져오도록 수정 ★★★
        const query = "SELECT * FROM esg_programs WHERE status = 'published' ORDER BY id ASC";
        const { rows } = await db.query(query);
        res.status(200).json({ success: true, programs: rows });
    } catch (error) {
        console.error("공개용 프로그램 목록 조회 에러:", error);
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});

// GET /api/programs/:id - 특정 프로그램 상세 정보 조회 (공개용)
router.get('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const query = "SELECT * FROM esg_programs WHERE id = $1 AND status = 'published'";
        const { rows } = await db.query(query, [id]);
        if (rows.length === 0) {
            return res.status(404).json({ success: false, message: "프로그램을 찾을 수 없습니다." });
        }
        res.status(200).json({ success: true, program: rows[0] });
    } catch (error) {
        console.error("공개용 프로그램 상세 조회 에러:", error);
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});

// POST /api/programs/batch-details - 여러 프로그램 상세 정보 조회
router.post('/batch-details', async (req, res) => {
    const { programIds } = req.body; // [1, 5, 10] 과 같은 배열
    if (!programIds || !Array.isArray(programIds) || programIds.length === 0) {
        return res.status(200).json({ success: true, programs: [] });
    }
    try {
        const query = 'SELECT * FROM esg_programs WHERE id = ANY($1::int[])';
        const { rows } = await db.query(query, [programIds]);
        res.status(200).json({ success: true, programs: rows });
    } catch (error) {
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

module.exports = router;