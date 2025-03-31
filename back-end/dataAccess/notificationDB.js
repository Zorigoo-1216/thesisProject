const Notification = require('../models/Notification');

const sendJobMatchNotification = async (userId, job) => {
    const message = `Танд тохирох ажил байна: ${job.title}, Байршил: ${job.location}`;
    return await Notification.create({
        userId,
        type: 'job_match',
        title: 'Шинэ ажлын боломж',
        message,
        isRead: false,
        createdAt: new Date()
      });
};

module.exports = { sendJobMatchNotification };