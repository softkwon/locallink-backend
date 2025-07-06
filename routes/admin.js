// routes/admin.js
const express = require('express');
const { stringify } = require('csv-stringify/sync'); // ★★★ csv-stringify 불러오기 ★★★
const { parse } = require('csv-parse/sync'); // 파일 상단에 csv-parse/sync 추가
const stream = require('stream');  // ★★★ stream 불러오기 ★★★
const multer = require('multer'); // ★★★ multer 불러오기 ★★★
const sharp = require('sharp'); // ★★★ sharp 라이브러리 불러오기 ★★★
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');
const checkPermission = require('../middleware/permissionMiddleware'); // 새로 만든 권한 미들웨어
const { uploadImageToS3, deleteImageFromS3 } = require('../helpers/s3-helper');
const router = express.Router();

//지워도 된다는 함수들 체크필요//
const fs = require('fs'); // ★★★ 파일 시스템 모듈 불러오기 ★★★
const path = require('path');   // ★★★ path 불러오기 ★★★



// --- ▼▼▼ 파일 업로드 설정을 '메모리 저장소' 하나로 통일합니다. ▼▼▼ ---
const storage = multer.memoryStorage(); // 파일을 디스크가 아닌 메모리에 버퍼 형태로 저장
const upload = multer({ 
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 } // 5MB 용량 제한
});

// ★★★ 협력사 로고용 저장소 설정 추가 ★★★
const partnerStorage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'public/uploads/partners/'); // 저장 경로
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, 'partner-' + uniqueSuffix + path.extname(file.originalname));
    }
});
const uploadPartner = multer({ storage: partnerStorage, limits: { fileSize: 5 * 1024 * 1024 } });


/**
 * 파일명: routes/admin.js
 * 수정 위치: GET /api/admin/users
 * 수정 일시: 2025-07-06 09:00
 */
