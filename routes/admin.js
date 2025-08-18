// routes/admin.js
const express = require('express');
const { stringify } = require('csv-stringify/sync'); 
const { parse } = require('csv-parse/sync'); 
const stream = require('stream');  
const multer = require('multer'); 
const sharp = require('sharp'); 
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');
const checkPermission = require('../middleware/permissionMiddleware');
const { uploadImageToS3, uploadFileToS3, deleteImageFromS3 } = require('../helpers/s3-helper');
const router = express.Router();

const STATIC_BASE_URL = 'https://locallink-backend.onrender.com';


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
                        return `${STATIC_BASE_URL}/${path}`;
                    }
                    return path;
                });
            }
        });
    }
    
    newProgram.content = content;
    return newProgram;
};


const convertSiteContentImageUrls = (contentValue) => {
    if (!contentValue) {
        return contentValue;
    }
    const sections = (typeof contentValue === 'string') ? JSON.parse(contentValue) : contentValue;

    if (Array.isArray(sections)) {
        sections.forEach(section => {
            if (section.images && Array.isArray(section.images)) {
                section.images.forEach(imageObj => {
                    if (imageObj && imageObj.file && !imageObj.file.startsWith('http')) {
                        imageObj.file = `${process.env.STATIC_BASE_URL}/${imageObj.file}`;
                    }
                });
            }
        });
    }
    return sections;
};

const fs = require('fs'); 
const path = require('path');   


const processProgramData = (program) => {
    if (!program) return program;

    const newProgram = { ...program };
    const jsonFields = ['content', 'economic_effects', 'related_links', 'opportunity_effects'];

    jsonFields.forEach(field => {
        if (newProgram[field] && typeof newProgram[field] === 'string') {
            try {
                newProgram[field] = JSON.parse(newProgram[field]);
            } catch (e) {
                console.error(`Error parsing JSON for field ${field}:`, e);
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

const storage = multer.memoryStorage(); 
const upload = multer({ 
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 } 
});

const partnerStorage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'public/uploads/partners/'); 
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, 'partner-' + uniqueSuffix + path.extname(file.originalname));
    }
});
const uploadPartner = multer({ storage: partnerStorage, limits: { fileSize: 5 * 1024 * 1024 } });

