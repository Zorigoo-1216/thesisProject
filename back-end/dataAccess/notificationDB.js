const Notification = require('../models/Notification');

const createNotification = async (notification) => {
  return await Notification.create(notification);
}
const findByUserId = async (userId) => {
  return await Notification.find({ userId }).sort({ createdAt: -1 });
};

const markAsRead = async (notificationId) => {
  return await Notification.findByIdAndUpdate(notificationId, { isRead: true }, { new: true });
};
module.exports = { createNotification, findByUserId, markAsRead };