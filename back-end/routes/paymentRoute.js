const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const authenticate = require('../middleware/authMiddleware');

router.get('/job/:jobId', authenticate, paymentController.viewPaymentInfoByJob);

router.get('/job/:jobId/:userId', authenticate, paymentController.viewPaymentInfoByJobAndUser);

router.get('/user/:userId', authenticate, paymentController.getUserPaymentInfo);
router.get('/job/:jobId/:paymentId', authenticate, paymentController.getPaymentDetail)
router.get('/user/:userId/:paymentId', authenticate, paymentController.getPaymentDetail)
// Employer transfers 1 worker salary
router.post('/transfer/:paymentId', authenticate, paymentController.transferWorkerSalary);
// employer transfer many worker salary
router.post('/transfer', authenticate, paymentController.transferWorkersSalary);
router.put('/:jobId/:paymentId', authenticate, paymentController.markAsPaid)
// View payment info
module.exports = router;
