require('dotenv').config();
const express = require('express');
const cors = require('cors');

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
const notificationRoutes = require('./routes/notifications');

const app = express();


const allowedOrigins = [
    'http://127.0.0.1:5500', 
    'http://localhost:5500',
    'https://locallink-frontend.vercel.app',
    'https://esglink.co.kr',
    'https://www.esglink.co.kr'
];

const corsOptions = {
    origin: function (origin, callback) {
        if (!origin || allowedOrigins.indexOf(origin) !== -1) {
            callback(null, true);
        } else {
            callback(new Error('CORS에 의해 허용되지 않는 요청입니다.'));
        }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    credentials: true
};

app.use(cors(corsOptions));

app.use(express.json());
app.use(express.static('public'));

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
app.use('/api/notifications', notificationRoutes);


app.get('/', (req, res) => {
  res.send('Locallink Backend Server is running!');
});

const PORT = process.env.PORT || 3000; 
app.listen(PORT, () => {
    console.log(`서버가 http://localhost:${PORT} 에서 실행 중입니다.`);
});

