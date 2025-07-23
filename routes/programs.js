
const express = require('express');
const db = require('../db');
const router = express.Router();

const processProgramData = (program) => {
    if (!program) return program;

    const newProgram = { ...program };
    const jsonFields = ['content', 'economic_effects', 'related_links', 'opportunity_effects'];

    jsonFields.forEach(field => {
        if (newProgram[field] && typeof newProgram[field] === 'string') {
            try {
                newProgram[field] = JSON.parse(newProgram[field]);
            } catch (e) {
                console.error(`Error parsing JSON for field ${field} in program ${newProgram.id}:`, e);
                newProgram[field] = []; 
            }
        }
    });

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

router.get('/', async (req, res) => {
    try {
        const query = `
            SELECT p.*, COALESCE(sc.categories, '[]'::json) as solution_categories
            FROM esg_programs p
            LEFT JOIN (
                SELECT psc.program_id, json_agg(sc.category_name) as categories
                FROM program_solution_categories psc
                JOIN solution_categories sc ON psc.category_id = sc.id
                GROUP BY psc.program_id
            ) sc ON p.id = sc.program_id
            WHERE p.status = 'published'
            ORDER BY p.id ASC
        `;
        const { rows } = await db.query(query);
        const processedPrograms = rows.map(processProgramData);
        res.status(200).json({ success: true, programs: processedPrograms });
    } catch (error) {
        console.error("공개용 프로그램 목록 조회 에러:", error);
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});

router.get('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const query = `
            SELECT p.*, COALESCE(sc.categories, '[]'::json) as solution_categories
            FROM esg_programs p
            LEFT JOIN (
                SELECT psc.program_id, json_agg(sc.category_name) as categories
                FROM program_solution_categories psc
                JOIN solution_categories sc ON psc.category_id = sc.id
                GROUP BY psc.program_id
            ) sc ON p.id = sc.program_id
            WHERE p.id = $1 AND p.status = 'published'
        `;
        const { rows } = await db.query(query, [id]);
        if (rows.length === 0) {
            return res.status(404).json({ success: false, message: "프로그램을 찾을 수 없습니다." });
        }
        
        const program = processProgramData(rows[0]);
        res.status(200).json({ success: true, program: program });
    } catch (error) {
        console.error(`공개용 프로그램 상세 조회 에러 (ID: ${id}):`, error);
        res.status(500).json({ success: false, message: "서버 에러가 발생했습니다." });
    }
});

router.post('/batch-details', async (req, res) => {
    const { programIds } = req.body;
    if (!programIds || !Array.isArray(programIds) || programIds.length === 0) {
        return res.status(200).json({ success: true, programs: [] });
    }
    try {
        const query = `
            SELECT p.*, COALESCE(sc.categories, '[]'::json) as solution_categories
            FROM esg_programs p
            LEFT JOIN (
                SELECT psc.program_id, json_agg(sc.category_name) as categories
                FROM program_solution_categories psc
                JOIN solution_categories sc ON psc.category_id = sc.id
                GROUP BY psc.program_id
            ) sc ON p.id = sc.program_id
            WHERE p.id = ANY($1::int[])
        `;
        const { rows } = await db.query(query, [programIds]);

        const sortedRows = programIds.map(id => rows.find(row => row.id === id)).filter(Boolean);
        
        const processedPrograms = sortedRows.map(processProgramData);
        res.status(200).json({ success: true, programs: processedPrograms });

    } catch (error) {
        console.error("배치 상세 조회 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

module.exports = router;