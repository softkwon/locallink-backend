// db.js (수정된 최종본)
const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'locallink_db',
  password: '8773', // 본인의 PostgreSQL 비밀번호
  port: 5432,
});

module.exports = {
  // 기존의 간단한 쿼리용 함수 (다른 파일들에서 사용)
  query: (text, params) => pool.query(text, params),
  // 트랜잭션 처리를 위해 pool 객체를 직접 내보내도록 추가
  pool: pool 
};