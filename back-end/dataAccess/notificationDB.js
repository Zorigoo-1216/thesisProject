const Notification = require('../models/Notification');

const createNotification = async (notification) => {
  return await Notification.create(notification);
}

module.exports = { createNotification };