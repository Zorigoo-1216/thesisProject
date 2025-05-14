const notificationService = require('../services/notificationService');

const getUserNotifications = async (req, res) => {
  try {
    const userId = req.params.userId || req.user?.id || req.user?._id;
    if (!userId) {
      return res.status(400).json({ success: false, message: "Хэрэглэгчийн ID олдсонгүй" });
    }

    console.log("📩 Getting notifications for user:", userId);
    const notifications = await notificationService.getNotificationsForUser(userId);
    console.log("📩 Notifications:", notifications);
    res.status(200).json({ success: true, data: notifications });
  } catch (error) {
    console.error("❌ getUserNotifications error:", error.message);
    res.status(500).json({ success: false, message: "Системийн алдаа" });
  }
};


const readNotification = async (req, res) => {
  try {
    const { notificationId } = req.params;
    const result = await notificationService.markNotificationAsRead(notificationId);
    res.status(200).json({ success: true, message: "Амжилттай тэмдэглэгдлээ", data: result });
  } catch (error) {
    console.error("❌ readNotification error:", error.message);
    res.status(500).json({ success: false, message: "Системийн алдаа" });
  }
};

module.exports = {
  getUserNotifications,
  readNotification,
};
