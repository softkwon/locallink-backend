// routes/programs.js (새 파일)
const express = require('express');
const db = require('../db');
const router = express.Router();


/**
 * 프로그램 content 데이터 안의 모든 상대 이미지 경로를 전체 URL로 변환하는 함수
 * @param {object} program - DB에서 가져온 프로그램 데이터 한 줄
 * @returns {object} - 이미지 경로가 변환된 프로그램 객체
 */
const convertProgramContentUrls = (program) => {
    if (!program || !program.content) {
        return program;
    }

    const newProgram = { ...program };
    const content = (typeof newProgram.content === 'string') ? JSON.parse(newProgram.content) : newProgram.content;

    if (Array.isArray(content)) {
        content.forEach(section => {
            if (section.images && Array.isArray(section.images)) {
                section.images = section.images.map(path => {
                    if (path && !path.startsWith('http')) {
                        // 이제 process.env에 설정된 올바른 S3 주소를 사용하게 됩니다.
                        return `${process.env.STATIC_BASE_URL}/${path}`;
                    }
                    return path;
                });
            }
        });
    }
    newProgram.content = content;
    return newProgram;
};


// GET /api/programs - 발행된 모든 프로그램 목록 조회 (공개용)
router.get('/', async (req, res) => {
    try {
        const query = "SELECT * FROM esg_programs WHERE status = 'published' ORDER BY id ASC";
        const { rows } = await db.query(query);

        // ★★★ 수정된 부분 ★★★
        const processedPrograms = rows.map(convertProgramContentUrls);

        res.status(200).json({ success: true, programs: processedPrograms });
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
        
        // ★★★ 수정된 부분 ★★★
        const processedProgram = convertProgramContentUrls(rows[0]);

        res.status(200).json({ success: true, program: processedProgram });
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

        // ★★★ 수정된 부분 ★★★
        const processedPrograms = rows.map(convertProgramContentUrls);

        res.status(200).json({ success: true, programs: processedPrograms });
    } catch (error) {
        console.error("배치 상세 조회 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

module.exports = router;