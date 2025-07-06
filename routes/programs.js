
const express = require('express');
const db = require('../db');
const router = express.Router();

// GET /api/programs - 발행된 모든 프로그램 목록 조회 (공개용)
router.get('/', async (req, res) => {
    try {
        const query = "SELECT * FROM esg_programs WHERE status = 'published' ORDER BY id ASC";
        const { rows } = await db.query(query);

        // ★★★ 각 프로그램의 데이터를 직접 처리합니다. ★★★
        const processedPrograms = rows.map(program => {
            if (!program) return program;
            
            const jsonFields = ['content', 'economic_effects', 'related_links', 'opportunity_effects'];
            // 1. JSON 문자열들을 실제 객체/배열로 변환
            jsonFields.forEach(field => {
                if (program[field] && typeof program[field] === 'string') {
                    try {
                        program[field] = JSON.parse(program[field]);
                    } catch {
                        program[field] = []; // 오류 발생 시 빈 배열로 처리
                    }
                }
            });

            // 2. 이미지 경로를 전체 URL로 변환
            if (program.content && Array.isArray(program.content)) {
                program.content.forEach(section => {
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
            return program;
        });

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
        
        let program = rows[0];

        // --- ★★★ 직접 데이터 처리 (가장 중요) ★★★ ---
        const jsonFields = ['content', 'economic_effects', 'related_links', 'opportunity_effects'];
        
        // 1. JSON 문자열들을 실제 객체/배열로 변환
        jsonFields.forEach(field => {
            if (program[field] && typeof program[field] === 'string') {
                try {
                    program[field] = JSON.parse(program[field]);
                } catch {
                    program[field] = []; // 오류 발생 시 빈 배열로 처리
                }
            }
        });

        // 2. 이미지 경로를 전체 URL로 변환
        if (program.content && Array.isArray(program.content)) {
            program.content.forEach(section => {
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
        // --- ★★★ 데이터 처리 끝 ★★★ ---

        res.status(200).json({ success: true, program: program });

    } catch (error) {
        console.error(`공개용 프로그램 상세 조회 에러 (ID: ${id}):`, error);
        res.status(500).json({ success: false, message: "서버 에러가 발생했습니다." });
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