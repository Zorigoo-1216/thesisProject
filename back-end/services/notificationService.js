const notificationDB = require('../dataAccess/notificationDB');
const UserDb = require('../dataAccess/userDB');
const { sendSocketNotification } = require('../socket');

const sendNotification = async (userIds, notificationData) => {
  try {
    const ids = Array.isArray(userIds) ? userIds : [userIds];

    for (const userId of ids) {
      const user = await UserDb.getUserById(userId);
      if (!user) continue;

      const notification = {
        userId,
        title: notificationData.title,
        message: notificationData.message,
        type: notificationData.type || 'generic',
        isRead: false,
        createdAt: new Date()
      };

      // DB-д хадгалах
     const savedNotification = await notificationDB.createNotification(notification);

      // Socket-р илгээх (хэрэв онлайн байвал)
      sendSocketNotification(userId, savedNotification);
      return savedNotification;
    }
  } catch (error) {
    console.error('❌ sendNotification error:', error.message);
  }
};


const getNotificationsForUser = async (userId) => {
  return await notificationDB.findByUserId(userId);
};

const markNotificationAsRead = async (notificationId) => {
  return await notificationDB.markAsRead(notificationId);
};


module.exports = {
  sendNotification,
   getNotificationsForUser,
  markNotificationAsRead,
};
