// middleware/permissionMiddleware.js

const checkPermission = (allowedRoles) => {
    return (req, res, next) => {
        // 이 미들웨어는 authMiddleware 뒤에서 실행되어 req.user가 있다고 가정합니다.
        if (req.user && allowedRoles.includes(req.user.role)) {
            // 로그인한 사용자의 역할(req.user.role)이 허용된 역할(allowedRoles) 목록에 포함되어 있으면, 통과
            next();
        } else {
            // 포함되어 있지 않으면, 권한 없음 에러를 보냅니다.
            res.status(403).json({ success: false, message: '이 기능에 접근할 권한이 없습니다.' });
        }
    };
};

module.exports = checkPermission;