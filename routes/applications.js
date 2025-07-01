// routes/applications.js (2025-06-29 07:45:00)
const express = require('express');
const { stringify } = require('csv-stringify/sync');
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');
const checkPermission = require('../middleware/permissionMiddleware');
const router = express.Router();


// --------------------------------------------------
// --- 사용자 본인용 API (경로: /api/applications/me/...) ---
// --------------------------------------------------

// GET /me - 나의 신청 프로그램 목록 조회
router.get('/me', authMiddleware, async (req, res) => {
    const { userId } = req.user;
    try {
        const query = 'SELECT * FROM user_applications WHERE user_id = $1 ORDER BY created_at DESC';
        const { rows } = await db.query(query, [userId]);
        res.status(200).json({ success: true, applications: rows });
    } catch (error) {
        console.error("나의 신청 목록 조회 에러:", error);
        res.status(500).json({ success: false, message: "서버 에러" });
    }
});

// POST /me - 새 프로그램 신청
router.post('/me', authMiddleware, async (req, res) => {
    const { userId } = req.user;
    const { programId } = req.body;
    if (!programId) {
        return res.status(400).json({ success: false, message: "프로그램 ID가 필요합니다."});
    }
    try {
        const query = 'INSERT INTO user_applications (user_id, program_id, status) VALUES ($1, $2, $3) RETURNING id';
        await db.query(query, [userId, programId, '신청']);
        res.status(201).json({ success: true, message: '프로그램이 신청되었습니다. [나의 프로그램 신청 현황]에서 확인하세요.' });
    } catch (error) {
        if (error.code === '23505') { // unique_violation (중복 신청)
            return res.status(409).json({ success: false, message: '이미 신청한 프로그램입니다.' });
        }
        console.error("프로그램 신청 에러:", error);
        res.status(500).json({ success: false, message: "신청 처리 중 서버 에러 발생" });
    }
});

// DELETE /me/:applicationId - 신청 취소
router.delete('/me/:applicationId', authMiddleware, async (req, res) => {
    const { userId } = req.user;
    const { applicationId } = req.params;
    try {
        const query = 'DELETE FROM user_applications WHERE id = $1 AND user_id = $2';
        const { rowCount } = await db.query(query, [applicationId, userId]);
        if(rowCount === 0) {
            return res.status(404).json({ success: false, message: "취소할 신청 내역이 없거나 권한이 없습니다."});
        }
        res.status(200).json({ success: true, message: '신청이 취소되었습니다.' });
    } catch (error) {
        console.error("신청 취소 에러:", error);
        res.status(500).json({ success: false, message: "취소 처리 중 서버 에러 발생" });
    }
});


// ----------------------------------------------------
// --- 관리자용 API (경로: /api/applications/admin/...) ---
// ----------------------------------------------------

// GET /admin - 모든 프로그램 신청 현황 조회
router.get('/admin', authMiddleware, checkPermission(['super_admin', 'user_manager']), async (req, res) => {
    try {
        const query = `
            SELECT 
                ua.id, ua.status, ua.created_at, 
                u.company_name, u.manager_name, u.manager_phone, u.email, 
                p.title AS program_title, p.related_links 
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

// PATCH /admin/:applicationId/status - 신청 상태 변경
router.patch('/admin/:applicationId/status', authMiddleware, checkPermission(['super_admin', 'user_manager']), async (req, res) => {
    const { applicationId } = req.params;
    const { status } = req.body;
    if (!status) { 
        return res.status(400).json({ success: false, message: '상태 값이 필요합니다.' });
    }
    try {
        const query = 'UPDATE user_applications SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING id, status';
        const { rows } = await db.query(query, [status, applicationId]);
        if (rows.length === 0) {
            return res.status(404).json({ success: false, message: '해당 신청 내역을 찾을 수 없습니다.' });
        }
        res.status(200).json({ success: true, message: `상태가 '${rows[0].status}'(으)로 변경되었습니다.` });
    } catch (error) {
        console.error("신청 상태 변경 에러:", error);
        res.status(500).json({ success: false, message: '서버 에러' });
    }
});

// GET /admin/export - 신청 현황 CSV로 Export
router.get('/admin/export', authMiddleware, checkPermission(['super_admin', 'user_manager']), async (req, res) => {
    try {
        const query = `
            SELECT 
                ua.id, u.company_name, u.manager_name, u.manager_phone, u.email, 
                p.title AS program_title, p.related_links, ua.status, ua.created_at
            FROM user_applications ua
            JOIN users u ON ua.user_id = u.id
            JOIN esg_programs p ON ua.program_id = p.id
            ORDER BY ua.created_at DESC;
        `;
        const { rows } = await db.query(query);

        const dataForCsv = rows.map(row => {
            let organization_name = '-';
            if (row.related_links && row.related_links.length > 0) {
                organization_name = row.related_links[0].organization_name || '-';
            }
            return {
                '신청 ID': row.id,
                '회사명': row.company_name,
                '담당자': row.manager_name,
                '전화번호': row.manager_phone,
                '이메일': row.email,
                '신청 프로그램': row.program_title,
                '담당 단체': organization_name,
                '신청 상태': row.status,
                '신청일자': new Date(row.created_at).toLocaleString('ko-KR')
            };
        });

        const csvString = stringify(dataForCsv, { header: true });
        res.setHeader('Content-Type', 'text/csv; charset=utf-8');
        res.setHeader('Content-Disposition', `attachment; filename="applications-${Date.now()}.csv"`);
        res.status(200).end('\uFEFF' + csvString);
    } catch (error) {
        console.error("Export 에러:", error);
        res.status(500).send('Export 중 서버 에러 발생');
    }
});

// DELETE /me/:applicationId - 신청 취소
router.delete('/me/:applicationId', authMiddleware, async (req, res) => {
    const { userId } = req.user;
    const { applicationId } = req.params;
    try {
        const query = 'DELETE FROM user_applications WHERE id = $1 AND user_id = $2';
        const { rowCount } = await db.query(query, [applicationId, userId]);
        if(rowCount === 0) {
            return res.status(404).json({ success: false, message: "취소할 신청 내역이 없거나 권한이 없습니다."});
        }
        res.status(200).json({ success: true, message: '신청이 취소되었습니다.' });
    } catch (error) {
        console.error("신청 취소 에러:", error);
        res.status(500).json({ success: false, message: "취소 처리 중 서버 에러 발생" });
    }
});

module.exports = router;