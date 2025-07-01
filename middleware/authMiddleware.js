// middleware/authMiddleware.js

const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  // 1. 요청 헤더에서 'Authorization' 값을 찾습니다.
  const authHeader = req.headers['authorization'];

  // 2. 헤더가 없거나 'Bearer '로 시작하지 않으면 에러 처리
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: '인증 토큰이 필요합니다. 로그인이 필요합니다.' });
  }

  // 3. 'Bearer ' 부분을 제외하고 실제 토큰 값만 추출합니다.
  const token = authHeader.split(' ')[1];

  try {
    // 4. JWT를 검증합니다. (.env 파일의 비밀 키 사용)
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // 5. 검증에 성공하면, 토큰의 페이로드(사용자 정보)를 req 객체에 저장합니다.
    req.user = decoded;

    // 6. 다음 로직으로 제어를 넘깁니다.
    next();
  } catch (error) {
    // 7. 토큰이 유효하지 않은 경우 (만료, 변조 등) 에러 처리
    return res.status(403).json({ success: false, message: '유효하지 않은 토큰입니다.' });
  }
};

module.exports = authMiddleware;