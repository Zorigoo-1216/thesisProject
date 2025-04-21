const express = require('express');
const router = express.Router();
const jobProgressController = require('../controllers/jobProgressController');
const authenticate = require('../middleware/authMiddleware');

// Ажил эхлүүлэх хүсэлт илгээх (ажилтан)
router.post('/:jobId/start', authenticate, jobProgressController.startJob);

// Ажил эхлүүлэх хүсэлтүүдийг ажил олгогч харах
router.get('/:jobId/start-requests', authenticate, jobProgressController.getStartRequests);
// GET /api/jobprogress/:jobId/salary
router.get('/:jobId/salary', authenticate, jobProgressController.getWorkerSalary);

router.get('/:jobId/my-progress', authenticate, jobProgressController.getMyProgress);

// Ажил эхлүүлэхийг баталгаажуулах (ажил олгогч)
router.post('/:jobId/approve-start', authenticate, jobProgressController.confirmJobStart);

// Ажил дуусгасан тухай хүсэлт илгээх (ажилтан)
router.post('/:jobId/request-completion/:jobProgressId', authenticate, jobProgressController.requestCompletion);

// Ажил дуусгасан тухай хүсэлтүүдийг авах (ажил олгогч)
router.get('/:jobId/completion-requests', authenticate, jobProgressController.getCompletionRequests);

// Ажил дуусгасныг баталгаажуулах (ажил олгогч)
router.post('/:jobId/approve-completion', authenticate, jobProgressController.confirmCompletion);

// Ажил дуусгасныг няцаах (ажил олгогч)
router.post('/:jobId/reject-completion', authenticate, jobProgressController.rejectCompletion);

// Ажлын явцын жагсаалт харах
router.get('/:jobId/progresses', authenticate, jobProgressController.viewProgress);

// Нэг ажилчны явцын дэлгэрэнгүй харах
router.get('/:jobId/progresses/:progressId', authenticate, jobProgressController.viewProgressDetails);

module.exports = router;
