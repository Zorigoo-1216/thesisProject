  const Notification = require('../models/Notification');

  const sendNotification = async (userId, type, title, message) => {
    return await Notification.create({
      userId,
      type,
      title,
      message,
      isRead: false
    });
  };

  const sendBulkNotifications = async (users, job) => {
    const notifications = users.map(user => ({
      userId: user._id,
      type: 'job_match',
      title: 'Танд тохирох шинэ ажил байна',
      message: `${job.location} байршилд "${job.title}" ажил зарлагдлаа.`,
      isRead: false,
      createdAt: new Date()
    }));

    return await Notification.insertMany(notifications);
  };

  module.exports = {
    sendNotification,
    sendBulkNotifications
  };
