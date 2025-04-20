const NotificationDb = require('../dataAccess/notificationDB');
const JobDb = require('../dataAccess/jobDB');
const UserDb = require('../dataAccess/userDB');
const buildJobNotificationMessage = (job) => {
  return `${job.location} байршилд "${job.title}" ажил зарлагдлаа. Цалин: ${job.salary?.amount}₮/${job.salary?.type === 'hourly' ? 'цаг' : 'өдөр'}`;
};
// Ajiltand ajliin zar uusehed medegdel ilgeene
const sendBulkNotifications = async (users, job) => {
  const message = buildJobNotificationMessage(job);
  const notifications = users.map(user => ({
    userId: user._id,
    type: 'job_match',
    title: 'Танд тохирох шинэ ажил байна',
    message,
    isRead: false,
    createdAt: new Date()
  }));
  return await NotificationDb.createManyNotification(notifications);
  //return await Notification.insertMany(notifications);
};

// ajillah huselt ilgeesen medegdel ilgeene

const createNotification = async (notification) => {
  return await NotificationDb.createNotification(notification);
}

module.exports = {
  sendBulkNotifications,createNotification
};
