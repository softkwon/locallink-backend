/**
 * 파일명: helpers/s3-helper.js
 * 기능: AWS S3 이미지 업로드 및 삭제를 처리하는 헬퍼 함수들
 * 수정 일시: 2025-07-03 10:48
 */
console.log("★★★ S3 Helper v2 (ACL Removed) is running! ★★★");


const s3 = require('../config/s3-client');
const sharp = require('sharp');
const path = require('path');

/**
 * 이미지를 리사이징하여 S3에 업로드하고, 최종 URL을 반환하는 함수
 * @param {Buffer} fileBuffer - multer를 통해 받은 파일의 버퍼
 * @param {string} originalFilename - 파일의 원본 이름
 * @param {string} folder - S3 버킷 내에 저장될 폴더 이름 (예: 'programs', 'news')
 * @param {number} userId - 요청을 보낸 사용자의 ID
 * @returns {Promise<string>} - S3에 업로드된 파일의 전체 URL
 */

/**
 * 파일명: helpers/s3-helper.js
 * 수정 위치: uploadImageToS3 함수 내부
 * 수정 일시: 2025-07-06 10:48
 */
async function uploadImageToS3(fileBuffer, originalFilename, folder, userId) {
    try {
        const processedImageBuffer = await sharp(fileBuffer)
            .resize({ width: 1200, fit: 'inside', withoutEnlargement: true })
            .toFormat('jpeg', { quality: 85 })
            .toBuffer();
        
        // ★★★ 파일 이름 생성 로직을 더 간단하고 안전하게 변경 ★★★
        const extension = path.extname(originalFilename);
        const filename = `${folder.slice(0, -1)}-${userId || 'user'}-${Date.now()}${extension}`;
        
        const uploadParams = {
            Bucket: process.env.AWS_S3_BUCKET_NAME,
            Key: `${folder}/${filename}`,
            Body: processedImageBuffer,
            ContentType: 'image/jpeg',
        };

        const result = await s3.upload(uploadParams).promise();
        return result.Location;

    } catch (error) {
        console.error(`S3 Upload Error in folder ${folder}:`, error);
        throw error;
    }
}

/**
 * S3에 업로드된 파일을 URL을 기반으로 삭제하는 함수
 * @param {string} fileUrl - 삭제할 파일의 전체 S3 URL
 */
async function deleteImageFromS3(fileUrl) {
    try {
        const url = new URL(fileUrl);
        const key = url.pathname.substring(1); // URL에서 키(파일 경로) 추출

        const deleteParams = {
            Bucket: process.env.AWS_S3_BUCKET_NAME,
            Key: key
        };

        await s3.deleteObject(deleteParams).promise();
    } catch (error) {
        console.error(`S3 Delete Error for URL ${fileUrl}:`, error);
        // 여기서 에러를 던지지 않는 이유는, DB 삭제는 성공해야 하기 때문입니다.
        // S3 파일 삭제 실패가 전체 로직을 중단시켜서는 안 됩니다.
    }
}

module.exports = { uploadImageToS3, deleteImageFromS3 };