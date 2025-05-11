const NotificationDB = require('../dataAccess/notificationDB');
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
      await NotificationDB.createNotification(notification);

      // Socket-р илгээх (хэрэв онлайн байвал)
      sendSocketNotification(userId, notification);
    }
  } catch (error) {
    console.error('❌ sendNotification error:', error.message);
  }
};

module.exports = {
  sendNotification,
};
