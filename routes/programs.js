
const express = require('express');
const db = require('../db');
const router = express.Router();

/**
 * 프로그램 데이터의 모든 JSON 필드를 파싱하고, 이미지 경로를 전체 URL로 변환하는 통합 함수
 * @param {object} program - DB에서 가져온 프로그램 데이터 한 줄
 * @returns {object} - 모든 경로와 JSON이 처리된 프로그램 객체
 */
const processProgramData = (program) => {
    if (!program) return program;

    const newProgram = { ...program };
    const jsonFields = ['content', 'economic_effects', 'related_links', 'opportunity_effects'];

    // 1. 문자열 상태인 JSON 필드를 모두 실제 객체/배열로 변환
    jsonFields.forEach(field => {
        if (newProgram[field] && typeof newProgram[field] === 'string') {
            try {
                newProgram[field] = JSON.parse(newProgram[field]);
            } catch (e) {
                console.error(`[CRITICAL] JSON 파싱 오류! (Program ID: ${newProgram.id}, Field: ${field})`, e);
                newProgram[field] = []; // 파싱 오류 시 빈 배열로 초기화
            }
        }
    });

    // 2. content 안의 이미지 경로를 전체 URL로 변환
    if (newProgram.content && Array.isArray(newProgram.content)) {
        newProgram.content.forEach(section => {
            if (section.images && Array.isArray(section.images)) {
                section.images = section.images.map(path => {
                    if (path && !path.startsWith('http')) {
                        return `${process.env.STATIC_BASE_URL}/${path}`;
                    }
                    return path;
                });
            }
        });
    }

    return newProgram;
};


// GET /api/programs - 발행된 모든 프로그램 목록 조회 (공개용)
router.get('/', async (req, res) => {
    try {
        const query = "SELECT * FROM esg_programs WHERE status = 'published' ORDER BY id ASC";
        const { rows } = await db.query(query);
        const processedPrograms = rows.map(processProgramData);
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
        
        const processedProgram = processProgramData(rows[0]);

        // ★★★ 디버깅용 로그 추가 ★★★
        // 이 로그를 통해 서버가 프론트로 보내기 직전의 데이터 타입을 확인할 수 있습니다.
        console.log(`[DEBUG] Program ID ${id} 데이터 처리 결과:`);
        console.log(`[DEBUG]   - related_links 타입: ${typeof processedProgram.related_links}`);
        console.log(`[DEBUG]   - opportunity_effects 타입: ${typeof processedProgram.opportunity_effects}`);
        
        res.status(200).json({ success: true, program: processedProgram });

    } catch (error) {
        console.error(`공개용 프로그램 상세 조회 에러 (ID: ${id}):`, error);
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});

// POST /api/programs/batch-details - 여러 프로그램 상세 정보 조회
router.post('/batch-details', async (req, res) => {
    const { programIds } = req.body;
    if (!programIds || !Array.isArray(programIds) || programIds.length === 0) {
        return res.status(200).json({ success: true, programs: [] });
    }
    try {
        const query = 'SELECT * FROM esg_programs WHERE id = ANY($1::int[])';
        const { rows } = await db.query(query, [programIds]);
        const processedPrograms = rows.map(processProgramData);
        res.status(200).json({ success: true, programs: processedPrograms });
    } catch (error) {
        console.error("배치 상세 조회 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

module.exports = router;