router.get(
    '/users',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'user_manager']),
    async (req, res) => {
        try {
            const query = `
                SELECT 
                    u.id, u.email, u.company_name, u.manager_name, u.manager_phone, u.role, u.created_at,
                    u.used_referral_code,           -- 추천 코드
                    recommender.company_name AS recommending_organization_name, -- 추천 단체명
                    EXISTS (SELECT 1 FROM diagnoses WHERE user_id = u.id AND status = 'completed') as has_completed_diagnosis,
                    (
                        SELECT status FROM user_applications ua
                        WHERE ua.user_id = u.id
                        ORDER BY 
                            CASE status
                                WHEN '완료' THEN 1 
                                WHEN '진행' THEN 2 
                                WHEN '접수' THEN 3
                                ELSE 4
                            END
                        LIMIT 1
                    ) as highest_application_status
                FROM users u
                LEFT JOIN users recommender ON u.recommending_organization_id = recommender.id -- 추천 단체 정보 JOIN
                ORDER BY u.id DESC
            `;
            const { rows } = await db.query(query);

            const usersWithLevel = rows.map(user => {
                let level = 1;
                if (user.has_completed_diagnosis) level = 2;
                if (user.highest_application_status) {
                    level = 3;
                    if (user.highest_application_status === '진행') level = 4;
                    if (user.highest_application_status === '완료') level = 5;
                }
                return { ...user, level: level };
            });

            res.status(200).json({ success: true, users: usersWithLevel });

        } catch (error) {
            console.error("관리자용 사용자 목록 조회 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

router.put(
    '/users/:userId/role',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin']),
    async (req, res) => {
        const { userId } = req.params;
        const { role } = req.body;

        const allowedRoles = ['user', 'content_manager', 'user_manager', 'vice_super_admin', 'super_admin'];
        if (!role || !allowedRoles.includes(role)) {
            return res.status(400).json({ success: false, message: '유효하지 않은 역할입니다.' });
        }
        
        if (req.user.role === 'vice_super_admin') {
            if (role === 'super_admin') {
                return res.status(403).json({ success: false, message: 'super_admin으로 역할을 지정할 수 없습니다.' });
            }
            const { rows } = await db.query('SELECT role FROM users WHERE id = $1', [userId]);
            if (rows.length > 0 && rows[0].role === 'super_admin') {
                return res.status(403).json({ success: false, message: 'super_admin의 역할은 변경할 수 없습니다.' });
            }
        }

        try {
            const result = await db.query(
                'UPDATE users SET role = $1 WHERE id = $2 RETURNING id, role',
                [role, userId]
            );

            if (result.rows.length === 0) {
                return res.status(404).json({ success: false, message: '사용자를 찾을 수 없습니다.' });
            }
            res.status(200).json({ success: true, message: '사용자 역할이 성공적으로 변경되었습니다.' });
        } catch (error) {
            console.error('역할 변경 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.delete(
    '/users/:userId',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        const { userId: targetUserId } = req.params;
        const currentUserId = req.user.userId;

        if (parseInt(targetUserId, 10) === currentUserId) {
            return res.status(400).json({ success: false, message: '자기 자신을 삭제할 수 없습니다.' });
        }

        try {
            await db.query('DELETE FROM users WHERE id = $1', [targetUserId]);
            res.status(200).json({ success: true, message: '사용자가 성공적으로 삭제되었습니다.' });
        } catch (error) {
            console.error('사용자 삭제 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.get('/users/export', authMiddleware, checkPermission(['super_admin', 'vice_super_admin',  'user_manager']), async (req, res) => {
    try {
        const query = `
            SELECT 
                id as "ID",
                email as "이메일",
                company_name as "회사명",
                manager_name as "담당자명",
                manager_phone as "연락처",
                role as "권한",
                TO_CHAR(created_at, 'YYYY-MM-DD') as "가입일"
            FROM users 
            ORDER BY id DESC
        `;
        const { rows } = await db.query(query);

        if (rows.length === 0) {
            return res.status(404).send('내보낼 사용자 데이터가 없습니다.');
        }

        const csvString = stringify(rows, { header: true });

        res.setHeader('Content-Type', 'text/csv; charset=utf-8');
        res.setHeader('Content-Disposition', `attachment; filename="users-list-${new Date().toISOString().slice(0,10)}.csv"`);
        
        res.status(200).end('\uFEFF' + csvString);

    } catch (error) {
        console.error("사용자 목록 내보내기 에러:", error);
        res.status(500).send('Export 중 서버 에러 발생');
    }
});

router.get('/inquiries', authMiddleware, checkPermission(['super_admin','vice_super_admin', 'user_manager']), async (req, res) => {
    try {
        const { rows } = await db.query('SELECT * FROM inquiries ORDER BY created_at DESC');
        res.status(200).json({ success: true, inquiries: rows });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});


router.put('/inquiries/:id/status', authMiddleware, checkPermission(['super_admin', 'vice_super_admin',  'user_manager']), async (req, res) => {
    const { id } = req.params;
    const { status } = req.body; 

    const client = await db.pool.connect();
    try {
        await client.query('BEGIN');

        const updateQuery = 'UPDATE inquiries SET status = $1 WHERE id = $2 RETURNING user_id, inquiry_type';
        const result = await client.query(updateQuery, [status, id]);

        if (result.rows.length === 0) {
            throw new Error('문의를 찾을 수 없습니다.');
        }

        const inquiry = result.rows[0];
        const message = `문의하신 '[${inquiry.inquiry_type}]'의 처리 상태가 [${status}](으)로 변경되었습니다.`;
        const link_url = '/mypage_inquiry.html';
        
        await client.query(
            'INSERT INTO notifications (user_id, message, link_url) VALUES ($1, $2, $3)',
            [inquiry.user_id, message, link_url]
        );

        await client.query('COMMIT');
        res.status(200).json({ success: true, message: '상태가 성공적으로 변경되었습니다.' });

    } catch (error) {
        await client.query('ROLLBACK');
        console.error(`문의(ID: ${id}) 상태 변경 에러:`, error);
        res.status(500).json({ success: false, message: error.message || '서버 에러가 발생했습니다.' });
    } finally {
        client.release();
    }
});

router.delete('/inquiries/:id', authMiddleware, checkPermission(['super_admin']), async (req, res) => {
    const { id } = req.params;
    try {
        const { rowCount } = await db.query('DELETE FROM inquiries WHERE id = $1', [id]);
        if (rowCount === 0) return res.status(404).json({ success: false, message: '문의를 찾을 수 없습니다.' });
        res.status(200).json({ success: true, message: '문의가 삭제되었습니다.' });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});


router.get('/inquiries', authMiddleware, checkPermission(['super_admin', 'vice_super_admin', 'user_manager']), async (req, res) => {
    const { type } = req.query; 
    try {
        let query = 'SELECT * FROM inquiries';
        const values = [];
        if (type && type !== 'all') {
            query += ' WHERE inquiry_type = $1';
            values.push(type);
        }
        query += ' ORDER BY created_at DESC';
        const { rows } = await db.query(query, values);
        res.status(200).json({ success: true, inquiries: rows });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

router.get('/inquiries/export', authMiddleware, checkPermission(['super_admin', 'vice_super_admin', 'user_manager']), async (req, res) => {
    try {
        const { rows } = await db.query('SELECT * FROM inquiries ORDER BY created_at DESC');
        const csvString = stringify(rows, { header: true });
        res.setHeader('Content-Type', 'text/csv; charset=utf-8');
        res.setHeader('Content-Disposition', `attachment; filename="inquiries-${Date.now()}.csv"`);
        res.status(200).end('\uFEFF' + csvString);
    } catch (error) { res.status(500).send('Export 중 서버 에러 발생'); }
});


router.get(
    '/questions',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        try {
            const query = 'SELECT * FROM survey_questions ORDER BY display_order ASC';
            const { rows } = await db.query(query);
            res.status(200).json({ success: true, questions: rows });
        } catch (error) {
            console.error('관리자용 질문 목록 조회 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

router.get(
    '/questions/:id',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        try {
            const { id } = req.params;
            const query = 'SELECT * FROM survey_questions WHERE id = $1';
            const { rows } = await db.query(query, [id]);

            if (rows.length === 0) {
                return res.status(404).json({ success: false, message: '해당 질문을 찾을 수 없습니다.' });
            }
            res.status(200).json({ success: true, question: rows[0] });
        } catch (error) {
            console.error('관리자용 특정 질문 조회 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.put(
    '/questions/:id',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        const { id } = req.params;
        const { 
            display_order, question_text, explanation, options, 
            next_question_default, next_question_if_yes, next_question_if_no, 
            benchmark_metric, diagnosis_type, scoring_method // ★★★ scoring_method 추가
        } = req.body;
        try {
            const query = `
                UPDATE survey_questions 
                SET display_order = $1, question_text = $2, explanation = $3, options = $4,
                    next_question_default = $5, next_question_if_yes = $6, next_question_if_no = $7,
                    benchmark_metric = $8, diagnosis_type = $9, scoring_method = $10
                WHERE id = $11 RETURNING *;
            `;
            const values = [
                display_order, question_text, explanation, JSON.stringify(options),
                next_question_default, next_question_if_yes, next_question_if_no,
                benchmark_metric, diagnosis_type, scoring_method,
                id
            ];
            const { rows } = await db.query(query, values);
            if (rows.length === 0) {
                return res.status(404).json({ success: false, message: '질문을 찾을 수 없습니다.' });
            }
            res.status(200).json({ success: true, message: '질문이 성공적으로 수정되었습니다.' });
        } catch (error) {
            console.error('질문 수정 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.get(
    '/scoring-rules',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin' ]),
    async (req, res) => {
        const { type } = req.query;
        try {
            let query = `
                SELECT 
                    r.id, 
                    r.question_code, 
                    q.question_text, 
                    r.answer_condition, 
                    r.score, 
                    r.esg_category 
                FROM scoring_rules r
                JOIN survey_questions q ON r.question_code = q.question_code
            `;
            const values = [];

            if (type) {
                query += ' WHERE q.diagnosis_type = $1';
                values.push(type);
            }
            query += ' ORDER BY q.display_order ASC, r.id ASC';
            
            const { rows } = await db.query(query, values);
            res.status(200).json({ success: true, rules: rows });
        } catch (error) {
            console.error("채점 규칙 조회 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

router.put(
    '/scoring-rules/:id',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        const { id } = req.params;
        const { score } = req.body;

        if (score === undefined || isNaN(parseFloat(score))) {
            return res.status(400).json({ success: false, message: '유효한 점수를 입력해주세요.' });
        }

        try {
            const query = 'UPDATE scoring_rules SET score = $1 WHERE id = $2 RETURNING id';
            const { rows } = await db.query(query, [score, id]);

            if (rows.length === 0) {
                return res.status(404).json({ success: false, message: '해당 규칙을 찾을 수 없습니다.' });
            }
            res.status(200).json({ success: true, message: '채점 규칙이 성공적으로 업데이트되었습니다.' });
        } catch (error) {
            console.error('채점 규칙 수정 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

router.delete(
    '/questions/:id',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        try {
            const { id } = req.params;
            await db.query('DELETE FROM diagnosis_answers WHERE question_code = (SELECT question_code FROM survey_questions WHERE id = $1)', [id]);
            await db.query('DELETE FROM scoring_rules WHERE question_code = (SELECT question_code FROM survey_questions WHERE id = $1)', [id]);
            
            const { rowCount } = await db.query('DELETE FROM survey_questions WHERE id = $1', [id]);

            if (rowCount === 0) {
                return res.status(404).json({ success: false, message: '삭제할 질문을 찾을 수 없습니다.' });
            }
            res.status(200).json({ success: true, message: '질문이 성공적으로 삭제되었습니다.' });

        } catch (error) {
            console.error('질문 삭제 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

router.post(
    '/questions',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin']),
    async (req, res) => {
        const { 
            question_code, esg_category, question_text, question_type, 
            options, explanation, display_order, 
            next_question_default, next_question_if_yes, next_question_if_no, 
            benchmark_metric, diagnosis_type, scoring_method 
        } = req.body;

        const client = await db.pool.connect();
        try {
            await client.query('BEGIN');

            const questionQuery = `
                INSERT INTO survey_questions (
                    question_code, esg_category, question_text, question_type, 
                    options, explanation, display_order, 
                    next_question_default, next_question_if_yes, next_question_if_no, 
                    benchmark_metric, diagnosis_type, scoring_method
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13);
            `;
            const questionValues = [
                question_code, esg_category, question_text, question_type, 
                JSON.stringify(options), explanation, display_order, 
                next_question_default, next_question_if_yes, next_question_if_no, 
                benchmark_metric, diagnosis_type, scoring_method
            ];
            await client.query(questionQuery, questionValues);

            if (scoring_method === 'benchmark_comparison' && benchmark_metric) {
                const ruleQuery = `INSERT INTO scoring_rules (question_code, answer_condition, score, esg_category) VALUES ($1, $2, $3, $4);`;
                const benchmarkCommand = `BENCHMARK_${benchmark_metric.replace('_avg', '').toUpperCase()}`;
                await client.query(ruleQuery, [question_code, '*', benchmarkCommand, esg_category]);
            } else { 
                if (options && options.length > 0) {
                    for (const option of options) {
                        if (option.value) {
                            const ruleQuery = `INSERT INTO scoring_rules (question_code, answer_condition, score, esg_category) VALUES ($1, $2, $3, $4);`;
                            await client.query(ruleQuery, [question_code, option.value, 0, esg_category]);
                        }
                    }
                }
            }

            await client.query('COMMIT');
            res.status(201).json({ success: true, message: '새로운 질문과 기본 채점 규칙이 성공적으로 생성되었습니다.' });
        } catch (error) {
            await client.query('ROLLBACK');
            console.error('질문 생성 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        } finally {
            client.release();
        }
    }
);

router.post(
    '/questions/reorder',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        const { questionId, direction } = req.body;

        const client = await db.pool.connect();
        try {
            await client.query('BEGIN');

            const currentQRes = await client.query('SELECT display_order FROM survey_questions WHERE id = $1', [questionId]);
            if (currentQRes.rows.length === 0) throw new Error('해당 질문을 찾을 수 없습니다.');
            const currentOrder = currentQRes.rows[0].display_order;

            let otherQRes;
            if (direction === 'up') {
                otherQRes = await client.query('SELECT id, display_order FROM survey_questions WHERE display_order < $1 ORDER BY display_order DESC LIMIT 1', [currentOrder]);
            } else { 
                otherQRes = await client.query('SELECT id, display_order FROM survey_questions WHERE display_order > $1 ORDER BY display_order ASC LIMIT 1', [currentOrder]);
            }
            
            if (otherQRes.rows.length > 0) {
                const otherQuestion = otherQRes.rows[0];
                
                await client.query('UPDATE survey_questions SET display_order = $1 WHERE id = $2', [otherQuestion.display_order, questionId]);
                await client.query('UPDATE survey_questions SET display_order = $1 WHERE id = $2', [currentOrder, otherQuestion.id]);
            }
            
            await client.query('COMMIT');
            res.status(200).json({ success: true, message: '순서가 변경되었습니다.' });

        } catch (error) {
            await client.query('ROLLBACK');
            console.error('질문 순서 변경 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러' });
        } finally {
            client.release();
        }
    }
);

router.get(
    '/average-metrics',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        try {
            const query = `
                SELECT column_name 
                FROM information_schema.columns
                WHERE table_name = 'industry_averages' 
                  AND column_name LIKE '%_avg';
            `;
            const { rows } = await db.query(query);
            const metrics = rows.map(row => row.column_name);
            res.status(200).json({ success: true, metrics: metrics });
        } catch (error) {
            console.error('벤치마크 지표 목록 조회 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.get(
    '/industry-averages',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        try {
            const query = 'SELECT * FROM industry_averages ORDER BY industry_code ASC';
            const { rows } = await db.query(query);
            res.status(200).json({ success: true, averages: rows });
        } catch (error) {
            console.error('관리자용 산업 평균 조회 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.put(
    '/industry-averages/:id',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        const { id } = req.params;
        const { 
            ghg_emissions_avg, energy_usage_avg, waste_generation_avg,
            non_regular_ratio_avg, disability_employment_ratio_avg, female_employee_ratio_avg,
            years_of_service_avg, outside_director_ratio_avg, board_meetings_avg,
            executive_compensation_ratio_avg, donation_ratio_avg, quality_mgmt_ratio_avg,
            cumulative_voting_ratio_avg, dividend_policy_ratio_avg, legal_violation_ratio_avg
        } = req.body;

        try {
            const query = `
                UPDATE industry_averages SET
                    ghg_emissions_avg = $1, energy_usage_avg = $2, waste_generation_avg = $3,
                    non_regular_ratio_avg = $4, disability_employment_ratio_avg = $5, female_employee_ratio_avg = $6,
                    years_of_service_avg = $7, outside_director_ratio_avg = $8, board_meetings_avg = $9,
                    executive_compensation_ratio_avg = $10, donation_ratio_avg = $11, quality_mgmt_ratio_avg = $12,
                    cumulative_voting_ratio_avg = $13, dividend_policy_ratio_avg = $14, legal_violation_ratio_avg = $15
                WHERE id = $16 RETURNING id;
            `;
            const values = [
                ghg_emissions_avg, energy_usage_avg, waste_generation_avg,
                non_regular_ratio_avg, disability_employment_ratio_avg, female_employee_ratio_avg,
                years_of_service_avg, outside_director_ratio_avg, board_meetings_avg,
                executive_compensation_ratio_avg, donation_ratio_avg, quality_mgmt_ratio_avg,
                cumulative_voting_ratio_avg, dividend_policy_ratio_avg, legal_violation_ratio_avg,
                id
            ];
            
            const { rows } = await db.query(query, values);
            if (rows.length === 0) {
                return res.status(404).json({ success: false, message: '해당 산업 데이터를 찾을 수 없습니다.' });
            }
            res.status(200).json({ success: true, message: '산업 평균 데이터가 성공적으로 업데이트되었습니다.' });

        } catch (error) {
            console.error('산업 평균 데이터 수정 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);


router.get(
    '/benchmark-rules',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        try {
            const query = 'SELECT * FROM benchmark_scoring_rules ORDER BY metric_name, upper_bound ASC';
            const { rows } = await db.query(query);
            res.status(200).json({ success: true, rules: rows });
        } catch (error) {
            console.error('관리자용 벤치마크 규칙 조회 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.put(
    '/benchmark-rules/:id',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin']),
    async (req, res) => {
        const { id } = req.params;
        const { score, upper_bound, description } = req.body;

        if (score === undefined || upper_bound === undefined) {
            return res.status(400).json({ success: false, message: '점수와 상한값은 필수 항목입니다.' });
        }

        try {
            const query = `
                UPDATE benchmark_scoring_rules 
                SET score = $1, upper_bound = $2, description = $3
                WHERE id = $4 RETURNING id;
            `;
            const values = [score, upper_bound, description, id];
            const { rows } = await db.query(query, values);

            if (rows.length === 0) {
                return res.status(404).json({ success: false, message: '해당 규칙을 찾을 수 없습니다.' });
            }
            res.status(200).json({ success: true, message: '벤치마크 채점 규칙이 성공적으로 업데이트되었습니다.' });
        } catch (error) {
            console.error('벤치마크 채점 규칙 수정 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.get('/programs', authMiddleware, checkPermission(['super_admin', 'vice_super_admin', 'content_manager']), async (req, res) => {
    try {
        const { userId, role } = req.user; 

        let query = 'SELECT * FROM esg_programs';
        const values = [];

        if (role === 'content_manager') {
            query += ' WHERE author_id = $1';
            values.push(userId);
        }

        query += ' ORDER BY id ASC';
        
        const { rows } = await db.query(query, values);
        
        const processedPrograms = rows.map(processProgramData);
        
        res.status(200).json({ success: true, programs: processedPrograms });
    } catch (error) {
        console.error('관리자용 프로그램 목록 조회 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});


router.post(
    '/programs',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    upload.any(),
    async (req, res) => {
        const client = await db.pool.connect();
        try {
            await client.query('BEGIN');
            const { content, ...otherBodyFields } = req.body;
            const { userId, role } = req.user;

            const authorId = (['super_admin', 'vice_super_admin'].includes(role) && otherBodyFields.author_id) ? otherBodyFields.author_id : userId;
            const isAdminRecommended = otherBodyFields.is_admin_recommended === 'true' || otherBodyFields.is_admin_recommended === true;

            const parsedContent = JSON.parse(content);
            const finalContent = await Promise.all(parsedContent.map(async (section) => {
                if (!section.images || section.images.length === 0) return section;
                const updatedImages = await Promise.all(section.images.map(async (placeholder) => {
                    const file = req.files.find(f => f.fieldname === placeholder);
                    if (file) {
                        return await uploadImageToS3(file.buffer, file.originalname, 'programs', userId);
                    }
                    return null;
                }));
                return { ...section, images: updatedImages.filter(Boolean) };
            }));
            
            const programQuery = `
                INSERT INTO esg_programs (
                    title, program_code, esg_category, program_overview, content, 
                    economic_effects, related_links, risk_text, risk_description, 
                    opportunity_effects, service_regions, execution_type, status,
                    potential_e, potential_s, potential_g,
                    existing_cost_details, service_costs,
                    is_admin_recommended, author_id 
                ) 
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, 'draft', $13, $14, $15, $16, $17, $18, $19) RETURNING id;
            `;
            const programValues = [
                otherBodyFields.title, otherBodyFields.program_code, otherBodyFields.esg_category, otherBodyFields.program_overview,
                JSON.stringify(finalContent), otherBodyFields.economic_effects, otherBodyFields.related_links,
                otherBodyFields.risk_text, otherBodyFields.risk_description, otherBodyFields.opportunity_effects,
                otherBodyFields.service_regions.split(','), otherBodyFields.execution_type,
                otherBodyFields.potential_e || 0, otherBodyFields.potential_s || 0, otherBodyFields.potential_g || 0,
                otherBodyFields.existing_cost_details || null, 
                otherBodyFields.service_costs || '[]',
                isAdminRecommended,
                authorId
            ];
            
            const programResult = await client.query(programQuery, programValues);
            const newProgramId = programResult.rows[0].id;

            const solutionCategories = otherBodyFields.solution_categories ? otherBodyFields.solution_categories.split(',') : [];
            if (solutionCategories.length > 0) {
                const categoryRes = await client.query('SELECT id, category_name FROM solution_categories WHERE category_name = ANY($1::text[])', [solutionCategories]);
                const categoryMap = new Map(categoryRes.rows.map(row => [row.category_name, row.id]));
                for (const categoryName of solutionCategories) {
                    const categoryId = categoryMap.get(categoryName);
                    if (categoryId) {
                        await client.query('INSERT INTO program_solution_categories (program_id, category_id) VALUES ($1, $2)', [newProgramId, categoryId]);
                    }
                }
            }

            await client.query('COMMIT');
            res.status(201).json({ success: true, message: '프로그램이 성공적으로 생성되었습니다.' });

        } catch (error) {
            await client.query('ROLLBACK');
            console.error('프로그램 생성 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        } finally {
            client.release();
        }
    }
);

router.put(
    '/programs/:id',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    upload.any(),
    async (req, res) => {
        const { id } = req.params;
        const { userId, role } = req.user; 
        const client = await db.pool.connect();

        try {
            await client.query('BEGIN');

            const programRes = await client.query('SELECT author_id FROM esg_programs WHERE id = $1', [id]);
            if (programRes.rows.length === 0) {
                return res.status(404).json({ success: false, message: '프로그램을 찾을 수 없습니다.' });
            }
            const programAuthorId = programRes.rows[0].author_id;

            if (role === 'content_manager' && programAuthorId !== userId) {
                return res.status(403).json({ success: false, message: '이 프로그램을 수정할 권한이 없습니다.' });
            }

            const oldProgramRes = await client.query('SELECT content FROM esg_programs WHERE id = $1', [id]);
            const oldImageUrls = new Set();
            if (oldProgramRes.rows[0]?.content) {
                const oldContent = Array.isArray(oldProgramRes.rows[0].content) ? oldProgramRes.rows[0].content : JSON.parse(oldProgramRes.rows[0].content);
                oldContent.forEach(section => {
                    if (section.images) section.images.forEach(imgUrl => oldImageUrls.add(imgUrl));
                });
            }
            
            const { content, ...otherBodyFields } = req.body;
            const parsedContent = JSON.parse(content);

            const finalContent = await Promise.all(parsedContent.map(async (section) => {
                if (!section.images || section.images.length === 0) return section;
                const updatedImages = await Promise.all(section.images.map(async (imageOrPlaceholder) => {
                    if (typeof imageOrPlaceholder === 'string' && imageOrPlaceholder.startsWith('http')) {
                        return imageOrPlaceholder;
                    }
                    const file = req.files.find(f => f.fieldname === imageOrPlaceholder);
                    if (file) {
                        return await uploadImageToS3(file.buffer, file.originalname, 'programs', userId);
                    }
                    return imageOrPlaceholder;
                }));
                return { ...section, images: updatedImages.filter(Boolean) };
            }));

            const finalImageUrls = new Set();
            finalContent.forEach(section => {
                if (section.images) section.images.forEach(imgUrl => finalImageUrls.add(imgUrl));
            });
            const imagesToDelete = [...oldImageUrls].filter(url => !finalImageUrls.has(url));
            if (imagesToDelete.length > 0) {
                await Promise.all(imagesToDelete.map(url => deleteImageFromS3(url)));
            }

            const programValues = [
                otherBodyFields.title, otherBodyFields.program_code, otherBodyFields.esg_category, otherBodyFields.program_overview,
                JSON.stringify(finalContent), otherBodyFields.economic_effects, otherBodyFields.related_links,
                otherBodyFields.risk_text, otherBodyFields.risk_description, otherBodyFields.opportunity_effects,
                otherBodyFields.service_regions.split(','), otherBodyFields.execution_type,
                otherBodyFields.potential_e || 0, otherBodyFields.potential_s || 0, otherBodyFields.potential_g || 0,
                otherBodyFields.existing_cost_details || null, 
                otherBodyFields.service_costs || '[]',
                otherBodyFields.is_admin_recommended || false
            ];

            let querySetParts = [
                'title = $1', 'program_code = $2', 'esg_category = $3', 'program_overview = $4', 'content = $5',
                'economic_effects = $6', 'related_links = $7', 'risk_text = $8', 'risk_description = $9',
                'opportunity_effects = $10', 'service_regions = $11', 'execution_type = $12',
                'potential_e = $13', 'potential_s = $14', 'potential_g = $15',
                'existing_cost_details = $16', 'service_costs = $17', 'is_admin_recommended = $18', 'updated_at = NOW()'
            ];

            if ((role === 'super_admin' || role === 'vice_super_admin') && otherBodyFields.author_id) {
                programValues.push(otherBodyFields.author_id);
                querySetParts.push(`author_id = $${programValues.length}`);
            }

            programValues.push(id);
            const finalQuery = `UPDATE esg_programs SET ${querySetParts.join(', ')} WHERE id = $${programValues.length}`;
            
            await client.query(finalQuery, programValues);
            
            const solutionCategories = otherBodyFields.solution_categories ? otherBodyFields.solution_categories.split(',') : [];
            await client.query('DELETE FROM program_solution_categories WHERE program_id = $1', [id]);
            if (solutionCategories.length > 0) {
                const categoryRes = await client.query('SELECT id, category_name FROM solution_categories WHERE category_name = ANY($1::text[])', [solutionCategories]);
                const categoryMap = new Map(categoryRes.rows.map(row => [row.category_name, row.id]));
                for (const categoryName of solutionCategories) {
                    const categoryId = categoryMap.get(categoryName);
                    if (categoryId) {
                        await client.query('INSERT INTO program_solution_categories (program_id, category_id) VALUES ($1, $2)', [id, categoryId]);
                    }
                }
            }

            await client.query('COMMIT');
            res.status(200).json({ success: true, message: '프로그램이 성공적으로 수정되었습니다.' });

        } catch (error) {
            await client.query('ROLLBACK');
            console.error(`[CRITICAL] 프로그램(ID: ${id}) 수정 에러:`, error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        } finally {
            client.release();
        }
    }
);

router.delete(
    '/programs/:id',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        const { id } = req.params;
        const client = await db.pool.connect();
        try {
            await client.query('BEGIN');

            const programRes = await client.query('SELECT content FROM esg_programs WHERE id = $1', [id]);
            if (programRes.rows.length > 0 && programRes.rows[0].content) {
                const content = programRes.rows[0].content;
                const imagesToDelete = [];
                content.forEach(section => {
                    if (section.images && Array.isArray(section.images)) {
                        section.images.forEach(imageUrl => {
                            if (typeof imageUrl === 'string' && imageUrl.startsWith('http')) {
                                imagesToDelete.push(imageUrl);
                            }
                        });
                    }
                });
                
                if (imagesToDelete.length > 0) {
                    await Promise.all(imagesToDelete.map(url => deleteImageFromS3(url)));
                }
            }
            
            const programCodeRes = await client.query('SELECT program_code FROM esg_programs WHERE id = $1', [id]);
            if (programCodeRes.rows.length > 0) {
                await client.query('DELETE FROM strategy_rules WHERE recommended_program_code = $1', [programCodeRes.rows[0].program_code]);
            }
            await client.query('DELETE FROM user_applications WHERE program_id = $1', [id]); // 신청 내역도 함께 삭제
            const { rowCount } = await client.query('DELETE FROM esg_programs WHERE id = $1', [id]);
            if (rowCount === 0) return res.status(404).json({ success: false, message: '프로그램을 찾을 수 없습니다.' });

            await client.query('COMMIT');
            res.status(200).json({ success: true, message: '프로그램이 성공적으로 삭제되었습니다.' });
        } catch (error) {
            await client.query('ROLLBACK');
            console.error(`[CRITICAL] 프로그램(ID: ${id}) 수정 에러:`, error); 
            
            res.status(500).json({ 
                success: false, 
                message: error.message || '서버 에러가 발생했습니다.' 
            });
        } finally {
            client.release();
        }
    }
);

router.get('/programs/:id', authMiddleware, checkPermission(['super_admin', 'vice_super_admin', 'content_manager']), async (req, res) => {
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
            WHERE p.id = $1
        `;
        const { rows } = await db.query(query, [id]);
        
        if (rows.length === 0) {
            return res.status(404).json({ success: false, message: '해당 프로그램을 찾을 수 없습니다.' });
        }
        
        const processedProgram = processProgramData(rows[0]);
        res.status(200).json({ success: true, program: processedProgram });

    } catch (error) {
        console.error('프로그램 상세 조회 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

router.patch('/programs/:id/status', authMiddleware, checkPermission(['super_admin']), async (req, res) => {
    const { id } = req.params;
    const { status } = req.body; 

    if (!status) {
        return res.status(400).json({ success: false, message: '상태 값이 필요합니다.' });
    }

    try {
        const query = 'UPDATE esg_programs SET status = $1 WHERE id = $2 RETURNING id, status;';
        const { rows } = await db.query(query, [status, id]);

        if (rows.length === 0) {
            return res.status(404).json({ success: false, message: '프로그램을 찾을 수 없습니다.' });
        }

        res.status(200).json({ 
            success: true, 
            message: `프로그램 상태가 '${rows[0].status}'(으)로 변경되었습니다.`,
            updatedProgram: rows[0]
        });
    } catch (error) {
        console.error('프로그램 상태 변경 중 오류:', error);
        res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
});

router.post(
    '/upload-program-images',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin',  'content_manager']),
    upload.array('programImages', 10), 
    async (req, res) => {
        if (!req.files || req.files.length === 0) {
            return res.status(400).json({ success: false, message: '업로드된 파일이 없습니다.' });
        }
        try {
            const imageUrls = await Promise.all(
                req.files.map(file => 
                    uploadImageToS3(file.buffer, file.originalname, 'programs', req.user.userId)
                )
            );
            
            res.status(200).json({ 
                success: true, 
                message: "이미지가 성공적으로 업로드되었습니다.", 
                imageUrls: imageUrls 
            });

        } catch (error) {
            console.error('프로그램 이미지 업로드 에러:', error);
            res.status(500).json({ success: false, message: '이미지 처리 중 서버 에러 발생' });
        }
    }
);

router.post(
    '/benchmark-rules',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin']),
    async (req, res) => {
        const { metric_name, description, upper_bound, score, is_inverted, comparison_type } = req.body;
        try {
            const query = 'INSERT INTO benchmark_scoring_rules (metric_name, description, upper_bound, score, is_inverted, comparison_type) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id';
            const values = [metric_name, description, upper_bound, score, is_inverted, comparison_type];
            await db.query(query, values);
            res.status(201).json({ success: true, message: '새로운 벤치마크 규칙이 추가되었습니다.' });
        } catch (error) {
            console.error('벤치마크 규칙 추가 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

router.delete(
    '/benchmark-rules/:id',
    authMiddleware,
    checkPermission(['super_admin',]),
    async (req, res) => {
        const { id } = req.params;
        try {
            const { rowCount } = await db.query('DELETE FROM benchmark_scoring_rules WHERE id = $1', [id]);
            if (rowCount === 0) {
                return res.status(404).json({ success: false, message: '규칙을 찾을 수 없습니다.' });
            }
            res.status(200).json({ success: true, message: '벤치마크 규칙이 삭제되었습니다.' });
        } catch (error) {
            console.error('벤치마크 규칙 삭제 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

router.get(
    '/strategy-rules',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', ]),
    async (req, res) => {
        try {
            const query = `
                SELECT 
                    sr.id, 
                    sr.description, 
                    sr.conditions, 
                    sr.recommended_program_code, 
                    sr.priority,
                    p.title as program_title
                FROM 
                    strategy_rules sr
                LEFT JOIN 
                    esg_programs p ON sr.recommended_program_code = p.program_code
                ORDER BY 
                    sr.priority DESC, sr.id ASC;
            `;
            const { rows } = await db.query(query);
            res.status(200).json({ success: true, rules: rows });
        } catch (error) {
            console.error("전략 규칙 조회 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.post(
    '/strategy-rules',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', ]),
    async (req, res) => {
        const { description, conditions, recommended_program_code, priority } = req.body;
        try {
            const query = 'INSERT INTO strategy_rules (description, conditions, recommended_program_code, priority) VALUES ($1, $2, $3, $4) RETURNING id';
            const values = [description, JSON.stringify(conditions), recommended_program_code, priority];
            await db.query(query, values);
            res.status(201).json({ success: true, message: '새로운 전략 규칙이 추가되었습니다.' });
        } catch (error) {
            console.error("전략 규칙 추가 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

router.put(
    '/strategy-rules/:id',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', ]),
    async (req, res) => {
        const { id } = req.params;
        const { description, conditions, recommended_program_code, priority } = req.body;
        try {
            const query = 'UPDATE strategy_rules SET description = $1, conditions = $2, recommended_program_code = $3, priority = $4 WHERE id = $5 RETURNING id';
            const values = [description, JSON.stringify(conditions), recommended_program_code, priority, id];
            const { rowCount } = await db.query(query, values);
            if(rowCount === 0) return res.status(404).json({ success: false, message: '규칙을 찾을 수 없습니다.' });
            res.status(200).json({ success: true, message: '전략 규칙이 수정되었습니다.' });
        } catch (error) {
            console.error("전략 규칙 수정 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.delete(
    '/strategy-rules/:id',
    authMiddleware,
    checkPermission(['super_admin', '']),
    async (req, res) => {
        const { id } = req.params;
        try {
            const { rowCount } = await db.query('DELETE FROM strategy_rules WHERE id = $1', [id]);
            if (rowCount === 0) return res.status(404).json({ success: false, message: '규칙을 찾을 수 없습니다.' });
            res.status(200).json({ success: true, message: '전략 규칙이 삭제되었습니다.' });
        } catch (error) {
            console.error("전략 규칙 삭제 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.get('/industry-issues', authMiddleware, checkPermission(['super_admin','vice_super_admin', ]), async (req, res) => {
    try {
        const query = `
            SELECT i.id, i.industry_code, ind.name as industry_name, i.key_issue, i.opportunity, i.threat, i.linked_metric, i.notes
            FROM industry_esg_issues i
            JOIN industries ind ON i.industry_code = ind.code
            ORDER BY i.industry_code;
        `;
        const { rows } = await db.query(query);
        res.status(200).json({ success: true, issues: rows });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

router.post('/industry-issues', authMiddleware, checkPermission(['super_admin', 'vice_super_admin', ]), async (req, res) => {
    const { industry_code, key_issue, opportunity, threat, linked_metric, notes } = req.body;
    try {
        const query = 'INSERT INTO industry_esg_issues (industry_code, key_issue, opportunity, threat, linked_metric, notes) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id';
        const values = [industry_code, key_issue, opportunity, threat, linked_metric, notes];
        await db.query(query, values);
        res.status(201).json({ success: true, message: '새로운 산업별 이슈가 추가되었습니다.' });
    } catch (error) {
        if (error.code === '23505') { return res.status(409).json({ success: false, message: '해당 산업에 대한 항목이 이미 존재합니다.' }); }
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

router.put('/industry-issues/:id', authMiddleware, checkPermission(['super_admin', 'vice_super_admin', ]), async (req, res) => {
    const { id } = req.params;
    const { key_issue, opportunity, threat, linked_metric, notes } = req.body;
    try {
        const query = 'UPDATE industry_esg_issues SET key_issue = $1, opportunity = $2, threat = $3, linked_metric = $4, notes = $5, updated_at = NOW() WHERE id = $6 RETURNING id';
        const values = [key_issue, opportunity, threat, linked_metric, notes, id];
        const { rowCount } = await db.query(query, values);
        if (rowCount === 0) return res.status(404).json({ success: false, message: '해당 항목을 찾을 수 없습니다.' });
        res.status(200).json({ success: true, message: '산업별 이슈가 수정되었습니다.' });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

router.delete('/industry-issues/:id', authMiddleware, checkPermission(['super_admin', ]), async (req, res) => {
    const { id } = req.params;
    try {
        const { rowCount } = await db.query('DELETE FROM industry_esg_issues WHERE id = $1', [id]);
        if (rowCount === 0) return res.status(404).json({ success: false, message: '해당 항목을 찾을 수 없습니다.' });
        res.status(200).json({ success: true, message: '산업별 이슈가 삭제되었습니다.' });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

router.get(
    '/industry-issues/export',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', ]),
    async (req, res) => {
        try {
            const { rows } = await db.query('SELECT id, industry_code, key_issue, opportunity, threat, linked_metric, notes FROM industry_esg_issues ORDER BY id ASC');
            
            const columns = ['id', 'industry_code', 'key_issue', 'opportunity', 'threat', 'linked_metric', 'notes'];
            const csvString = stringify(rows, { header: true, columns: columns });

            res.setHeader('Content-Type', 'text/csv; charset=utf-8');
            res.setHeader('Content-Disposition', `attachment; filename="industry-issues-${Date.now()}.csv"`);
            
            const csvWithBom = '\uFEFF' + csvString;
            res.status(200).end(csvWithBom);

        } catch (error) {
            console.error("데이터 Export 에러:", error);
            res.status(500).send('Export 중 서버 에러 발생');
        }
    }
);

router.post(
    '/industry-issues/import',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', ]),
    upload.single('csvFile'), 
    async (req, res) => {
        if (!req.file) {
            return res.status(400).json({ success: false, message: '업로드된 파일이 없습니다.' });
        }

        const client = await db.pool.connect();
        try {
            const records = parse(req.file.buffer, {
                columns: true,
                skip_empty_lines: true
            });

            if (records.length === 0) {
                return res.status(400).json({ success: false, message: 'CSV 파일이 비어있거나 읽을 수 있는 데이터가 없습니다.' });
            }

            await client.query('BEGIN');
            
            let updatedCount = 0;
            for (const record of records) {
                const { industry_code, key_issue, opportunity, threat, linked_metric, notes } = record;
                if (!industry_code) continue;

                const query = `
                    UPDATE industry_esg_issues SET 
                        key_issue = $1, 
                        opportunity = $2, 
                        threat = $3, 
                        linked_metric = $4, 
                        notes = $5,
                        updated_at = NOW()
                    WHERE industry_code = $6;
                `;
                const result = await client.query(query, [key_issue, opportunity, threat, linked_metric, notes, industry_code]);
                
                if (result.rowCount > 0) {
                    updatedCount++;
                }
                console.log(`[Import] industry_code: ${industry_code} 처리 중... 업데이트된 행: ${result.rowCount}`);
            }

            await client.query('COMMIT');
            res.status(200).json({ success: true, message: `${updatedCount}개의 행이 성공적으로 업데이트되었습니다.` });

        } catch (error) {
            await client.query('ROLLBACK');
            console.error("데이터 Import 에러:", error);
            res.status(500).json({ success: false, message: 'Import 중 서버 에러 발생' });
        } finally {
            client.release();
        }
    }
);

router.get('/company-size-issues', authMiddleware, async (req, res) => {
    try {
        const { rows } = await db.query('SELECT * FROM company_size_esg_issues');
        res.status(200).json({ success: true, issues: rows });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

router.put('/company-size-issues', authMiddleware, checkPermission(['super_admin', 'vice_super_admin']), async (req, res) => {
    const { issues } = req.body;
    const client = await db.pool.connect();
    try {
        await client.query('BEGIN');
        for (const issue of issues) {
            const query = `
                UPDATE company_size_esg_issues 
                SET key_issue = $1, opportunity = $2, threat = $3, updated_at = NOW()
                WHERE company_size = $4`;
            await client.query(query, [issue.key_issue, issue.opportunity, issue.threat, issue.company_size]);
        }
        await client.query('COMMIT');
        res.status(200).json({ success: true, message: '성공적으로 저장되었습니다.' });
    } catch (error) {
        await client.query('ROLLBACK');
        res.status(500).json({ success: false, message: '서버 에러' });
    } finally {
        client.release();
    }
});

router.get('/regional-issues', authMiddleware, checkPermission(['super_admin', 'vice_super_admin']), async (req, res) => {
    try {
        const query = 'SELECT * FROM regional_esg_issues ORDER BY display_order ASC';
        const { rows } = await db.query(query);
        res.status(200).json({ success: true, issues: rows });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

router.post('/regional-issues', authMiddleware, checkPermission(['super_admin', 'vice_super_admin']), async (req, res) => {
    const { region, esg_category, content } = req.body;
    try {
        const query = 'INSERT INTO regional_esg_issues (region, esg_category, content) VALUES ($1, $2, $3) RETURNING id';
        const values = [region, esg_category, content];
        await db.query(query, values);
        res.status(201).json({ success: true, message: '새로운 지역별 이슈가 추가되었습니다.' });
    } catch (error) {
            console.error("지역별 이슈 추가 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
});

router.put('/regional-issues/:id', authMiddleware, checkPermission(['super_admin']), async (req, res) => {
    const { id } = req.params;
    const { region, esg_category, content } = req.body;
    try {
        const query = 'UPDATE regional_esg_issues SET region = $1, esg_category = $2, content = $3, updated_at = NOW() WHERE id = $4 RETURNING id';
        const values = [region, esg_category, content, id];
        const { rowCount } = await db.query(query, values);
        if (rowCount === 0) return res.status(404).json({ success: false, message: '해당 항목을 찾을 수 없습니다.' });
        res.status(200).json({ success: true, message: '지역별 이슈가 수정되었습니다.' });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

router.delete(
    '/regional-issues/:id',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        const { id } = req.params;
        try {
            const { rowCount } = await db.query('DELETE FROM regional_esg_issues WHERE id = $1', [id]);
            if (rowCount === 0) return res.status(404).json({ success: false, message: '해당 항목을 찾을 수 없습니다.' });
            res.status(200).json({ success: true, message: '지역별 이슈가 삭제되었습니다.' });
        } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
    }
);

router.post(
    '/regional-issues/reorder',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        const { issueId, direction } = req.body;
        const client = await db.pool.connect();
        try {
            await client.query('BEGIN');

            const currentRes = await client.query('SELECT display_order FROM regional_esg_issues WHERE id = $1', [issueId]);
            const currentOrder = currentRes.rows[0].display_order;

            let otherRes;
            if (direction === 'up') {
                otherRes = await client.query('SELECT id, display_order FROM regional_esg_issues WHERE display_order < $1 ORDER BY display_order DESC LIMIT 1', [currentOrder]);
            } else { 
                otherRes = await client.query('SELECT id, display_order FROM regional_esg_issues WHERE display_order > $1 ORDER BY display_order ASC LIMIT 1', [currentOrder]);
            }

            if (otherRes.rows.length > 0) {
                const otherIssue = otherRes.rows[0];
                await client.query('UPDATE regional_esg_issues SET display_order = $1 WHERE id = $2', [otherIssue.display_order, issueId]);
                await client.query('UPDATE regional_esg_issues SET display_order = $1 WHERE id = $2', [currentOrder, otherIssue.id]);
            }

            await client.query('COMMIT');
            res.status(200).json({ success: true, message: '순서가 변경되었습니다.' });
        } catch (error) {
            await client.query('ROLLBACK');
            res.status(500).json({ success: false, message: '서버 에러' });
        } finally {
            client.release();
        }
    }
);

router.get(
    '/statistics/all-diagnoses',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        const { year } = req.query;
        try {
            let query = `
                SELECT
                    d.id AS diagnosis_id,
                    d.company_name,
                    u.email,
                    d.industry_codes,
                    u.business_location,
                    u.interests,
                    d.establishment_year,
                    d.employee_count,
                    d.recent_sales,
                    d.recent_operating_profit,
                    d.export_percentage,
                    d.is_listed,
                    d.company_size,
                    d.status,
                    d.diagnosis_type,
                    d.total_score,
                    d.e_score,
                    d.s_score,
                    d.g_score,
                    (
                        SELECT json_agg(
                            json_build_object(
                                'question_code', da.question_code,
                                'answer_value', da.answer_value,
                                'score', da.score
                            )
                        )
                        FROM diagnosis_answers da
                        WHERE da.diagnosis_id = d.id
                    ) as answers
                FROM 
                    diagnoses d
                JOIN 
                    users u ON d.user_id = u.id
                WHERE
                    d.status = 'completed'
            `;
            const values = [];

            if (year && year !== 'all') {
                query += ` AND EXTRACT(YEAR FROM d.created_at) = $1`;
                values.push(parseInt(year));
            }
            query += ' ORDER BY d.created_at DESC;';
            
            const { rows } = await db.query(query, values);
            res.status(200).json({ success: true, statistics: rows });
        } catch (error) {
            console.error('통계 데이터 조회 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

router.get(
    '/statistics/available-years',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        try {
            const query = "SELECT DISTINCT EXTRACT(YEAR FROM created_at)::integer as year FROM diagnoses WHERE status = 'completed' ORDER BY year DESC";
            const { rows } = await db.query(query);
            res.status(200).json({ success: true, years: rows.map(r => r.year) });
        } catch (error) {
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.get(
    '/statistics/all-diagnoses/export',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin']),
    async (req, res) => {
        try {
            const query = `
                SELECT
                    d.id as diagnosis_id, u.company_name, u.email, d.industry_codes, 
                    u.business_location, u.interests, d.establishment_year, d.employee_count, 
                    d.recent_sales, d.recent_operating_profit, d.export_percentage, 
                    d.is_listed, d.company_size, d.status, d.diagnosis_type,
                    d.total_score, d.e_score, d.s_score, d.g_score,
                    (
                        SELECT json_agg(json_build_object('question_code', da.question_code, 'answer_value', da.answer_value, 'score', da.score))
                        FROM diagnosis_answers da WHERE da.diagnosis_id = d.id
                    ) as answers
                FROM diagnoses d JOIN users u ON d.user_id = u.id 
                WHERE d.status = 'completed' ORDER BY d.created_at DESC;
            `;
            const { rows } = await db.query(query);

            if (rows.length === 0) {
                return res.status(404).send('Export할 데이터가 없습니다.');
            }

            const naturalSort = (a, b) => {
                const re = /(\d+)/g;
                const a_parts = a.split(re).filter(Boolean);
                const b_parts = b.split(re).filter(Boolean);
                for (let i = 0; i < Math.min(a_parts.length, b_parts.length); i++) {
                    const a_part = a_parts[i];
                    const b_part = b_parts[i];
                    if (!isNaN(a_part) && !isNaN(b_part)) {
                        const a_num = parseInt(a_part, 10);
                        const b_num = parseInt(b_part, 10);
                        if (a_num !== b_num) return a_num - b_num;
                    } else {
                        if (a_part !== b_part) return a_part.localeCompare(b_part);
                    }
                }
                return a_parts.length - b_parts.length;
            };
            
            let allQuestionCodes = new Set();
            rows.forEach(row => {
                if (row.answers) row.answers.forEach(ans => allQuestionCodes.add(ans.question_code));
            });
            const sortedQuestionCodes = Array.from(allQuestionCodes).sort(naturalSort);

            const dataForCsv = rows.map(row => {
                const flatRow = { ...row };
                const answersMap = new Map();
                if(flatRow.answers) flatRow.answers.forEach(ans => answersMap.set(ans.question_code, ans));
                
                sortedQuestionCodes.forEach(code => {
                    const answer = answersMap.get(code);
                    flatRow[`${code}_answer`] = answer ? answer.answer_value : '';
                    flatRow[`${code}_score`] = answer ? answer.score : '';
                });
                
                if(Array.isArray(flatRow.industry_codes)) flatRow.industry_codes = flatRow.industry_codes.join(',');
                if(Array.isArray(flatRow.interests)) flatRow.interests = flatRow.interests.join(',');
                
                delete flatRow.answers;
                return flatRow;
            });
            
            const csvString = stringify(dataForCsv, { header: true });
            res.setHeader('Content-Type', 'text/csv; charset=utf-8');
            res.setHeader('Content-Disposition', `attachment; filename="diagnoses-statistics-${new Date().toISOString().slice(0,10)}.csv"`);
            res.status(200).end('\uFEFF' + csvString);

        } catch (error) {
            console.error("통계 데이터 Export 에러:", error);
            res.status(500).send('Export 중 서버 에러 발생');
        }
    }
);


router.post(
    '/benchmarks/calculate',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        const client = await db.pool.connect();
        try {
            await client.query('BEGIN');

            const [industriesRes, averagesRes, questionsRes, scoringRulesRes, benchmarkRulesRes, answerRulesRes] = await Promise.all([
                client.query('SELECT * FROM industries'),
                client.query('SELECT * FROM industry_averages'),
                client.query("SELECT * FROM survey_questions WHERE diagnosis_type = 'simple'"),
                client.query('SELECT * FROM scoring_rules'),
                client.query('SELECT * FROM benchmark_scoring_rules'),
                client.query('SELECT * FROM average_to_answer_rules')
            ]);

            const allIndustries = industriesRes.rows;
            const allAverages = averagesRes.rows;
            const simpleQuestions = questionsRes.rows;
            const scoringRules = scoringRulesRes.rows;
            const benchmarkRules = benchmarkRulesRes.rows;
            const answerRules = answerRulesRes.rows;
            
            const zeroScoreQuestions = ['S-Q1', 'S-Q2', 'S-Q3', 'S-Q4', 'S-Q5', 'S-Q6', 'S-Q7', 'S-Q8', 'S-Q9', 'S-Q10', 'S-Q11', 'S-Q12', 'S-Q13', 'S-Q14', 'S-Q15', 'S-Q16'];

            for (const industry of allIndustries) {
                const industryAverages = allAverages.find(avg => avg.industry_code === industry.code);

                for (const question of simpleQuestions) {
                    let calculatedScore = null; 
                    if (zeroScoreQuestions.includes(question.question_code)) {
                        calculatedScore = 0;
                    }
                    else if (question.scoring_method === 'benchmark_comparison') {
                        calculatedScore = 50.00; 
                        if (question.benchmark_metric && industryAverages) {
                            const metricValue = parseFloat(industryAverages[question.benchmark_metric]);
                            if (!isNaN(metricValue)) {
                                const tiers = benchmarkRules.filter(r => r.metric_name === question.benchmark_metric).sort((a,b) => a.upper_bound - b.upper_bound);
                                for (const tier of tiers) {
                                    if (tier.is_inverted && metricValue <= tier.upper_bound) {
                                        calculatedScore = parseFloat(tier.score);
                                        break;
                                    }
                                }
                            }
                        }
                    } 
                    else if (question.scoring_method === 'direct_score') {
                        const translationRule = answerRules.find(r => r.question_code === question.question_code);
                        if (translationRule && industryAverages) {
                            const metricName = translationRule.metric_name;
                            const metricValue = parseFloat(industryAverages[metricName]);
                            if (!isNaN(metricValue)) {
                                let estimatedAnswerValue = null;
                                const tiers = answerRules.filter(r => r.metric_name === metricName && r.question_code === question.question_code);
                                for(const tier of tiers) {
                                    if(metricValue > tier.lower_bound && metricValue <= tier.upper_bound) {
                                        estimatedAnswerValue = tier.resulting_answer_value;
                                        break;
                                    }
                                }
                                if (estimatedAnswerValue) {
                                    const finalRule = scoringRules.find(r => r.question_code === question.question_code && r.answer_condition === estimatedAnswerValue);
                                    if (finalRule) calculatedScore = parseFloat(finalRule.score);
                                } else {
                                     calculatedScore = 50.00; 
                                }
                            }
                        } else {
                             calculatedScore = 50.00;
                        }
                    }

                    if (calculatedScore !== null) {
                        const upsertQuery = `
                            INSERT INTO industry_benchmark_scores (industry_code, question_code, average_score, last_calculated_at)
                            VALUES ($1, $2, $3, NOW()) ON CONFLICT (industry_code, question_code) DO UPDATE SET
                            average_score = EXCLUDED.average_score, last_calculated_at = NOW();`;
                        await client.query(upsertQuery, [industry.code, question.question_code, calculatedScore.toFixed(2)]);
                    }
                }
            }

            await client.query('COMMIT');
            res.status(200).json({ success: true, message: `산업 평균 점수 계산 및 저장이 완료되었습니다.` });

        } catch (error) {
            await client.query('ROLLBACK');
            console.error("산업 평균 점수 계산 에러:", error);
            res.status(500).json({ success: false, message: '계산 중 서버 에러 발생' });
        } finally {
            client.release();
        }
    }
);

router.get(
    '/benchmark-scores',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin']),
    async (req, res) => {
        try {
            const query = `
                SELECT 
                    b.id,
                    b.industry_code,
                    i.name as industry_name,
                    b.question_code,
                    b.average_score
                FROM 
                    industry_benchmark_scores b
                JOIN 
                    industries i ON b.industry_code = i.code
                ORDER BY 
                    b.industry_code, b.question_code;
            `;
            const { rows } = await db.query(query);
            res.status(200).json({ success: true, scores: rows });
        } catch (error) {
            console.error('산업 평균 점수 조회 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.put(
    '/benchmark-scores/:id',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin']),
    async (req, res) => {
        const { id } = req.params;
        const { average_score, notes } = req.body; 

        try {
            const query = 'UPDATE industry_benchmark_scores SET average_score = $1, notes = $2, last_calculated_at = NOW() WHERE id = $3 RETURNING id';
            const values = [average_score, notes, id];
            const { rowCount } = await db.query(query, values);

            if (rowCount === 0) {
                return res.status(404).json({ success: false, message: '해당 항목을 찾을 수 없습니다.' });
            }
            res.status(200).json({ success: true, message: '평균 점수가 성공적으로 수정되었습니다.' });
        } catch (error) {
            console.error('산업 평균 점수 수정 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);


router.get('/answer-rules', authMiddleware, checkPermission(['super_admin', 'vice_super_admin']), async (req, res) => {
    try {
        const { rows } = await db.query('SELECT * FROM average_to_answer_rules ORDER BY metric_name, lower_bound');
        res.status(200).json({ success: true, rules: rows });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

router.post('/answer-rules', authMiddleware, checkPermission(['super_admin', 'vice_super_admin']), async (req, res) => {
    const { metric_name, question_code, lower_bound, upper_bound, resulting_answer_value } = req.body;
    try {
        const query = 'INSERT INTO average_to_answer_rules (metric_name, question_code, lower_bound, upper_bound, resulting_answer_value) VALUES ($1, $2, $3, $4, $5)';
        await db.query(query, [metric_name, question_code, lower_bound, upper_bound, resulting_answer_value]);
        res.status(201).json({ success: true, message: '새로운 답변 추정 규칙이 추가되었습니다.' });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

router.put('/answer-rules/:id', authMiddleware, checkPermission(['super_admin', 'vice_super_admin']), async (req, res) => {
    const { id } = req.params;
    const { lower_bound, upper_bound, resulting_answer_value } = req.body;
    try {
        const query = 'UPDATE average_to_answer_rules SET lower_bound = $1, upper_bound = $2, resulting_answer_value = $3 WHERE id = $4';
        const { rowCount } = await db.query(query, [lower_bound, upper_bound, resulting_answer_value, id]);
        if (rowCount === 0) return res.status(404).json({ success: false, message: '해당 규칙을 찾을 수 없습니다.' });
        res.status(200).json({ success: true, message: '규칙이 수정되었습니다.' });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

router.delete('/answer-rules/:id', authMiddleware, checkPermission(['super_admin', '']), async (req, res) => {
    const { id } = req.params;
    try {
        const { rowCount } = await db.query('DELETE FROM average_to_answer_rules WHERE id = $1', [id]);
        if (rowCount === 0) return res.status(404).json({ success: false, message: '해당 규칙을 찾을 수 없습니다.' });
        res.status(200).json({ success: true, message: '규칙이 삭제되었습니다.' });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

router.get(
    '/content/:key',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        const { key } = req.params;
        try {
            const { rows } = await db.query('SELECT content_value FROM site_content WHERE content_key = $1', [key]);
            if (rows.length === 0) {
                const defaultValue = key === 'main_page_sections' ? [] : {};
                return res.status(200).json({ success: true, content: defaultValue });
            }

            const processedContent = convertSiteContentImageUrls(rows[0].content_value);

            res.status(200).json({ success: true, content: processedContent });
        } catch (error) {
            console.error(`콘텐츠 조회 에러 (key: ${key}):`, error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

router.put(
    '/content/:key',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin']),
    async (req, res) => {
        const { key } = req.params;
        const { content } = req.body;
        try {
            const query = 'UPDATE site_content SET content_value = $1, updated_at = NOW() WHERE content_key = $2 RETURNING content_key';
            const values = [JSON.stringify(content), key];
            const { rowCount } = await db.query(query, values);
            if(rowCount === 0) return res.status(404).json({ success: false, message: '콘텐츠 키를 찾을 수 없습니다.'});
            res.status(200).json({ success: true, message: '콘텐츠가 성공적으로 업데이트되었습니다.' });
        } catch (error) {
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);


router.post(
    '/upload-page-images',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin']),
    upload.array('pageImages', 10),
    async (req, res) => {
        if (!req.files || req.files.length === 0) {
            return res.status(400).json({ success: false, message: '업로드된 파일이 없습니다.' });
        }
        try {
            const imageUrls = await Promise.all(
                req.files.map(file => 
                    uploadImageToS3(file.buffer, file.originalname, 'pages', req.user.userId)
                )
            );
            
            res.status(200).json({ 
                success: true, 
                message: "이미지가 성공적으로 업로드되었습니다.", 
                imageUrls: imageUrls 
            });

        } catch (error) {
            console.error('페이지 이미지 업로드 에러:', error);
            res.status(500).json({ success: false, message: '이미지 처리 중 서버 에러' });
        }
    }
);


router.get(
    '/partners',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    async (req, res) => {
        try {
            const { rows } = await db.query('SELECT * FROM partners ORDER BY display_order ASC');

            const processedPartners = rows.map(partner => {
                if (partner.logo_url && !partner.logo_url.startsWith('http')) {
                    return { ...partner, logo_url: `${process.env.STATIC_BASE_URL}/${partner.logo_url}` };
                }
                return partner;
            });

            res.status(200).json({ success: true, partners: processedPartners });
        } catch (error) { 
            console.error("협력사 목록 조회 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러' }); 
        }
    }
);

router.post(
    '/partners',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin']),
    upload.single('partnerLogo'),
    async (req, res) => {
        const { name, link_url } = req.body;
        if (!req.file) {
            return res.status(400).json({ success: false, message: '로고 이미지를 선택해주세요.' });
        }

        const client = await db.pool.connect();
        try {
            await client.query('BEGIN');

            const logoUrl = await uploadImageToS3(req.file.buffer, req.file.originalname, 'partners', req.user.userId);

            const orderRes = await client.query('SELECT MAX(display_order) as max_order FROM partners');
            const newOrder = (orderRes.rows[0].max_order || 0) + 1;

            const query = 'INSERT INTO partners (name, logo_url, link_url, display_order) VALUES ($1, $2, $3, $4) RETURNING id';
            await client.query(query, [name, logoUrl, link_url, newOrder]);
            
            await client.query('COMMIT'); 
            res.status(201).json({ success: true, message: '새로운 협력사가 추가되었습니다.' });

        } catch (error) { 
            await client.query('ROLLBACK');
            console.error("협력사 추가 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' }); 
        } finally {
            client.release();
        }
    }
);

router.put(
    '/partners/:id',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin']),
    upload.single('partnerLogo'), 
    async (req, res) => {
        const { id } = req.params;
        const { name, link_url, logo_url } = req.body; 
        let finalLogoUrl = logo_url;

        try {
            if (req.file) {
                if (logo_url && logo_url.startsWith('http')) {
                    await deleteImageFromS3(logo_url);
                }
                finalLogoUrl = await uploadImageToS3(req.file.buffer, req.file.originalname, 'partners', req.user.userId);
            }
            
            const query = 'UPDATE partners SET name = $1, logo_url = $2, link_url = $3 WHERE id = $4';
            const { rowCount } = await db.query(query, [name, finalLogoUrl, link_url, id]);
            
            if (rowCount === 0) return res.status(404).json({ success: false, message: '항목을 찾을 수 없습니다.' });
            res.status(200).json({ success: true, message: '협력사 정보가 수정되었습니다.' });

        } catch (error) { 
            console.error("협력사 수정 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러' }); 
        }
    }
);

router.post('/partners/reorder', authMiddleware, checkPermission(['super_admin', 'vice_super_admin']), async (req, res) => {
    const { partnerId, direction } = req.body; 

    const client = await db.pool.connect();
    try {
        await client.query('BEGIN');

        const currentRes = await client.query('SELECT display_order FROM partners WHERE id = $1', [partnerId]);
        if (currentRes.rows.length === 0) throw new Error('해당 파트너를 찾을 수 없습니다.');
        const currentOrder = currentRes.rows[0].display_order;

        let otherRes;
        if (direction === 'up') {
            otherRes = await client.query('SELECT id, display_order FROM partners WHERE display_order < $1 ORDER BY display_order DESC LIMIT 1', [currentOrder]);
        } else { // 'down'
            otherRes = await client.query('SELECT id, display_order FROM partners WHERE display_order > $1 ORDER BY display_order ASC LIMIT 1', [currentOrder]);
        }

        if (otherRes.rows.length > 0) {
            const otherPartner = otherRes.rows[0];
            await client.query('UPDATE partners SET display_order = $1 WHERE id = $2', [otherPartner.display_order, partnerId]);
            await client.query('UPDATE partners SET display_order = $1 WHERE id = $2', [currentOrder, otherPartner.id]);
        }

        await client.query('COMMIT');
        res.status(200).json({ success: true, message: '순서가 변경되었습니다.' });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('파트너 순서 변경 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러' });
    } finally {
        client.release();
    }
});

router.delete(
    '/partners/:id',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        const { id } = req.params;
        try {
            const logoRes = await db.query('SELECT logo_url FROM partners WHERE id = $1', [id]);
            const logoUrlToDelete = logoRes.rows[0]?.logo_url;

            const { rowCount } = await db.query('DELETE FROM partners WHERE id = $1', [id]);
            if (rowCount === 0) return res.status(404).json({ success: false, message: '항목을 찾을 수 없습니다.' });

            if (logoUrlToDelete && logoUrlToDelete.startsWith('http')) {
                await deleteImageFromS3(logoUrlToDelete);
            }
            
            res.status(200).json({ success: true, message: '협력사가 삭제되었습니다.' });
        } catch (error) { 
            console.error("협력사 삭제 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러' }); 
        }
    }
);

router.get('/site-meta', authMiddleware, async (req, res) => {
    try {
        const { rows } = await db.query('SELECT * FROM site_meta WHERE id = 1');
        if (rows.length === 0) {
            return res.json({ success: true, meta: { title: '', description: '', image_url: '' } });
        }
        res.json({ success: true, meta: rows[0] });
    } catch (error) {
        res.status(500).json({ success: false, message: '메타 정보 조회 중 서버 에러' });
    }
});

router.put(
    '/site-meta',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin']),
    upload.single('metaImage'),
    async (req, res) => {
        const { title, description, existing_image_url } = req.body;
        let finalImageUrl = existing_image_url;

        try {
            if (req.file) {
                if (existing_image_url && existing_image_url.startsWith('http')) {
                    await deleteImageFromS3(existing_image_url);
                }
                finalImageUrl = await uploadImageToS3(req.file.buffer, req.file.originalname, 'meta', req.user.userId);
            }

            const query = `
                INSERT INTO site_meta (id, title, description, image_url)
                VALUES (1, $1, $2, $3)
                ON CONFLICT (id) DO UPDATE
                SET title = $1, description = $2, image_url = $3;
            `;
            await db.query(query, [title, description, finalImageUrl]);

            res.status(200).json({ success: true, message: '사이트 공유 정보가 성공적으로 업데이트되었습니다.' });
        } catch (error) {
            console.error("사이트 메타 정보 업데이트 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

router.get(
    '/simulator-parameters',
    authMiddleware,
    checkPermission(['super_admin']), 
    async (req, res) => {
        try {
            const { rows } = await db.query('SELECT * FROM simulator_parameters ORDER BY id ASC');
            res.status(200).json({ success: true, parameters: rows });
        } catch (error) {
            console.error("시뮬레이터 매개변수 조회 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.put(
    '/simulator-parameters/:id',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        const { id } = req.params;
        const { parameter_value, description } = req.body;

        if (parameter_value === undefined) {
            return res.status(400).json({ success: false, message: '값이 필요합니다.' });
        }

        try {
            const query = 'UPDATE simulator_parameters SET parameter_value = $1, description = $2 WHERE id = $3 RETURNING id';
            const values = [parameter_value, description, id];
            const { rowCount } = await db.query(query, values);

            if (rowCount === 0) {
                return res.status(404).json({ success: false, message: '해당 매개변수를 찾을 수 없습니다.' });
            }
            res.status(200).json({ success: true, message: '매개변수가 성공적으로 업데이트되었습니다.' });
        } catch (error) {
            console.error("시뮬레이터 매개변수 수정 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

router.get('/industry-average-columns', authMiddleware, async (req, res) => {
    try {
        const query = `
            SELECT column_name 
            FROM information_schema.columns
            WHERE table_schema = 'public' 
              AND table_name = 'industry_averages'
              AND column_name NOT IN ('id', 'industry_code', 'created_at', 'updated_at');
        `;
        const { rows } = await db.query(query);
        
        const columnNames = rows.map(row => row.column_name);
        
        res.status(200).json({ success: true, columns: columnNames });

    } catch (error) {
        console.error('산업 평균 데이터 컬럼 조회 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

router.get('/applications', authMiddleware, checkPermission(['super_admin', 'vice_super_admin', 'user_manager']), async (req, res) => {
    try {
        const query = `
            SELECT 
                ua.id,
                ua.status, 
                ua.created_at,
                u.company_name,
                u.manager_name,
                u.manager_phone,
                u.email,
                p.title AS program_title,
                p.related_links 
            FROM 
                user_applications ua
            JOIN 
                users u ON ua.user_id = u.id
            JOIN 
                esg_programs p ON ua.program_id = p.id
            ORDER BY 
                ua.created_at DESC;
        `;
        const { rows } = await db.query(query);

        const processedRows = rows.map(row => {
            let organization_name = '-';
            if (row.related_links && row.related_links.length > 0) {
                organization_name = row.related_links[0].organization_name || '-';
            }
            delete row.related_links;
            return { ...row, organization_name };
        });

        res.status(200).json({ success: true, applications: processedRows });
    } catch (error) {
        console.error("신청 현황 조회 에러:", error);
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});

router.get('/applications/export', authMiddleware, checkPermission(['super_admin', 'vice_super_admin', 'user_manager']), async (req, res) => {
    try {
        const query = `
            SELECT 
                ua.id as "신청ID",
                u.company_name as "회사명",
                u.manager_name as "담당자",
                u.manager_phone as "연락처",
                u.email as "이메일",
                p.title AS "신청 프로그램",
                ua.status as "진행상태",
                TO_CHAR(ua.created_at, 'YYYY-MM-DD HH24:MI:SS') as "신청일시"
            FROM 
                user_applications ua
            JOIN 
                users u ON ua.user_id = u.id
            JOIN 
                esg_programs p ON ua.program_id = p.id
            ORDER BY 
                ua.created_at DESC;
        `;
        const { rows } = await db.query(query);

        if (rows.length === 0) {
            return res.status(404).send('내보낼 데이터가 없습니다.');
        }

        const csvString = stringify(rows, { header: true });

        res.setHeader('Content-Type', 'text/csv; charset=utf-8');
        res.setHeader('Content-Disposition', `attachment; filename="applications-${new Date().toISOString().slice(0,10)}.csv"`);
        
        res.status(200).end('\uFEFF' + csvString);

    } catch (error) {
        console.error("신청 현황 내보내기 에러:", error);
        res.status(500).send('Export 중 서버 에러 발생');
    }
});

router.get('/news', authMiddleware, checkPermission(['super_admin', 'vice_super_admin', 'content_manager']), async (req, res) => {
    try {
        const query = 'SELECT id, title, category, status, created_at, is_pinned FROM news_posts ORDER BY id DESC';
        const { rows } = await db.query(query);
        res.status(200).json({ success: true, posts: rows });
    } catch (error) {
        console.error("관리자용 소식 목록 조회 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

router.get('/news/:id', authMiddleware, async (req, res) => {
    const { id } = req.params;
    try {
        const query = 'SELECT * FROM news_posts WHERE id = $1';
        const { rows } = await db.query(query, [id]);
        if (rows.length === 0) {
            return res.status(404).json({ success: false, message: '게시물을 찾을 수 없습니다.' });
        }

        const processedPost = convertProgramContentUrls(rows[0]);

        res.status(200).json({ success: true, post: processedPost });
    } catch (error) {
        console.error("특정 소식 조회 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

router.patch('/news/:id/pin', authMiddleware, checkPermission(['super_admin']), async (req, res) => {
    const { id } = req.params;
    const { isPinned } = req.body;
    try {
        const { rowCount } = await db.query('UPDATE news_posts SET is_pinned = $1 WHERE id = $2', [isPinned, id]);
        if (rowCount === 0) return res.status(404).json({ success: false, message: '게시물을 찾을 수 없습니다.' });
        res.status(200).json({ success: true, message: '고정 상태가 변경되었습니다.' });
    } catch (error) {
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

router.post('/news', authMiddleware, checkPermission(['super_admin', 'vice_super_admin', 'content_manager']), upload.any(), async (req, res) => {
    const { title, category, status, content } = req.body;
    const { userId } = req.user; 
    
    try {
        const parsedContent = JSON.parse(content);
        
        const finalContent = await Promise.all(parsedContent.map(async (section) => {
            const images = await Promise.all(section.images.map(async (placeholder) => {
                const file = req.files.find(f => f.fieldname === placeholder);
                if (file) {
                    return await uploadImageToS3(file.buffer, file.originalname, 'news', userId);
                }
                return null;
            }));
            
            return { ...section, images: images.filter(Boolean) };
        }));
        
        const query = `INSERT INTO news_posts (title, content, category, status, author_id) VALUES ($1, $2, $3, $4, $5) RETURNING id`;
        const values = [title, JSON.stringify(finalContent), category, status || 'draft', userId];
        
        await db.query(query, values);
        res.status(201).json({ success: true, message: '소식이 성공적으로 등록되었습니다.' });

    } catch (error) {
        console.error("새 소식 저장 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});


router.put('/news/:id', authMiddleware, checkPermission(['super_admin', 'vice_super_admin',  'content_manager']), upload.any(), async (req, res) => {
    const { id } = req.params;
    const { title, category, status, content } = req.body;
    
    try {
        const oldPostRes = await db.query('SELECT content FROM news_posts WHERE id = $1', [id]);
        const oldImageUrls = new Set();
        if (oldPostRes.rows.length > 0 && oldPostRes.rows[0].content) {
            oldPostRes.rows[0].content.forEach(section => {
                if (section.images) section.images.forEach(imgUrl => oldImageUrls.add(imgUrl));
            });
        }

        const parsedContent = JSON.parse(content);
        
        const finalContent = await Promise.all(parsedContent.map(async (section) => {
            const updatedImages = await Promise.all(section.images.map(async (imageOrPlaceholder) => {
                if (typeof imageOrPlaceholder === 'string' && imageOrPlaceholder.startsWith('http')) {
                    return imageOrPlaceholder;
                }
                const file = req.files.find(f => f.fieldname === imageOrPlaceholder);
                if (file) {
                    return await uploadImageToS3(file.buffer, file.originalname, 'news', req.user.userId);
                }
                return null;
            }));
            return { ...section, images: updatedImages.filter(Boolean) };
        }));

        const newImageUrls = new Set();
        finalContent.forEach(section => {
            if (section.images) section.images.forEach(imgUrl => newImageUrls.add(imgUrl));
        });

        const imagesToDelete = [...oldImageUrls].filter(url => !newImageUrls.has(url));
        
        if (imagesToDelete.length > 0) {
            await Promise.all(imagesToDelete.map(url => deleteImageFromS3(url)));
        }

        const query = `
            UPDATE news_posts 
            SET title = $1, content = $2, category = $3, status = $4, updated_at = NOW() 
            WHERE id = $5`;
        const values = [title, JSON.stringify(finalContent), category, status, id];
        await db.query(query, values);
        
        res.status(200).json({ success: true, message: '게시물이 성공적으로 수정되었습니다.' });

    } catch (error) {
        console.error("소식 수정 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

router.patch('/news/:id/status', authMiddleware, checkPermission(['super_admin']), async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;

    console.log(`[API PATCH /news/:id/status] Received request...`);
    console.log(`  -> Post ID: ${id}`);
    console.log(`  -> New Status: ${status}`);

    if (!status) {
        return res.status(400).json({ success: false, message: '상태 값이 필요합니다.' });
    }

    try {
        const query = 'UPDATE news_posts SET status = $1 WHERE id = $2';
        const { rowCount } = await db.query(query, [status, id]);
        
        console.log(`  -> DB update executed. Affected rows: ${rowCount}`);
        
        if (rowCount === 0) {
            return res.status(404).json({ success: false, message: '게시물을 찾을 수 없습니다.' });
        }
        res.status(200).json({ success: true, message: `상태가 '${status === 'published' ? '발행' : '임시저장'}'(으)로 변경되었습니다.` });
    } catch (error) {
        console.error("상태 변경 API 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

router.delete('/news/:id', authMiddleware, checkPermission(['super_admin', 'vice_super_admin' ]), async (req, res) => {
    const { id } = req.params;
    try {
        const postRes = await db.query('SELECT content FROM news_posts WHERE id = $1', [id]);
        if (postRes.rows.length > 0 && postRes.rows[0].content) {
            const content = postRes.rows[0].content;
            const imagesToDelete = [];
            content.forEach(section => {
                if (section.images && Array.isArray(section.images)) {
                    imagesToDelete.push(...section.images);
                }
            });

            if (imagesToDelete.length > 0) {
                await Promise.all(imagesToDelete.map(url => deleteImageFromS3(url)));
            }
        }

        const { rowCount } = await db.query('DELETE FROM news_posts WHERE id = $1', [id]);
        if (rowCount === 0) {
            return res.status(404).json({ success: false, message: '삭제할 게시물을 찾을 수 없습니다.' });
        }

        res.status(200).json({ success: true, message: '게시물이 성공적으로 삭제되었습니다.' });
    } catch (error) {
        console.error('소식 삭제 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

router.post('/upload-news-image', authMiddleware, checkPermission(['super_admin', 'vice_super_admin', 'content_manager']), upload.array('newsImages', 3), async (req, res) => {
    if (!req.files || req.files.length === 0) {
        return res.status(400).json({ success: false, message: '업로드된 파일이 없습니다.' });
    }
    try {
        const imageUrls = await Promise.all(
            req.files.map(file => 
                uploadImageToS3(file.buffer, file.originalname, 'news', req.user.userId)
            )
        );
        
        res.status(200).json({ 
            success: true, 
            message: "이미지가 성공적으로 업로드되었습니다.", 
            imageUrls: imageUrls 
        });

    } catch (error) {
        console.error("뉴스 이미지 처리 에러:", error);
        res.status(500).json({ success: false, message: '이미지 처리 중 오류가 발생했습니다.' });
    }
});

router.get('/site-content', authMiddleware, checkPermission(['super_admin']), async (req, res) => {
    try {
        const [contentRes, sitesRes] = await Promise.all([
            db.query("SELECT * FROM site_content WHERE id = 1"),
            db.query("SELECT * FROM related_sites ORDER BY display_order")
        ]);

        const siteContent = contentRes.rows[0] || {};

        if (siteContent.content_value) {
            siteContent.content_value = convertSiteContentImageUrls(siteContent.content_value);
        }

        res.status(200).json({ 
            success: true, 
            content: siteContent,
            relatedSites: sitesRes.rows 
        });
    } catch (e) { 
        console.error("사이트 콘텐츠 조회 에러:", e);
        res.status(500).json({ success: false, message: '서버 에러' }); 
    }
});


router.put('/site-content', authMiddleware, checkPermission(['super_admin']), upload.any(), async (req, res) => {
    const { footer_info, terms_of_service, privacy_policy, marketing_consent_text, related_sites, main_page_content } = req.body;
    const newImageFiles = req.files;
    const client = await db.pool.connect();

    try {
        await client.query('BEGIN');

        const parsedMainContent = JSON.parse(main_page_content);
        
        const finalMainContent = await Promise.all(parsedMainContent.map(async (section) => {
            const updatedImages = await Promise.all(section.images.map(async (imageOrPlaceholder) => {
                if (typeof imageOrPlaceholder === 'object' && imageOrPlaceholder.file.startsWith('https')) {
                    return imageOrPlaceholder;
                }
                
                const file = newImageFiles.find(f => f.fieldname === imageOrPlaceholder.file);
                if (file) {
                    const newImageUrl = await uploadImageToS3(file.buffer, file.originalname, 'pages', req.user.userId);
                    return { file: newImageUrl }; 
                }
                return null;
            }));
            
            return { ...section, images: updatedImages.filter(Boolean) };
        }));

        const upsertQuery = `
            INSERT INTO site_content (id, content_key, content, content_value, terms_of_service, privacy_policy, marketing_consent_text, updated_at) 
            VALUES (1, 'main_page_sections', $1, $2, $3, $4, $5, NOW())
            ON CONFLICT (id) DO UPDATE SET
                content = EXCLUDED.content,
                content_value = EXCLUDED.content_value,
                terms_of_service = EXCLUDED.terms_of_service,
                privacy_policy = EXCLUDED.privacy_policy,
                marketing_consent_text = EXCLUDED.marketing_consent_text,
                updated_at = NOW();
        `;
        await client.query(upsertQuery, [JSON.parse(footer_info), JSON.stringify(finalMainContent), terms_of_service, privacy_policy, marketing_consent_text]);
        
        await client.query('DELETE FROM related_sites');
        for (const site of JSON.parse(related_sites)) {
            if (site.name && site.url) {
                await client.query('INSERT INTO related_sites (name, url) VALUES ($1, $2)', [site.name, site.url]);
            }
        }
        
        await client.query('COMMIT');
        res.status(200).json({ success: true, message: '사이트 정보가 성공적으로 업데이트되었습니다.' });

    } catch (error) {
        await client.query('ROLLBACK');
        console.error("사이트 콘텐츠 업데이트 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    } finally {
        client.release();
    }
});

router.delete('/users/:id', authMiddleware, checkPermission(['super_admin']), async (req, res) => {
    const { id } = req.params;
    const adminId = req.user.userId;

    if (parseInt(id, 10) === adminId) {
        return res.status(403).json({ success: false, message: '자기 자신의 계정은 삭제할 수 없습니다.' });
    }

    try {
        const { rowCount } = await db.query('DELETE FROM users WHERE id = $1', [id]);
        
        if (rowCount === 0) {
            return res.status(404).json({ success: false, message: '삭제할 사용자를 찾을 수 없습니다.' });
        }
        
        res.status(200).json({ success: true, message: '사용자가 성공적으로 삭제되었습니다.' });

    } catch (error) {
        console.error("관리자 회원 삭제 에러:", error);
        if (error.code === '23503') {
             return res.status(400).json({ success: false, message: '해당 사용자는 다른 데이터(진단 이력, 게시물 등)와 연결되어 있어 삭제할 수 없습니다.' });
        }
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});


router.get('/applications', authMiddleware, checkPermission(['super_admin', 'vice_super_admin', 'user_manager']), async (req, res) => {
    try {
        const query = `
            SELECT 
                ua.id,
                ua.status, -- 신청 상태 추가
                ua.created_at,
                u.company_name,
                u.manager_name,
                u.manager_phone,
                u.email,
                p.title AS program_title
            FROM 
                user_applications ua
            JOIN 
                users u ON ua.user_id = u.id
            JOIN 
                esg_programs p ON ua.program_id = p.id
            ORDER BY 
                ua.created_at DESC;
        `;
        const { rows } = await db.query(query);
        res.status(200).json({ success: true, applications: rows });
    } catch (error) {
        console.error("신청 현황 조회 에러:", error);
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});

router.put('/applications/:id/status', authMiddleware, checkPermission(['super_admin', 'vice_super_admin', 'user_manager']), async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;

    if (!['접수', '진행', '완료'].includes(status)) {
        return res.status(400).json({ success: false, message: '유효하지 않은 상태 값입니다.' });
    }

    const client = await db.pool.connect();
    try {
        await client.query('BEGIN');

        const updateRes = await client.query('UPDATE user_applications SET status = $1 WHERE id = $2 RETURNING user_id, program_id', [status, id]);
        if (updateRes.rows.length === 0) {
            throw new Error('해당 신청 내역을 찾을 수 없습니다.');
        }

        const { user_id, program_id } = updateRes.rows[0];
        const programRes = await client.query('SELECT title FROM esg_programs WHERE id = $1', [program_id]);
        const programTitle = programRes.rows[0].title;

        const message = `신청하신 '${programTitle}' 프로그램의 진행 상태가 [${status}](으)로 변경되었습니다.`;
        const link_url = '/mypage_program.html';

        await client.query(
            'INSERT INTO notifications (user_id, message, link_url) VALUES ($1, $2, $3)',
            [user_id, message, link_url]
        );

        await client.query('COMMIT');
        res.status(200).json({ success: true, message: `신청 상태가 [${status}] (으)로 변경되었습니다.` });

    } catch (error) {
        await client.query('ROLLBACK');
        console.error(`신청(ID: ${id}) 상태 변경 에러:`, error);
        res.status(500).json({ success: false, message: error.message || '서버 에러 발생' });
    } finally {
        client.release();
    }
});

router.post(
    '/users/:userId/assign-program',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'user_manager']),
    async (req, res) => {
        const { userId } = req.params;
        const { program_id, admin_message } = req.body;

        if (!program_id) {
            return res.status(400).json({ success: false, message: 'program_id가 필요합니다.' });
        }

        try {
            const applicationResult = await db.query(
                `INSERT INTO user_applications (user_id, program_id, status, admin_message)
                 VALUES ($1, $2, 'assigned', $3)
                 RETURNING id`,
                [userId, program_id, admin_message || ''] 
            );
            const newApplicationId = applicationResult.rows[0].id;

            res.status(201).json({
                success: true,
                message: '프로그램이 성공적으로 할당되었습니다.',
                application_id: newApplicationId
            });
        } catch (error) {
            console.error('맞춤형 프로그램 할당 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);


router.get(
    '/applications/:applicationId/milestones',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        const { applicationId } = req.params;
        try {
            const appRes = await db.query('SELECT user_id FROM user_applications WHERE id = $1', [applicationId]);
            if (appRes.rows.length === 0) {
                return res.status(404).json({ success: false, message: '신청 정보를 찾을 수 없습니다.' });
            }
            const userId = appRes.rows[0].user_id;

            const diagRes = await db.query(`SELECT id FROM diagnoses WHERE user_id = $1 AND status = 'completed' ORDER BY created_at DESC LIMIT 1`, [userId]);
            const latestDiagnosisId = diagRes.rows.length > 0 ? diagRes.rows[0].id : null;

            let userScoresMap = new Map();
            if (latestDiagnosisId) {
                const userScoresRes = await db.query('SELECT question_code, score FROM diagnosis_answers WHERE diagnosis_id = $1', [latestDiagnosisId]);
                userScoresMap = new Map(userScoresRes.rows.map(r => [r.question_code, r.score]));
            }

            const milestonesRes = await db.query('SELECT * FROM application_milestones WHERE application_id = $1 ORDER BY display_order ASC, id ASC', [applicationId]);
            const milestones = milestonesRes.rows;

            for (const milestone of milestones) {
                milestone.linked_questions_with_scores = [];
                if (Array.isArray(milestone.linked_question_codes)) {
                    milestone.linked_questions_with_scores = milestone.linked_question_codes.map(code => ({
                        code: code,
                        score: userScoresMap.has(code) ? userScoresMap.get(code) : 'N/A'
                    }));
                }
            }
            
            res.status(200).json({ 
                success: true, 
                milestones: milestones,
                allUserScores: Object.fromEntries(userScoresMap) 
            });

        } catch (error) {
            console.error(`[CRITICAL] 마일스톤 조회 에러 (Application ID: ${applicationId}):`, error);
            res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
        }
    }
);


router.post(
    '/applications/:applicationId/milestones/:milestoneId/complete',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'user_manager']),
    async (req, res) => {
        const { applicationId, milestoneId } = req.params;

        try {
            const appInfo = await db.query('SELECT user_id FROM user_applications WHERE id = $1', [applicationId]);
            if (appInfo.rows.length === 0) {
                return res.status(404).json({ success: false, message: '신청 내역을 찾을 수 없습니다.' });
            }
            const userId = appInfo.rows[0].user_id;

            const checkResult = await db.query(
                'SELECT id FROM user_milestone_completions WHERE application_id = $1 AND milestone_id = $2',
                [applicationId, milestoneId]
            );

            if (checkResult.rows.length > 0) {
                return res.status(409).json({ success: false, message: '이미 완료 처리된 마일스톤입니다.' });
            }

            await db.query(
                'INSERT INTO user_milestone_completions (user_id, application_id, milestone_id) VALUES ($1, $2, $3)',
                [userId, applicationId, milestoneId]
            );

            res.status(201).json({ success: true, message: '마일스톤을 완료 처리했습니다.' });
        } catch (error) {
            console.error('마일스톤 완료 처리 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

router.get(
    '/my-programs',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        try {
            const { userId, role } = req.user;
            let query = 'SELECT id, title FROM esg_programs';
            const values = [];
            if (role !== 'super_admin' && role !== 'vice_super_admin') {
                query += ' WHERE author_id = $1';
                values.push(userId);
            }
            query += ' ORDER BY title ASC';
            const { rows } = await db.query(query, values);
            res.status(200).json({ success: true, programs: rows });
        } catch (error) {
            res.status(500).json({ success: false, message: '서버 오류' });
        }
    }
);


router.get(
    '/programs/:programId/applications',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        try {
            const { programId } = req.params;
            const query = `
                SELECT ua.id, u.company_name
                FROM user_applications ua
                JOIN users u ON ua.user_id = u.id
                WHERE ua.program_id = $1
                ORDER BY u.company_name ASC`;
            const { rows } = await db.query(query, [programId]);
            res.status(200).json({ success: true, applications: rows });
        } catch (error) {
            res.status(500).json({ success: false, message: '서버 오류' });
        }
    }
);


router.get(
    '/survey-questions/all',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        try {
            const { rows } = await db.query('SELECT question_code, question_text FROM survey_questions ORDER BY display_order');
            res.status(200).json({ success: true, questions: rows });
        } catch (error) {
            res.status(500).json({ success: false, message: '서버 오류' });
        }
    }
);


router.get(
    '/applications/:applicationId/milestones',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        const { applicationId } = req.params;
        try {
            const appRes = await db.query('SELECT user_id FROM user_applications WHERE id = $1', [applicationId]);
            if (appRes.rows.length === 0) return res.status(404).json({ success: false, message: '신청 정보를 찾을 수 없습니다.' });
            const userId = appRes.rows[0].user_id;

            const diagRes = await db.query(`SELECT id FROM diagnoses WHERE user_id = $1 AND status = 'completed' ORDER BY created_at DESC LIMIT 1`, [userId]);
            const latestDiagnosisId = diagRes.rows.length > 0 ? diagRes.rows[0].id : null;

            const milestonesRes = await db.query('SELECT * FROM application_milestones WHERE application_id = $1 ORDER BY display_order ASC', [applicationId]);
            const milestones = milestonesRes.rows;

            if (latestDiagnosisId && milestones.length > 0) {
                for (const milestone of milestones) {
                    milestone.linked_questions_with_scores = []; 
                    if (milestone.linked_question_codes && milestone.linked_question_codes.length > 0) {
                        const scoreQuery = `
                            SELECT question_code, score FROM diagnosis_answers
                            WHERE diagnosis_id = $1 AND question_code = ANY($2::text[])
                        `;
                        const scoresRes = await db.query(scoreQuery, [latestDiagnosisId, milestone.linked_question_codes]);
                        const scoresMap = new Map(scoresRes.rows.map(r => [r.question_code, r.score]));
                        
                        milestone.linked_questions_with_scores = milestone.linked_question_codes.map(code => ({
                            code: code,
                            score: scoresMap.get(code) ?? 'N/A' 
                        }));
                    }
                }
            }
            
            res.status(200).json({ success: true, milestones: milestones });
        } catch (error) {
            console.error('마일스톤 조회 에러:', error);
            res.status(500).json({ success: false, message: '서버 오류' });
        }
    }
);


router.post(
    '/applications/:applicationId/milestones',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        const { applicationId } = req.params;
        const { milestone_name, score_value, linked_question_code, content, display_order } = req.body;
        try {
            const query = `
                INSERT INTO application_milestones (application_id, milestone_name, score_value, linked_question_code, content, display_order)
                VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`;
            const { rows } = await db.query(query, [applicationId, milestone_name, score_value, linked_question_code, content, display_order]);
            res.status(201).json({ success: true, message: '마일스톤이 추가되었습니다.', milestone: rows[0] });
        } catch (error) {
            res.status(500).json({ success: false, message: '서버 오류' });
        }
    }
);


router.post(
    '/applications/:applicationId/milestones/batch-update',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    upload.any(),
    async (req, res) => {
        const { applicationId } = req.params;
        const { milestonesData } = req.body;
        const client = await db.pool.connect();

        try {
            await client.query('BEGIN');

            const receivedMilestones = JSON.parse(milestonesData);
            const existingMilestonesRes = await client.query('SELECT id, image_url, attachment_url FROM application_milestones WHERE application_id = $1', [applicationId]);
            const existingMilestonesMap = new Map(existingMilestonesRes.rows.map(m => [m.id, { imageUrl: m.image_url, attachmentUrl: m.attachment_url }]));
            
            const receivedMilestoneIds = new Set();

            for (const milestone of receivedMilestones) {
                let imageUrl = milestone.image_url || null;
                let attachmentUrl = milestone.attachment_url || null;

                if (milestone.imagePlaceholder) {
                    const imageFile = req.files.find(f => f.fieldname === milestone.imagePlaceholder);
                    if (imageFile) {
                        const oldData = existingMilestonesMap.get(milestone.id);
                        if (oldData && oldData.imageUrl) await deleteImageFromS3(oldData.imageUrl);
                        imageUrl = await uploadImageToS3(imageFile.buffer, imageFile.originalname, 'milestones/images', req.user.userId);
                    }
                }

                if (milestone.attachmentPlaceholder) {
                    const attachmentFile = req.files.find(f => f.fieldname === milestone.attachmentPlaceholder);
                    if (attachmentFile) {
                        const oldData = existingMilestonesMap.get(milestone.id);
                        if (oldData && oldData.attachmentUrl) await deleteImageFromS3(oldData.attachmentUrl);
                        attachmentUrl = await uploadFileToS3(attachmentFile.buffer, attachmentFile.originalname, 'milestones/attachments', req.user.userId);
                    }
                }

                if (milestone.id === 'new') {
                    const query = `
                        INSERT INTO application_milestones 
                        (application_id, milestone_name, score_value, improvement_category, content, display_order, image_url, attachment_url) 
                        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                    `;
                    await client.query(query, [applicationId, milestone.milestone_name, milestone.score_value, milestone.improvement_category, milestone.content, milestone.display_order, imageUrl, attachmentUrl]);
                } else {
                    const milestoneId = parseInt(milestone.id, 10);
                    receivedMilestoneIds.add(milestoneId);
                    
                    const query = `
                        UPDATE application_milestones 
                        SET milestone_name=$1, score_value=$2, improvement_category=$3, content=$4, display_order=$5, image_url=$6, attachment_url=$7, updated_at=NOW() 
                        WHERE id=$8
                    `;
                    await client.query(query, [milestone.milestone_name, milestone.score_value, milestone.improvement_category, milestone.content, milestone.display_order, imageUrl, attachmentUrl, milestoneId]);
                }
            }
            
            for (const [existingId, existingUrls] of existingMilestonesMap.entries()) {
                if (!receivedMilestoneIds.has(existingId)) {
                    if (existingUrls.imageUrl) await deleteImageFromS3(existingUrls.imageUrl);
                    if (existingUrls.attachmentUrl) await deleteImageFromS3(existingUrls.attachmentUrl);
                    await client.query('DELETE FROM application_milestones WHERE id = $1', [existingId]);
                }
            }

            await client.query('COMMIT');
            res.status(200).json({ success: true, message: '모든 변경사항이 성공적으로 저장되었습니다.' });

        } catch (error) {
            await client.query('ROLLBACK');
            console.error("마일스톤 일괄 저장 에러:", error);
            res.status(500).json({ success: false, message: '저장 중 서버 오류가 발생했습니다.' });
        } finally {
            client.release();
        }
    }
);


router.get(
    '/regulations', 
    authMiddleware,
    async (req, res) => {
        try {
            const { rows } = await db.query('SELECT * FROM regulations ORDER BY effective_date ASC');
            res.status(200).json({ success: true, regulations: rows });
        } catch (error) {
            console.error("규제 정보 조회 에러:", error);
            res.status(500).json({ success: false, message: '서버 오류' });
        }
    }
);


router.post(
    '/regulations',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        const { regulation_name, effective_date, description, target_sizes, link_url, sanctions, countermeasures } = req.body;
        try {
            const query = `
                INSERT INTO regulations (regulation_name, effective_date, description, target_sizes, link_url, sanctions, countermeasures)
                VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`;
            const { rows } = await db.query(query, [regulation_name, effective_date, description, target_sizes, link_url, sanctions, countermeasures]);
            res.status(201).json({ success: true, message: '규제 정보가 추가되었습니다.', regulation: rows[0] });
        } catch (error) {
            console.error("규제 정보 추가 에러:", error);
            res.status(500).json({ success: false, message: '서버 오류' });
        }
    }
);


router.put(
    '/regulations/:id',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        const { id } = req.params;
        const { regulation_name, effective_date, description, target_sizes, link_url, sanctions, countermeasures } = req.body;
        try {
            const query = `
                UPDATE regulations SET
                    regulation_name = $1, effective_date = $2, description = $3,
                    target_sizes = $4, link_url = $5, sanctions = $6, countermeasures = $7, updated_at = NOW()
                WHERE id = $8 RETURNING *`;
            const { rows } = await db.query(query, [regulation_name, effective_date, description, target_sizes, link_url, sanctions, countermeasures, id]);
            if (rows.length === 0) {
                return res.status(404).json({ success: false, message: '규제 정보를 찾을 수 없습니다.' });
            }
            res.status(200).json({ success: true, message: '규제 정보가 수정되었습니다.', regulation: rows[0] });
        } catch (error) {
            console.error("규제 정보 수정 에러:", error);
            res.status(500).json({ success: false, message: '서버 오류' });
        }
    }
);


router.delete(
    '/regulations/:id',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        const { id } = req.params;
        try {
            const { rowCount } = await db.query('DELETE FROM regulations WHERE id = $1', [id]);
            if (rowCount === 0) {
                return res.status(404).json({ success: false, message: '규제 정보를 찾을 수 없습니다.' });
            }
            res.status(200).json({ success: true, message: '규제 정보가 삭제되었습니다.' });
        } catch (error) {
            console.error("규제 정보 삭제 에러:", error);
            res.status(500).json({ success: false, message: '서버 오류' });
        }
    }
);

router.get(
    '/solution-categories',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        try {
            const { rows } = await db.query('SELECT * FROM solution_categories ORDER BY parent_category, id');
            res.status(200).json({ success: true, categories: rows });
        } catch (error) {
            console.error("솔루션 카테고리 조회 에러:", error);
            res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
        }
    }
);

router.put(
    '/solution-categories/:id',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin', 'content_manager']),
    async (req, res) => {
        const { id } = req.params;
        const { description } = req.body; 
        try {
            const query = 'UPDATE solution_categories SET description = $1 WHERE id = $2 RETURNING *';
            const { rows } = await db.query(query, [description, id]);
            if (rows.length === 0) {
                return res.status(404).json({ success: false, message: '해당 카테고리를 찾을 수 없습니다.' });
            }
            res.status(200).json({ success: true, message: '카테고리 설명이 수정되었습니다.', category: rows[0] });
        } catch (error) {
            console.error("솔루션 카테고리 수정 에러:", error);
            res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
        }
    }
);


router.get(
    '/admins-list',
    authMiddleware,
    checkPermission(['super_admin', 'vice_super_admin']),
    async (req, res) => {
        try {
            const query = "SELECT id, company_name FROM users WHERE role = 'content_manager' ORDER BY company_name ASC";
            const { rows } = await db.query(query);
            res.status(200).json({ success: true, admins: rows });
        } catch (error) {
            console.error("콘텐츠 매니저 목록 조회 에러:", error);
            res.status(500).json({ success: false, message: '서버 오류' });
        }
    }
);

router.get('/referral-codes', authMiddleware, checkPermission(['super_admin', 'vice_super_admin']), async (req, res) => {
    try {
        const query = `
            SELECT rc.id, rc.code, rc.created_at, rc.expires_at, u.company_name as organization_name
            FROM referral_codes rc
            LEFT JOIN users u ON rc.linked_admin_id = u.id
            ORDER BY rc.created_at DESC
        `;
        const { rows } = await db.query(query);
        res.status(200).json({ success: true, codes: rows });
    } catch (error) { 
        console.error("추천 코드 목록 조회 에러:", error);
        res.status(500).json({ success: false, message: '서버 오류' }); 
    }
});


router.post('/referral-codes', authMiddleware, checkPermission(['super_admin', 'vice_super_admin']), async (req, res) => {
    const { code, linked_admin_id, expires_at } = req.body;
    try {
        const query = 'INSERT INTO referral_codes (code, linked_admin_id, expires_at) VALUES ($1, $2, $3) RETURNING *';
        await db.query(query, [code, linked_admin_id || null, expires_at || null]);
        res.status(201).json({ success: true, message: '추천 코드가 생성되었습니다.' });
    } catch (error) {
        if (error.code === '23505') { // unique_violation
            return res.status(409).json({ success: false, message: '이미 존재하는 추천 코드입니다.' });
        }
        res.status(500).json({ success: false, message: '서버 오류' });
    }
});


router.delete('/referral-codes/:id', authMiddleware, checkPermission(['super_admin', 'vice_super_admin']), async (req, res) => {
    const { id } = req.params;
    try {
        await db.query('DELETE FROM referral_codes WHERE id = $1', [id]);
        res.status(200).json({ success: true, message: '추천 코드가 삭제되었습니다.' });
    } catch (error) { res.status(500).json({ success: false, message: '서버 오류' }); }
});

router.get('/solution-categories-public', async (req, res) => {
    try {
        const { rows } = await db.query('SELECT * FROM solution_categories ORDER BY parent_category, id');
        res.status(200).json({ success: true, categories: rows });
    } catch (error) {
        console.error("Public 솔루션 카테고리 조회 에러:", error);
        res.status(500).json({ success: false, message: '서버 오류가 발생했습니다.' });
    }
});

module.exports = router;