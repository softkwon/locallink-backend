
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
 * 일반 파일을 S3에 그대로 업로드하고, URL을 반환하는 함수
 * @param {Buffer} fileBuffer - multer를 통해 받은 파일의 버퍼
 * @param {string} originalFilename - 파일의 원본 이름
 * @param {string} folder - S3 버킷 내에 저장될 폴더 이름
 * @param {number} userId - 요청을 보낸 사용자의 ID
 * @returns {Promise<string>} - S3에 업로드된 파일의 전체 URL
 */
async function uploadFileToS3(fileBuffer, originalFilename, folder, userId) {
    try {
        const filename = `${folder.slice(0, -1)}-${userId || 'user'}-${Date.now()}-${originalFilename}`;

        const uploadParams = {
            Bucket: process.env.AWS_S3_BUCKET_NAME,
            Key: `${folder}/${filename}`,
            Body: fileBuffer,
            // 브라우저가 파일을 열지 않고 다운로드하도록 설정
            ContentType: 'application/octet-stream', 
        };

        const result = await s3.upload(uploadParams).promise();
        return result.Location;

    } catch (error) {
        console.error(`S3 File Upload Error in folder ${folder}:`, error);
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
        const key = url.pathname.substring(1);

        const deleteParams = {
            Bucket: process.env.AWS_S3_BUCKET_NAME,
            Key: key
        };

        await s3.deleteObject(deleteParams).promise();
    } catch (error) {
        console.error(`S3 Delete Error for URL ${fileUrl}:`, error);
    }
}

module.exports = { uploadImageToS3, deleteImageFromS3 };