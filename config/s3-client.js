/**
 * 파일명: config/s3-client.js
 * 기능: AWS SDK의 S3 클라이언트 객체를 생성하고 설정합니다.
 * 수정 일시: 2025-07-03 09:37
 */
const aws = require('aws-sdk');

// AWS S3 클라이언트 설정
const s3 = new aws.S3({
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    region: process.env.AWS_REGION || 'ap-northeast-2'
});

module.exports = s3;