// db.js (최종 수정본)
const { Pool } = require('pg');

// 환경 변수에서 DB 정보를 읽어옵니다.
// Render 서버에서는 Render 대시보드에 설정한 값이,
// 로컬에서는 .env 파일의 값이 사용됩니다.
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
  // Render와 같은 클라우드 DB에 연결하기 위한 필수 SSL 옵션
  ssl: {
    rejectUnauthorized: false
  }
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool: pool 
};