// GET /api/admin/users - 모든 사용자 목록 조회 (레벨 계산 로직 추가)
router.get(
    '/users',
    authMiddleware,
    checkPermission(['super_admin', 'user_manager']),
    async (req, res) => {
        try {
            // ★★★ 1. 사용자의 레벨 계산에 필요한 모든 데이터를 가져오는 쿼리로 수정 ★★★
            const query = `
                SELECT 
                    u.id, u.email, u.company_name, u.manager_name, u.manager_phone, u.role, u.created_at,
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
                ORDER BY u.id DESC
            `;
            const { rows } = await db.query(query);

            // ★★★ 2. 각 사용자의 레벨을 계산하여 데이터에 추가합니다. ★★★
            const usersWithLevel = rows.map(user => {
                let level = 1;
                if (user.has_completed_diagnosis) level = 2;
                if (user.highest_application_status) {
                    level = 3;
                    if (user.highest_application_status === '진행') level = 4;
                    if (user.highest_application_status === '완료') level = 5;
                }
                // 기존 user 객체에 level 정보를 추가하여 반환
                return { ...user, level: level };
            });

            res.status(200).json({ success: true, users: usersWithLevel });

        } catch (error) {
            console.error("관리자용 사용자 목록 조회 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

// --- ▼▼▼ 역할 변경 API 추가 (최고 관리자 전용) ▼▼▼ ---
router.put(
    '/users/:userId/role',
    authMiddleware,
    checkPermission(['super_admin']), // 오직 최고 관리자만 역할을 변경 가능
    async (req, res) => {
        const { userId } = req.params;
        const { role } = req.body;

        // 허용된 역할 목록
        const allowedRoles = ['user', 'content_manager', 'user_manager', 'super_admin'];
        if (!role || !allowedRoles.includes(role)) {
            return res.status(400).json({ success: false, message: '유효하지 않은 역할입니다.' });
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

// --- ▼▼▼ 사용자 삭제 API 추가 (최고 관리자 전용) ▼▼▼ ---
router.delete(
    '/users/:userId',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        const { userId: targetUserId } = req.params; // 삭제 대상 ID
        const currentUserId = req.user.userId; // 현재 로그인된 관리자 ID

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

// --- ▼▼▼ 문의 관리 API 추가 ▼▼▼ ---
// GET /api/admin/inquiries - 모든 문의 조회
router.get('/inquiries', authMiddleware, checkPermission(['super_admin', 'user_manager']), async (req, res) => {
    try {
        const { rows } = await db.query('SELECT * FROM inquiries ORDER BY created_at DESC');
        res.status(200).json({ success: true, inquiries: rows });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

// PUT /api/admin/inquiries/:id/status - 문의 상태 변경
router.put('/inquiries/:id/status', authMiddleware, checkPermission(['super_admin', 'user_manager']), async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;
    try {
        const { rowCount } = await db.query('UPDATE inquiries SET status = $1 WHERE id = $2', [status, id]);
        if (rowCount === 0) return res.status(404).json({ success: false, message: '문의를 찾을 수 없습니다.' });
        res.status(200).json({ success: true, message: '상태가 변경되었습니다.' });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

// DELETE /api/admin/inquiries/:id - 문의 삭제
router.delete('/inquiries/:id', authMiddleware, checkPermission(['super_admin']), async (req, res) => {
    const { id } = req.params;
    try {
        const { rowCount } = await db.query('DELETE FROM inquiries WHERE id = $1', [id]);
        if (rowCount === 0) return res.status(404).json({ success: false, message: '문의를 찾을 수 없습니다.' });
        res.status(200).json({ success: true, message: '문의가 삭제되었습니다.' });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

// --- ▼▼▼ 문의 관리 API (탭 필터링, Export 기능 추가) ▼▼▼ ---
// GET /api/admin/inquiries - 모든 문의 조회 (타입별 필터링 추가)
// GET /api/admin/inquiries - 모든 문의 조회
router.get('/inquiries', authMiddleware, checkPermission(['super_admin', 'user_manager']), async (req, res) => {
    const { type } = req.query; // 탭 필터링을 위한 타입
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

// GET /api/admin/inquiries/export - 문의 내역 Export
router.get('/inquiries/export', authMiddleware, checkPermission(['super_admin', 'user_manager']), async (req, res) => {
    try {
        const { rows } = await db.query('SELECT * FROM inquiries ORDER BY created_at DESC');
        const csvString = stringify(rows, { header: true });
        res.setHeader('Content-Type', 'text/csv; charset=utf-8');
        res.setHeader('Content-Disposition', `attachment; filename="inquiries-${Date.now()}.csv"`);
        res.status(200).end('\uFEFF' + csvString);
    } catch (error) { res.status(500).send('Export 중 서버 에러 발생'); }
});


// --- ▼▼▼ 모든 질문 목록 조회 API 추가 (최고 관리자, 콘텐츠 관리자 전용) ▼▼▼ ---
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

// --- ▼▼▼ 특정 질문 정보 조회 API 추가 (관리자 전용) ▼▼▼ ---
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

// --- ▼▼▼ 특정 질문 수정 API 추가 ▼▼▼ ---
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

// --- ▼▼▼ 모든 채점 규칙 조회 API 추가 (최고 관리자 전용) ▼▼▼ ---
router.get(
    '/scoring-rules',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    async (req, res) => {
        const { type } = req.query;
        try {
            // ★★★ JOIN 구문을 추가하여 survey_questions의 question_text를 함께 가져옵니다. ★★★
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

// --- ▼▼▼ 특정 채점 규칙 수정 API 추가 (최고 관리자, 콘텐츠 관리자 전용) ▼▼▼ ---
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

// --- ▼▼▼ 특정 질문 삭제 API 추가 (최고 관리자 전용) ▼▼▼ ---
router.delete(
    '/questions/:id',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        try {
            const { id } = req.params;
            // 중요: 이 질문을 사용하는 다른 데이터(답변, 채점규칙 등)와의 관계를 고려해야 합니다.
            // 지금은 먼저 답변과 채점 규칙에서 해당 질문을 참조하는 데이터를 삭제합니다.
            await db.query('DELETE FROM diagnosis_answers WHERE question_code = (SELECT question_code FROM survey_questions WHERE id = $1)', [id]);
            await db.query('DELETE FROM scoring_rules WHERE question_code = (SELECT question_code FROM survey_questions WHERE id = $1)', [id]);
            
            // 그 다음 질문 자체를 삭제합니다.
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

// --- ▼▼▼ 신규 질문 및 채점 규칙 동시 생성 API 추가 ▼▼▼ ---
router.post(
    '/questions',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']), // 권한을 content_manager도 포함하도록 수정
    async (req, res) => {
        // ★★★ 1. req.body에서 scoring_method를 명확하게 받아옵니다. ★★★
        const { 
            question_code, esg_category, question_text, question_type, 
            options, explanation, display_order, 
            next_question_default, next_question_if_yes, next_question_if_no, 
            benchmark_metric, diagnosis_type, scoring_method 
        } = req.body;

        const client = await db.pool.connect();
        try {
            await client.query('BEGIN');

            // ★★★ 2. INSERT 쿼리에 scoring_method 컬럼을 추가합니다. ★★★
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

            // '채점 방식'에 따라 다른 기본 채점 규칙을 생성합니다.
            if (scoring_method === 'benchmark_comparison' && benchmark_metric) {
                const ruleQuery = `INSERT INTO scoring_rules (question_code, answer_condition, score, esg_category) VALUES ($1, $2, $3, $4);`;
                const benchmarkCommand = `BENCHMARK_${benchmark_metric.replace('_avg', '').toUpperCase()}`;
                await client.query(ruleQuery, [question_code, '*', benchmarkCommand, esg_category]);
            } else { // 'direct_score' 방식일 경우
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

// --- ▼▼▼ 질문 순서 변경 API 추가 ▼▼▼ ---
router.post(
    '/questions/reorder',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        const { questionId, direction } = req.body; // questionId: 이동할 질문의 id, direction: 'up' 또는 'down'

        const client = await db.pool.connect();
        try {
            await client.query('BEGIN');

            // 1. 현재 질문의 순서(display_order)를 가져옵니다.
            const currentQRes = await client.query('SELECT display_order FROM survey_questions WHERE id = $1', [questionId]);
            if (currentQRes.rows.length === 0) throw new Error('해당 질문을 찾을 수 없습니다.');
            const currentOrder = currentQRes.rows[0].display_order;

            let otherQRes;
            // 2. 바꿀 대상 질문(otherQ)을 찾습니다.
            if (direction === 'up') {
                // 현재 순서보다 작은 것들 중 가장 큰 것을 찾습니다 (바로 위 질문)
                otherQRes = await client.query('SELECT id, display_order FROM survey_questions WHERE display_order < $1 ORDER BY display_order DESC LIMIT 1', [currentOrder]);
            } else { // direction === 'down'
                // 현재 순서보다 큰 것들 중 가장 작은 것을 찾습니다 (바로 아래 질문)
                otherQRes = await client.query('SELECT id, display_order FROM survey_questions WHERE display_order > $1 ORDER BY display_order ASC LIMIT 1', [currentOrder]);
            }
            
            // 3. 바꿀 대상이 있으면, 두 질문의 display_order 값을 서로 맞바꿉니다.
            if (otherQRes.rows.length > 0) {
                const otherQuestion = otherQRes.rows[0];
                
                // 현재 질문의 순서를 위/아래 질문의 순서로 변경
                await client.query('UPDATE survey_questions SET display_order = $1 WHERE id = $2', [otherQuestion.display_order, questionId]);
                // 위/아래 질문의 순서를 현재 질문의 원래 순서로 변경
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

// --- ▼▼▼ 벤치마크 지표 목록 조회 API 추가 ▼▼▼ ---
router.get(
    '/average-metrics',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        try {
            // information_schema.columns는 DB의 테이블 구조(메타데이터)를 조회하는 표준 방식입니다.
            const query = `
                SELECT column_name 
                FROM information_schema.columns
                WHERE table_name = 'industry_averages' 
                  AND column_name LIKE '%_avg';
            `;
            const { rows } = await db.query(query);
            // ['ghg_emissions_avg', 'energy_usage_avg', ...] 와 같은 배열로 변환
            const metrics = rows.map(row => row.column_name);
            res.status(200).json({ success: true, metrics: metrics });
        } catch (error) {
            console.error('벤치마크 지표 목록 조회 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

// --- ▼▼▼ 모든 산업 평균 데이터 조회 API 추가 ▼▼▼ ---
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

// --- ▼▼▼ 특정 산업 평균 데이터 수정 API 추가 ▼▼▼ ---
router.put(
    '/industry-averages/:id',
    authMiddleware,
    checkPermission(['super_admin']),
    async (req, res) => {
        const { id } = req.params;
        // 요청 body에서 모든 숫자 필드를 받아옵니다.
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



// --- ▼▼▼ 모든 벤치마크 채점 규칙 조회 API 추가 ▼▼▼ ---
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

// --- ▼▼▼ 특정 벤치마크 채점 규칙 수정 API 추가 ▼▼▼ ---
router.put(
    '/benchmark-rules/:id',
    authMiddleware,
    checkPermission(['super_admin', ]),
    async (req, res) => {
        const { id } = req.params;
        const { score, upper_bound, description } = req.body;

        // score와 upper_bound는 필수 값으로 검증
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

// --- ▼▼▼ ESG 추천 프로그램 관리 API (CRUD) 추가 ▼▼▼ ---
// GET /api/admin/programs - 모든 프로그램 목록 조회
router.get(
    '/programs',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    async (req, res) => {
        try {
            const { rows } = await db.query('SELECT * FROM esg_programs ORDER BY id ASC');
            res.status(200).json({ success: true, programs: rows });
        } catch (error) {
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

// POST /api/admin/programs - 새 프로그램 추가
// routes/admin.js

// POST /programs - 새 프로그램 생성 (파일과 텍스트를 한 번에 처리)
router.post(
    '/programs',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    upload.array('newImages'), 
    async (req, res) => {
    
    const client = await db.pool.connect();
    try {
        await client.query('BEGIN');

        const { 
            title, program_code, esg_category, program_overview, risk_text, risk_description,
            content, economic_effects, related_links, opportunity_effects, service_regions, imageCounts
        } = req.body;

        if (!title || !program_code || !esg_category) {
            return res.status(400).json({ success: false, message: '필수 필드를 모두 입력해주세요.' });
        }
        
        const parsedContent = JSON.parse(content);
        const parsedImageCounts = imageCounts ? JSON.parse(imageCounts) : [];
        
        // ★★★ 1. 모든 새 이미지를 S3에 먼저 업로드하고 URL 목록을 받습니다. ★★★
        const uploadedUrls = [];
        if (req.files && req.files.length > 0) {
            for (const file of req.files) {
                const imageUrl = await uploadImageToS3(file.buffer, file.originalname, 'programs', req.user.userId);
                uploadedUrls.push(imageUrl);
            }
        }
        
        // ★★★ 2. 업로드된 S3 URL을 content 데이터에 올바르게 분배합니다. ★★★
        let urlPointer = 0;
        for (let i = 0; i < parsedContent.length; i++) {
            const countForThisSection = parsedImageCounts[i] || 0;
            if (countForThisSection > 0) {
                const imagesForThisSection = uploadedUrls.slice(urlPointer, urlPointer + countForThisSection);
                if (!parsedContent[i].images) {
                    parsedContent[i].images = [];
                }
                // 이제 파일명이 아닌 전체 S3 URL이 저장됩니다.
                parsedContent[i].images.push(...imagesForThisSection);
                urlPointer += countForThisSection;
            }
        }
        
        const query = `
            INSERT INTO esg_programs 
                (title, program_code, esg_category, program_overview, content, economic_effects, related_links, risk_text, risk_description, opportunity_effects, service_regions) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING id;
        `;
        const values = [
            title, program_code, esg_category, program_overview,
            JSON.stringify(parsedContent), economic_effects, related_links,
            risk_text, risk_description, opportunity_effects, service_regions.split(',')
        ];
        
        await client.query(query, values);
        await client.query('COMMIT');
        res.status(201).json({ success: true, message: '프로그램이 성공적으로 생성되었습니다.' });

    } catch (error) {
        await client.query('ROLLBACK');
        console.error('프로그램 생성 에러:', error);
        if (error.code === '23505' && error.constraint === 'esg_programs_program_code_key') {
            return res.status(409).json({ success: false, message: '이미 사용 중인 프로그램 코드입니다.' });
        }
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    } finally {
        client.release();
    }
});

/**
 * 파일명: routes/admin.js
 * 수정 위치: PUT /api/admin/programs/:id
 * 수정 일시: 2025-07-06 08:35
 */
router.put(
    '/programs/:id', 
    authMiddleware, 
    checkPermission(['super_admin', 'content_manager']),
    upload.array('newImages'), // 새로 추가될 이미지를 받습니다.
    async (req, res) => {
        
    const { id } = req.params;
    const client = await db.pool.connect();
    try {
        await client.query('BEGIN');
        
        // 1. DB에서 수정 전의 기존 이미지 URL 목록을 미리 가져옵니다.
        const oldProgramRes = await client.query('SELECT content FROM esg_programs WHERE id = $1', [id]);
        const oldImageUrls = new Set();
        if (oldProgramRes.rows.length > 0 && oldProgramRes.rows[0].content) {
            oldProgramRes.rows[0].content.forEach(section => {
                if (section.images) section.images.forEach(imgUrl => oldImageUrls.add(imgUrl));
            });
        }

        const { 
            title, program_code, esg_category, program_overview, risk_text, risk_description,
            content, economic_effects, related_links, opportunity_effects, service_regions
        } = req.body;

        const parsedContent = JSON.parse(content);
        
        // 2. 새로 업로드된 이미지들을 S3에 올리고 URL 목록을 받습니다.
        const newImageUrls = [];
        if (req.files && req.files.length > 0) {
            // Promise.all을 사용해 여러 파일을 동시에 업로드합니다.
            const uploadPromises = req.files.map(file => 
                uploadImageToS3(file.buffer, file.originalname, 'programs', req.user.userId)
            );
            const resolvedUrls = await Promise.all(uploadPromises);
            newImageUrls.push(...resolvedUrls);
        }
        
        // 3. 프론트엔드에서 보낸 '남겨진 이미지'와 '새로운 이미지'를 합칩니다.
        // (이 로직은 프론트엔드에서 content 데이터를 어떻게 보내주는지에 따라 달라질 수 있습니다.)
        // 가장 단순한 예: 첫 번째 섹션에 새 이미지를 모두 추가
        if (parsedContent.length > 0) {
            if (!parsedContent[0].images) parsedContent[0].images = [];
            // 기존 이미지 URL과 새 이미지 URL을 합칩니다.
            // (프론트에서 이미 기존 URL을 content에 포함해서 보냈다면, newImageUrls만 추가)
            parsedContent[0].images.push(...newImageUrls);
        }

        // 4. 수정 후의 최종 이미지 URL 목록과 비교하여 삭제된 이미지를 찾습니다.
        const finalImageUrls = new Set();
        parsedContent.forEach(section => {
            if (section.images) section.images.forEach(imgUrl => finalImageUrls.add(imgUrl));
        });

        const imagesToDelete = [...oldImageUrls].filter(url => !finalImageUrls.has(url));

        // 5. S3에서 삭제된 이미지들을 제거합니다.
        if (imagesToDelete.length > 0) {
            await Promise.all(imagesToDelete.map(url => deleteImageFromS3(url)));
        }

        // 6. DB에 최종 데이터를 업데이트합니다.
        const query = `
            UPDATE esg_programs SET 
                title = $1, program_code = $2, esg_category = $3, content = $4, 
                economic_effects = $5, related_links = $6, program_overview = $7,
                risk_text = $8, risk_description = $9, opportunity_effects = $10,
                service_regions = $11
            WHERE id = $12
        `;
        const values = [
            title, program_code, esg_category, 
            JSON.stringify(parsedContent), economic_effects, related_links,
            program_overview, risk_text, risk_description,
            opportunity_effects, service_regions.split(','),
            id
        ];
        
        await client.query(query, values);
        await client.query('COMMIT');
        res.status(200).json({ success: true, message: '프로그램이 성공적으로 수정되었습니다.' });

    } catch (error) {
        await client.query('ROLLBACK');
        console.error('프로그램 수정 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    } finally {
        client.release();
    }
});

// GET /api/admin/programs/:id - 특정 프로그램 하나만 조회
/**
 * 파일명: routes/admin.js
 * 수정 위치: DELETE /api/admin/programs/:id
 * 기능: 옛날 데이터가 있어도 서버가 다운되지 않도록 수정
 */
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
                            // ★★★ S3 주소(http로 시작)일 경우에만 삭제 목록에 추가 ★★★
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
            
            // 이하 DB 삭제 로직은 기존과 동일
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
            console.error('프로그램 삭제 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러' });
        } finally {
            client.release();
        }
    }
);

/**
 * 파일명: routes/admin.js
 * 수정 위치: 특정 프로그램 조회 API 추가
 * 수정 일시: 2025-07-03 16:59
 */

// GET /api/admin/programs/:id - 특정 프로그램 정보 조회
router.get(
    '/programs/:id',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    async (req, res) => {
        const { id } = req.params;
        try {
            const { rows } = await db.query('SELECT * FROM esg_programs WHERE id = $1', [id]);
            if (rows.length === 0) {
                return res.status(404).json({ success: false, message: '해당 프로그램을 찾을 수 없습니다.' });
            }
            res.status(200).json({ success: true, program: rows[0] });
        } catch (error) {
            console.error('프로그램 상세 조회 에러:', error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

/**
 * 프로그램 상태 변경(발행/초안) API
 */
router.patch('/programs/:id/status', authMiddleware, checkPermission(['super_admin']), async (req, res) => {
    const { id } = req.params;
    const { status } = req.body; // 'published' 또는 'draft' 값을 받습니다.

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




// POST /api/admin/upload-program-images - 프로그램 이미지 업로드
/**
 * 파일명: routes/admin.js
 * 수정 위치: POST /api/admin/upload-program-images
 * 수정 일시: 2025-07-03 10:35
 */
router.post(
    '/upload-program-images',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    upload.array('programImages', 10), 
    async (req, res) => {
        if (!req.files || req.files.length === 0) {
            return res.status(400).json({ success: false, message: '업로드된 파일이 없습니다.' });
        }
        try {
            // ★★★ 여러 파일을 동시에 S3에 업로드하고, 완료되면 URL 목록을 받습니다. ★★★
            const imageUrls = await Promise.all(
                req.files.map(file => 
                    uploadImageToS3(file.buffer, file.originalname, 'programs', req.user.userId)
                )
            );
            
            // ★★★ 성공 시, 로컬 파일명이 아닌 최종 S3 URL 목록을 반환합니다. ★★★
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


// POST /api/admin/benchmark-rules - 새 벤치마크 규칙 추가
router.post(
    '/benchmark-rules',
    authMiddleware,
    checkPermission(['super_admin', '']),
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

// DELETE /api/admin/benchmark-rules/:id - 특정 벤치마크 규칙 삭제
router.delete(
    '/benchmark-rules/:id',
    authMiddleware,
    checkPermission(['super_admin', '']),
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

// --- ▼▼▼ 전략 추천 규칙 관리 API (CRUD) 추가 ▼▼▼ ---
// GET /api/admin/strategy-rules - 모든 전략 규칙 조회
router.get(
    '/strategy-rules',
    authMiddleware,
    checkPermission(['super_admin', '']),
    async (req, res) => {
        try {
            // 이제 esg_programs 테이블과 JOIN하여 추천 프로그램의 제목도 함께 가져옵니다.
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

// POST /api/admin/strategy-rules - 새 전략 규칙 추가
router.post(
    '/strategy-rules',
    authMiddleware,
    checkPermission(['super_admin', '']),
    async (req, res) => {
        const { description, conditions, recommended_program_code, priority } = req.body;
        try {
            const query = 'INSERT INTO strategy_rules (description, conditions, recommended_program_code, priority) VALUES ($1, $2, $3, $4) RETURNING id';
            // conditions 객체를 JSON 문자열로 변환하여 저장합니다.
            const values = [description, JSON.stringify(conditions), recommended_program_code, priority];
            await db.query(query, values);
            res.status(201).json({ success: true, message: '새로운 전략 규칙이 추가되었습니다.' });
        } catch (error) {
            console.error("전략 규칙 추가 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
    }
);

// PUT /api/admin/strategy-rules/:id - 특정 전략 규칙 수정
router.put(
    '/strategy-rules/:id',
    authMiddleware,
    checkPermission(['super_admin', '']),
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

// DELETE /api/admin/strategy-rules/:id - 특정 전략 규칙 삭제
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

// --- ▼▼▼ 산업별 ESG 이슈 관리 API (CRUD) 추가 ▼▼▼ ---
// GET /api/admin/industry-issues - 모든 산업 이슈 조회
router.get('/industry-issues', authMiddleware, checkPermission(['super_admin', '']), async (req, res) => {
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

// POST /api/admin/industry-issues
router.post('/industry-issues', authMiddleware, checkPermission(['super_admin', '']), async (req, res) => {
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

// PUT /api/admin/industry-issues/:id
router.put('/industry-issues/:id', authMiddleware, checkPermission(['super_admin', '']), async (req, res) => {
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

// DELETE /api/admin/industry-issues/:id
router.delete('/industry-issues/:id', authMiddleware, checkPermission(['super_admin', '']), async (req, res) => {
    const { id } = req.params;
    try {
        const { rowCount } = await db.query('DELETE FROM industry_esg_issues WHERE id = $1', [id]);
        if (rowCount === 0) return res.status(404).json({ success: false, message: '해당 항목을 찾을 수 없습니다.' });
        res.status(200).json({ success: true, message: '산업별 이슈가 삭제되었습니다.' });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

// --- ▼▼▼ 산업별 ESG 이슈 데이터 Export API 추가 ▼▼▼ ---
router.get(
    '/industry-issues/export',
    authMiddleware,
    checkPermission(['super_admin', '']),
    async (req, res) => {
        try {
            const { rows } = await db.query('SELECT id, industry_code, key_issue, opportunity, threat, linked_metric, notes FROM industry_esg_issues ORDER BY id ASC');
            
            const columns = ['id', 'industry_code', 'key_issue', 'opportunity', 'threat', 'linked_metric', 'notes'];
            const csvString = stringify(rows, { header: true, columns: columns });

            res.setHeader('Content-Type', 'text/csv; charset=utf-8');
            res.setHeader('Content-Disposition', `attachment; filename="industry-issues-${Date.now()}.csv"`);
            
            // 한글 깨짐 방지를 위한 BOM 추가
            const csvWithBom = '\uFEFF' + csvString;
            res.status(200).end(csvWithBom);

        } catch (error) {
            console.error("데이터 Export 에러:", error);
            res.status(500).send('Export 중 서버 에러 발생');
        }
    }
);

// --- ▼▼▼ 산업별 ESG 이슈 데이터 Import API 추가 ▼▼▼ ---
router.post(
    '/industry-issues/import',
    authMiddleware,
    checkPermission(['super_admin', '']),
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

                // ★★★ INSERT 대신 UPDATE만 수행하는 단순한 쿼리로 변경 ★★★
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
                
                // 각 행이 실제로 업데이트되었는지 확인하는 로그 추가
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

// GET /company-size-issues - 모든 규모별 이슈 조회
router.get('/company-size-issues', authMiddleware, async (req, res) => {
    try {
        const { rows } = await db.query('SELECT * FROM company_size_esg_issues');
        res.status(200).json({ success: true, issues: rows });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

// PUT /company-size-issues - 모든 규모별 이슈 일괄 수정
router.put('/company-size-issues', authMiddleware, checkPermission(['super_admin', 'content_manager']), async (req, res) => {
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

// GET /api/admin/regional-issues - 모든 지역 이슈 조회
router.get('/regional-issues', authMiddleware, checkPermission(['super_admin', '']), async (req, res) => {
    try {
        const query = 'SELECT * FROM regional_esg_issues ORDER BY display_order ASC';
        const { rows } = await db.query(query);
        res.status(200).json({ success: true, issues: rows });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

// POST /api/admin/regional-issues - 새 지역 이슈 추가
router.post('/regional-issues', authMiddleware, checkPermission(['super_admin', '']), async (req, res) => {
    const { region, esg_category, content } = req.body;
    try {
        const query = 'INSERT INTO regional_esg_issues (region, esg_category, content) VALUES ($1, $2, $3) RETURNING id';
        const values = [region, esg_category, content];
        await db.query(query, values);
        res.status(201).json({ success: true, message: '새로운 지역별 이슈가 추가되었습니다.' });
    } catch (error) {
            // ★★★ 중복 확인 if문을 삭제하여, 모든 오류를 서버 에러로 처리합니다. ★★★
            console.error("지역별 이슈 추가 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
        }
});

// PUT /api/admin/regional-issues/:id - 특정 지역 이슈 수정
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

// DELETE /api/admin/regional-issues/:id - 특정 지역 이슈 삭제
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

// --- ▼▼▼ 지역별 이슈 순서 변경 API 추가 ▼▼▼ ---
router.post(
    '/regional-issues/reorder',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
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
            } else { // down
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

// --- ▼▼▼ ESG 통계 리포트용 API (수정) ▼▼▼ ---
router.get(
    '/statistics/all-diagnoses',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    async (req, res) => {
        const { year } = req.query;
        try {
            // ★★★ 모든 컬럼을 명시적으로 나열하여 오류를 방지합니다. ★★★
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

// --- ▼▼▼ 통계용 연도 목록 API 추가 ▼▼▼ ---
router.get(
    '/statistics/available-years',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
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

// --- ▼▼▼ 통계 데이터 Export API (새로 추가) ▼▼▼ ---
router.get(
    '/statistics/all-diagnoses/export',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    async (req, res) => {
        try {
            // 1. 화면 표시용 API와 동일한, 모든 데이터를 가져오는 쿼리로 수정합니다.
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

            // 2. 모든 질문 코드를 수집하고 자연어 순으로 정렬합니다.
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

            // 3. 최종 데이터를 CSV 형식에 맞게 가공합니다.
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
            
            // 4. CSV로 변환하여 다운로드합니다.
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


// --- ▼▼▼ 산업 평균 점수 계산 엔진 API (최종 완성본) ▼▼▼ ---
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
            
            // 0점으로 처리할 분기용 질문 목록
            const zeroScoreQuestions = ['S-Q1', 'S-Q2', 'S-Q3', 'S-Q4', 'S-Q5', 'S-Q6', 'S-Q7', 'S-Q8', 'S-Q9', 'S-Q10', 'S-Q11', 'S-Q12', 'S-Q13', 'S-Q14', 'S-Q15', 'S-Q16'];

            for (const industry of allIndustries) {
                const industryAverages = allAverages.find(avg => avg.industry_code === industry.code);

                for (const question of simpleQuestions) {
                    let calculatedScore = null; // 기본적으로 null로 시작

                    // 2번 규칙: 분기용 질문은 0점으로 처리
                    if (zeroScoreQuestions.includes(question.question_code)) {
                        calculatedScore = 0;
                    }
                    // 1번 규칙: 벤치마크 비교 채점
                    else if (question.scoring_method === 'benchmark_comparison') {
                        calculatedScore = 50.00; // 기본 50점
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
                    // 2번 규칙: 답변 추정을 통한 일반 규칙 채점
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
                                     calculatedScore = 50.00; // 추정 규칙은 있지만, 값이 범위에 없는 경우
                                }
                            }
                        } else {
                             // 3번 규칙: 위 모든 경우에 해당하지 않는 나머지 (S-Q13_1 등)
                             calculatedScore = 50.00;
                        }
                    }

                    // 계산된 점수만 DB에 저장/수정합니다.
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

// GET /api/admin/benchmark-scores - 계산된 모든 산업 평균 점수 조회
router.get(
    '/benchmark-scores',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    async (req, res) => {
        try {
            // industry_benchmark_scores와 industries 테이블을 JOIN하여 산업명까지 함께 가져옵니다.
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

// PUT /api/admin/benchmark-scores/:id - 특정 산업 평균 점수 수정
router.put(
    '/benchmark-scores/:id',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    async (req, res) => {
        const { id } = req.params;
        const { average_score, notes } = req.body; // 수정할 데이터

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

// --- ▼▼▼ 답변 추정 규칙 관리 API (CRUD) 추가 ▼▼▼ ---

// GET /api/admin/answer-rules - 모든 답변 추정 규칙 조회
router.get('/answer-rules', authMiddleware, checkPermission(['super_admin', 'content_manager']), async (req, res) => {
    try {
        const { rows } = await db.query('SELECT * FROM average_to_answer_rules ORDER BY metric_name, lower_bound');
        res.status(200).json({ success: true, rules: rows });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

// POST /api/admin/answer-rules - 새 답변 추정 규칙 추가
router.post('/answer-rules', authMiddleware, checkPermission(['super_admin', 'content_manager']), async (req, res) => {
    const { metric_name, question_code, lower_bound, upper_bound, resulting_answer_value } = req.body;
    try {
        const query = 'INSERT INTO average_to_answer_rules (metric_name, question_code, lower_bound, upper_bound, resulting_answer_value) VALUES ($1, $2, $3, $4, $5)';
        await db.query(query, [metric_name, question_code, lower_bound, upper_bound, resulting_answer_value]);
        res.status(201).json({ success: true, message: '새로운 답변 추정 규칙이 추가되었습니다.' });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

// PUT /api/admin/answer-rules/:id - 특정 답변 추정 규칙 수정
router.put('/answer-rules/:id', authMiddleware, checkPermission(['super_admin', 'content_manager']), async (req, res) => {
    const { id } = req.params;
    const { lower_bound, upper_bound, resulting_answer_value } = req.body;
    try {
        const query = 'UPDATE average_to_answer_rules SET lower_bound = $1, upper_bound = $2, resulting_answer_value = $3 WHERE id = $4';
        const { rowCount } = await db.query(query, [lower_bound, upper_bound, resulting_answer_value, id]);
        if (rowCount === 0) return res.status(404).json({ success: false, message: '해당 규칙을 찾을 수 없습니다.' });
        res.status(200).json({ success: true, message: '규칙이 수정되었습니다.' });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

// DELETE /api/admin/answer-rules/:id - 특정 답변 추정 규칙 삭제
router.delete('/answer-rules/:id', authMiddleware, checkPermission(['super_admin', 'content_manager']), async (req, res) => {
    const { id } = req.params;
    try {
        const { rowCount } = await db.query('DELETE FROM average_to_answer_rules WHERE id = $1', [id]);
        if (rowCount === 0) return res.status(404).json({ success: false, message: '해당 규칙을 찾을 수 없습니다.' });
        res.status(200).json({ success: true, message: '규칙이 삭제되었습니다.' });
    } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
});

// GET /api/admin/content/:key - 특정 콘텐츠 조회 (관리자용)
router.get(
    '/content/:key',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    async (req, res) => {
        const { key } = req.params;
        try {
            const { rows } = await db.query('SELECT content_value FROM site_content WHERE content_key = $1', [key]);
            if (rows.length === 0) {
                // 키가 존재하지 않을 경우, 프론트에서 처리하도록 빈 배열 또는 객체를 보냅니다.
                const defaultValue = key === 'main_page_sections' ? [] : {};
                return res.status(200).json({ success: true, content: defaultValue });
            }
            res.status(200).json({ success: true, content: rows[0].content_value });
        } catch (error) {
            console.error(`콘텐츠 조회 에러 (key: ${key}):`, error);
            res.status(500).json({ success: false, message: '서버 에러' });
        }
    }
);

// --- ▼▼▼ 사이트 콘텐츠 수정 API 추가 ▼▼▼ ---
router.put(
    '/content/:key',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
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

// --- ▼▼▼ 페이지 콘텐츠 이미지 업로드 API 추가 ▼▼▼ ---
/**
 * 파일명: routes/admin.js
 * 수정 위치: POST /api/admin/upload-page-images
 * 수정 일시: 2025-07-03 10:37
 */
router.post(
    '/upload-page-images',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    upload.array('pageImages', 10),
    async (req, res) => {
        if (!req.files || req.files.length === 0) {
            return res.status(400).json({ success: false, message: '업로드된 파일이 없습니다.' });
        }
        try {
            // ★★★ 여러 파일을 동시에 S3에 업로드하고, 완료되면 URL 목록을 받습니다. ★★★
            const imageUrls = await Promise.all(
                req.files.map(file => 
                    uploadImageToS3(file.buffer, file.originalname, 'pages', req.user.userId)
                )
            );
            
            // ★★★ 성공 시, 최종 S3 URL 목록을 반환합니다. ★★★
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

/**
 * 파일명: routes/admin.js
 * 수정 위치: 협력사(Partners) 관리 API 전체
 * 수정 일시: 2025-07-04 02:41
 */
// GET /api/admin/partners - 모든 협력사 목록 조회 (수정 없음)
router.get(
    '/partners',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    async (req, res) => {
        try {
            const { rows } = await db.query('SELECT * FROM partners ORDER BY id ASC');
            res.status(200).json({ success: true, partners: rows });
        } catch (error) { res.status(500).json({ success: false, message: '서버 에러' }); }
    }
);

// POST /api/admin/partners - 새 협력사 추가 (S3 업로드 기능 포함)
router.post(
    '/partners',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    upload.single('partnerLogo'), // 'partnerLogo' 필드로 이미지 파일을 받습니다.
    async (req, res) => {
        const { name, link_url } = req.body;
        
        if (!req.file) {
            return res.status(400).json({ success: false, message: '로고 이미지를 선택해주세요.' });
        }

        try {
            // 1. S3 헬퍼를 사용해 이미지를 업로드하고 최종 URL을 받습니다.
            const logoUrl = await uploadImageToS3(req.file.buffer, req.file.originalname, 'partners', req.user.userId);

            // 2. DB에 텍스트 정보와 S3 이미지 URL을 저장합니다.
            const query = 'INSERT INTO partners (name, logo_url, link_url) VALUES ($1, $2, $3) RETURNING id';
            await db.query(query, [name, logoUrl, link_url]);
            
            res.status(201).json({ success: true, message: '새로운 협력사가 추가되었습니다.' });
        } catch (error) { 
            console.error("협력사 추가 에러:", error);
            res.status(500).json({ success: false, message: '서버 에러' }); 
        }
    }
);

// PUT /api/admin/partners/:id - 특정 협력사 수정 (S3 업로드 기능 포함)
router.put(
    '/partners/:id',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    upload.single('partnerLogo'), // 새 로고 파일이 있다면 'partnerLogo' 필드로 받습니다.
    async (req, res) => {
        const { id } = req.params;
        const { name, link_url, logo_url } = req.body; // logo_url은 새 파일이 없을 때의 기존 URL
        let finalLogoUrl = logo_url;

        try {
            // 1. 새로운 로고 파일이 함께 전송되었다면
            if (req.file) {
                // 1-1. 기존 로고가 있다면 S3에서 먼저 삭제합니다.
                if (logo_url && logo_url.startsWith('http')) {
                    await deleteImageFromS3(logo_url);
                }
                // 1-2. 새 로고를 S3에 업로드하고, 최종 URL을 업데이트합니다.
                finalLogoUrl = await uploadImageToS3(req.file.buffer, req.file.originalname, 'partners', req.user.userId);
            }
            
            // 2. DB 정보를 업데이트합니다.
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

// DELETE /api/admin/partners/:id - 특정 협력사 삭제 (S3 삭제 기능 포함)
router.delete(
    '/partners/:id',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    async (req, res) => {
        const { id } = req.params;
        try {
            // 1. DB에서 삭제할 로고의 URL을 먼저 가져옵니다.
            const logoRes = await db.query('SELECT logo_url FROM partners WHERE id = $1', [id]);
            const logoUrlToDelete = logoRes.rows[0]?.logo_url;

            // 2. DB에서 협력사 정보를 삭제합니다.
            const { rowCount } = await db.query('DELETE FROM partners WHERE id = $1', [id]);
            if (rowCount === 0) return res.status(404).json({ success: false, message: '항목을 찾을 수 없습니다.' });

            // 3. DB 삭제 성공 후, S3에서 로고 이미지를 삭제합니다.
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
// --- ▼▼▼ 사이트 메타 정보(공유 미리보기) 관리 API ▼▼▼ ---

// GET /api/admin/site-meta - 현재 사이트 메타 정보 조회
router.get('/site-meta', authMiddleware, async (req, res) => {
    try {
        const { rows } = await db.query('SELECT * FROM site_meta WHERE id = 1');
        if (rows.length === 0) {
            // 기본값이 없으면 초기화
            return res.json({ success: true, meta: { title: '', description: '', image_url: '' } });
        }
        res.json({ success: true, meta: rows[0] });
    } catch (error) {
        res.status(500).json({ success: false, message: '메타 정보 조회 중 서버 에러' });
    }
});

// PUT /api/admin/site-meta - 사이트 메타 정보 수정
router.put(
    '/site-meta',
    authMiddleware,
    checkPermission(['super_admin', 'content_manager']),
    upload.single('metaImage'), // 'metaImage' 필드로 새 썸네일 이미지를 받습니다.
    async (req, res) => {
        const { title, description, existing_image_url } = req.body;
        let finalImageUrl = existing_image_url;

        try {
            // 1. 새로운 썸네일 이미지가 업로드된 경우
            if (req.file) {
                // 1-1. 기존 이미지가 있었다면 S3에서 삭제
                if (existing_image_url && existing_image_url.startsWith('http')) {
                    await deleteImageFromS3(existing_image_url);
                }
                // 1-2. 새 이미지를 S3에 업로드하고 URL을 교체
                finalImageUrl = await uploadImageToS3(req.file.buffer, req.file.originalname, 'meta', req.user.userId);
            }

            // 2. DB에 메타 정보를 업데이트 (없으면 새로 생성 - ON CONFLICT)
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


// --- ▼▼▼ 시뮬레이터 매개변수 관리 API (조회, 수정) 추가 ▼▼▼ ---
// GET /api/admin/simulator-parameters - 모든 시뮬레이터 매개변수 조회
router.get(
    '/simulator-parameters',
    authMiddleware,
    checkPermission(['super_admin']), // 슈퍼 관리자만 접근 가능
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

// PUT /api/admin/simulator-parameters/:id - 특정 매개변수 수정
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

// GET /api/admin/industry-average-columns - 계산에 사용할 수 있는 산업 평균 데이터 컬럼 목록 조회
router.get('/industry-average-columns', authMiddleware, async (req, res) => {
    try {
        // information_schema.columns는 데이터베이스의 테이블 구조(메타데이터)를 조회하는 표준 방식입니다.
        const query = `
            SELECT column_name 
            FROM information_schema.columns
            WHERE table_schema = 'public' 
              AND table_name = 'industry_averages'
              AND column_name NOT IN ('id', 'industry_code', 'created_at', 'updated_at');
        `;
        const { rows } = await db.query(query);
        
        // 프론트엔드에서 사용하기 쉽게 문자열 배열로 변환합니다.
        // 결과 예시: ['carbon_emissions_avg', 'waste_generation_avg', ...]
        const columnNames = rows.map(row => row.column_name);
        
        res.status(200).json({ success: true, columns: columnNames });

    } catch (error) {
        console.error('산업 평균 데이터 컬럼 조회 에러:', error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

// GET /api/admin/applications - 모든 프로그램 신청 현황 조회
router.get('/applications', authMiddleware, checkPermission(['super_admin', 'user_manager']), async (req, res) => {
    try {
        // 여러 테이블을 JOIN하여 필요한 모든 정보를 한 번에 가져옵니다.
        const query = `
            SELECT 
                ua.id,
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

        // related_links(JSON)에서 첫 번째 단체명만 추출하여 새로운 속성으로 추가합니다.
        const processedRows = rows.map(row => {
            let organization_name = '-';
            if (row.related_links && row.related_links.length > 0) {
                organization_name = row.related_links[0].organization_name || '-';
            }
            // 기존 row 객체에 organization_name을 추가하고, 불필요한 related_links는 삭제
            delete row.related_links;
            return { ...row, organization_name };
        });

        res.status(200).json({ success: true, applications: processedRows });
    } catch (error) {
        console.error("신청 현황 조회 에러:", error);
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});

// GET /api/admin/news - 모든 소식 목록 조회
router.get('/news', authMiddleware, checkPermission(['super_admin', 'content_manager']), async (req, res) => {
    try {
        // ★★★ SELECT 절에 is_pinned 컬럼을 추가합니다. ★★★
        const query = 'SELECT id, title, category, status, created_at, is_pinned FROM news_posts ORDER BY id DESC';
        const { rows } = await db.query(query);
        res.status(200).json({ success: true, posts: rows });
    } catch (error) {
        console.error("관리자용 소식 목록 조회 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});



// --- 뉴스/소식 관리 API (신규, 수정, 삭제, 상세 조회 기능 추가) ---
// GET /api/admin/news/:id - 수정할 특정 게시물 정보 조회
router.get('/news/:id', authMiddleware, async (req, res) => {
    const { id } = req.params;
    try {
        // ★★★ SELECT 절에 is_pinned 컬럼을 추가합니다. ★★★
        const query = 'SELECT * FROM news_posts WHERE id = $1';
        const { rows } = await db.query(query, [id]);
        if (rows.length === 0) return res.status(404).json({ success: false, message: '게시물을 찾을 수 없습니다.' });
        res.status(200).json({ success: true, post: rows[0] });
    } catch (error) {
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

// PATCH /api/admin/news/:id/pin - 게시물 상단 고정 상태 변경
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

// POST /api/admin/news - 새 소식 저장 (FormData 방식)
router.post('/news', authMiddleware, checkPermission(['super_admin', 'content_manager']), upload.any(), async (req, res) => {
    const { title, category, status, content } = req.body;
    const { userId } = req.user; 
    
    try {
        const parsedContent = JSON.parse(content);
        
        // ★★★ S3 업로드 로직으로 수정 ★★★
        const finalContent = await Promise.all(parsedContent.map(async (section) => {
            const images = await Promise.all(section.images.map(async (placeholder) => {
                const file = req.files.find(f => f.fieldname === placeholder);
                if (file) {
                    // S3 헬퍼 함수를 호출하여 업로드하고 URL을 받습니다.
                    return await uploadImageToS3(file.buffer, file.originalname, 'news', userId);
                }
                return null;
            }));
            
            return { ...section, images: images.filter(Boolean) }; // null 값 제거
        }));
        
        // DB에 최종 저장
        const query = `INSERT INTO news_posts (title, content, category, status, author_id) VALUES ($1, $2, $3, $4, $5) RETURNING id`;
        const values = [title, JSON.stringify(finalContent), category, status || 'draft', userId];
        
        await db.query(query, values);
        res.status(201).json({ success: true, message: '소식이 성공적으로 등록되었습니다.' });

    } catch (error) {
        console.error("새 소식 저장 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});

// PUT /api/admin/news/:id - 게시물 수정
/**
 * 파일명: routes/admin.js
 * 수정 위치: PUT /api/admin/news/:id
 * 수정 일시: 2025-07-04 02:15
 */
router.put('/news/:id', authMiddleware, checkPermission(['super_admin', 'content_manager']), upload.any(), async (req, res) => {
    const { id } = req.params;
    const { title, category, status, content } = req.body;
    
    try {
        // --- 1. DB에서 수정 전의 기존 이미지 URL 목록을 미리 가져옵니다. ---
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
                // 이미 업로드된 URL인 경우 그대로 반환
                if (typeof imageOrPlaceholder === 'string' && imageOrPlaceholder.startsWith('http')) {
                    return imageOrPlaceholder;
                }
                // 새로운 파일(placeholder)인 경우, S3에 업로드하고 URL 반환
                const file = req.files.find(f => f.fieldname === imageOrPlaceholder);
                if (file) {
                    return await uploadImageToS3(file.buffer, file.originalname, 'news', req.user.userId);
                }
                return null;
            }));
            return { ...section, images: updatedImages.filter(Boolean) };
        }));

        // --- 2. 수정 후의 최종 이미지 URL 목록과 비교하여 삭제된 이미지를 찾습니다. ---
        const newImageUrls = new Set();
        finalContent.forEach(section => {
            if (section.images) section.images.forEach(imgUrl => newImageUrls.add(imgUrl));
        });

        const imagesToDelete = [...oldImageUrls].filter(url => !newImageUrls.has(url));
        
        // --- 3. S3에서 삭제된 이미지들을 제거합니다. ---
        if (imagesToDelete.length > 0) {
            await Promise.all(imagesToDelete.map(url => deleteImageFromS3(url)));
        }

        // 4. DB에 최종 데이터를 업데이트합니다.
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

// PATCH /api/admin/news/:id/status - 소식 상태 변경 
router.patch('/news/:id/status', authMiddleware, checkPermission(['super_admin']), async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;

    // --- 디버깅 로그 추가 ---
    console.log(`[API PATCH /news/:id/status] Received request...`);
    console.log(`  -> Post ID: ${id}`);
    console.log(`  -> New Status: ${status}`);

    if (!status) {
        return res.status(400).json({ success: false, message: '상태 값이 필요합니다.' });
    }

    try {
        const query = 'UPDATE news_posts SET status = $1 WHERE id = $2';
        const { rowCount } = await db.query(query, [status, id]);
        
        // --- 디버깅 로그 추가 ---
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

// DELETE /api/admin/news/:id - 게시물 삭제
router.delete('/news/:id', authMiddleware, checkPermission(['super_admin', 'content_manager']), async (req, res) => {
    const { id } = req.params;
    try {
        // 1. DB에서 삭제할 게시물의 이미지 URL들을 가져옵니다.
        const postRes = await db.query('SELECT content FROM news_posts WHERE id = $1', [id]);
        if (postRes.rows.length > 0 && postRes.rows[0].content) {
            const content = postRes.rows[0].content;
            const imagesToDelete = [];
            content.forEach(section => {
                if (section.images && Array.isArray(section.images)) {
                    imagesToDelete.push(...section.images);
                }
            });

            // 2. S3에서 해당 이미지들을 삭제합니다.
            if (imagesToDelete.length > 0) {
                await Promise.all(imagesToDelete.map(url => deleteImageFromS3(url)));
            }
        }

        // 3. DB에서 게시물 데이터를 삭제합니다.
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

// POST /api/admin/upload-news-image - 뉴스 이미지 업로드
router.post('/upload-news-image', authMiddleware, checkPermission(['super_admin', 'content_manager']), upload.array('newsImages', 3), async (req, res) => {
    if (!req.files || req.files.length === 0) {
        return res.status(400).json({ success: false, message: '업로드된 파일이 없습니다.' });
    }
    try {
        // ★★★ 여러 파일을 동시에 S3에 업로드하고, 완료되면 URL 목록을 받습니다. ★★★
        const imageUrls = await Promise.all(
            req.files.map(file => 
                uploadImageToS3(file.buffer, file.originalname, 'news', req.user.userId)
            )
        );
        
        // ★★★ 성공 시, 로컬 경로가 아닌 최종 S3 URL 목록을 반환합니다. ★★★
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

// GET /api/admin/site-content
router.get('/site-content', authMiddleware, checkPermission(['super_admin']), async (req, res) => {
    try {
        const [contentRes, sitesRes] = await Promise.all([
            db.query("SELECT * FROM site_content WHERE id = 1"),
            db.query("SELECT * FROM related_sites ORDER BY display_order")
        ]);
        res.status(200).json({ 
            success: true, 
            content: contentRes.rows[0] || {},
            relatedSites: sitesRes.rows 
        });
    } catch (e) { res.status(500).json({ success: false, message: '서버 에러' }); }
});


// ★★★ PUT /api/admin/site-content - 사이트 전체 콘텐츠 업데이트 (최종 완성본) ★★★
router.put('/site-content', authMiddleware, checkPermission(['super_admin']), upload.any(), async (req, res) => {
    const { footer_info, terms_of_service, privacy_policy, marketing_consent_text, related_sites, main_page_content } = req.body;
    const newImageFiles = req.files;
    const client = await db.pool.connect();

    try {
        await client.query('BEGIN');

        const parsedMainContent = JSON.parse(main_page_content);
        
        const finalMainContent = await Promise.all(parsedMainContent.map(async (section) => {
            const updatedImages = await Promise.all(section.images.map(async (imageOrPlaceholder) => {
                // 기존 S3 URL인 경우
                if (typeof imageOrPlaceholder === 'object' && imageOrPlaceholder.file.startsWith('https')) {
                    return imageOrPlaceholder;
                }
                
                // 새로운 파일인 경우 S3에 업로드
                const file = newImageFiles.find(f => f.fieldname === imageOrPlaceholder.file);
                if (file) {
                    const newImageUrl = await uploadImageToS3(file.buffer, file.originalname, 'pages', req.user.userId);
                    return { file: newImageUrl }; // 프론트엔드가 기대하는 { file: 'URL' } 형태로 반환
                }
                return null;
            }));
            
            return { ...section, images: updatedImages.filter(Boolean) };
        }));

        // DB 업데이트 로직은 기존과 동일
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

// DELETE /api/admin/users/:id - 특정 사용자 삭제
router.delete('/users/:id', authMiddleware, checkPermission(['super_admin']), async (req, res) => {
    const { id } = req.params;
    const adminId = req.user.userId;

    // 관리자 본인 계정은 삭제할 수 없도록 방지
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
        if (error.code === '23503') { // foreign_key_violation
             return res.status(400).json({ success: false, message: '해당 사용자는 다른 데이터(진단 이력, 게시물 등)와 연결되어 있어 삭제할 수 없습니다.' });
        }
        res.status(500).json({ success: false, message: '서버 에러가 발생했습니다.' });
    }
});






module.exports = router;