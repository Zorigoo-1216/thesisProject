const Notification = require('../models/Notification');

const notifyEligibleUsers = async (userId, job) => {
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

const createNotification = async (notification) => {
  return await Notification.create(notification);
}
const createManyNotification = async (notifications) => {
  return await Notification.insertMany(notifications);
}
module.exports = { notifyEligibleUsers , createNotification, createManyNotification };