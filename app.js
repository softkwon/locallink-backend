// app.js

require('dotenv').config();
const express = require('express');
const cors = require('cors');

// 허용할 프론트엔드 주소 목록
const allowedOrigins = [
    'http://127.0.0.1:5500', 
    'http://localhost:5500',
    'https://locallink-frontend.vercel.app'
];

const corsOptions = {
    origin: function (origin, callback) {
        // ★★★ 디버깅을 위해 요청의 출처(origin)를 로그로 출력합니다. ★★★
        console.log('Request received from origin:', origin);

        // 요청의 출처(origin)가 없거나(Postman 등), 허용 목록에 있으면 허용
        if (!origin || allowedOrigins.indexOf(origin) !== -1) {
            callback(null, true);
        } else {
            callback(new Error('CORS에 의해 허용되지 않는 요청입니다.'));
        }
    },
    credentials: true
};

// --- 라우트 모듈 불러오기 ---
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const industryRoutes = require('./routes/industries');
const diagnosisRoutes = require('./routes/diagnoses');
const surveyRoutes = require('./routes/survey');
const averageRoutes = require('./routes/averages');
const adminRoutes = require('./routes/admin');
const contentRoutes = require('./routes/content');
const inquiryRoutes = require('./routes/inquiries');
const strategyRoutes = require('./routes/strategy');
const programRoutes = require('./routes/programs');
const applicationRoutes = require('./routes/applications');
const simulatorRoutes = require('./routes/simulator');
const newsRoutes = require('./routes/news');

const app = express();

// --- 미들웨어 설정 ---
app.use(cors(corsOptions));
app.use(express.json());
app.use(express.static('public'));

// --- API 라우트 연결 ---
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/industries', industryRoutes);
app.use('/api/diagnoses', diagnosisRoutes);
app.use('/api/survey', surveyRoutes);
app.use('/api/averages', averageRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/content', contentRoutes);
app.use('/api/inquiries', inquiryRoutes);
app.use('/api/strategy', strategyRoutes);
app.use('/api/programs', programRoutes);
app.use('/api/applications', applicationRoutes);
app.use('/api/simulator', simulatorRoutes);
app.use('/api/news', newsRoutes);

// 기본 라우트
app.get('/', (req, res) => {
  res.send('Locallink Backend Server is running!');
});

// 호스팅 환경에서 지정해주는 PORT를 사용하고, 없다면 3000번을 사용합니다.
const PORT = process.env.PORT || 3000; 
app.listen(PORT, () => {
    console.log(`서버가 http://localhost:${PORT} 에서 실행 중입니다.`);
});