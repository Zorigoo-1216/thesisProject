const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/:userId' ,  authMiddleware, notificationController.getUserNotifications);
router.put('/:notificationId/read', authMiddleware, notificationController.readNotification);



module.exports = router