const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER, 
        pass: process.env.EMAIL_PASS, 
    },
});

const sendEmail = async (to, subject, html) => {
    try {
        await transporter.sendMail({
            from: `"ESGlink" <${process.env.EMAIL_USER}>`,
            to: to,
            subject: subject,
            html: html,
        });
        console.log('Email sent successfully');
        return true;
    } catch (error) {
        console.error('Error sending email:', error);
        return false;
    }
};

module.exports = sendEmail;