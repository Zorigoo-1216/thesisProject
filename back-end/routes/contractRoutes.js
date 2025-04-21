const express = require('express');
const router = express.Router();
const contractController = require('../controllers/contractController');
const authMiddleware = require('../middleware/authMiddleware');


router.get('/by-job/:id', authMiddleware, contractController.getContractByJobId);
// Загвар үүсгэх
router.post('/createtemplate', authMiddleware, contractController.createContractTemplate);
// routes/contractRoutes.js
router.post('/generate-template', authMiddleware, contractController.generateAndReturnHTML);

// Загварын хураангуй
router.get('/template/:id/summary', authMiddleware, contractController.getContractTemplateSummary);

// Загвар edit хийх
router.put('/template/:id/edit', authMiddleware, contractController.editContract);

// Ажил олгогч гарын үсэг зурна
router.post('/template/:id/employer-sign', authMiddleware, contractController.employerSignContract);

// Ажил олгогч гэрээг ажилчдад илгээнэ
router.post('/template/:id/send', authMiddleware, contractController.sendContractToWorkers);

// Гэрээ үзэх
router.get('/by-job/:jobId/worker/:workerId', authMiddleware, contractController.getContractByJobAndWorker);

// Гэрээний хураангуй
router.get('/:id/summary', authMiddleware, contractController.getContractSummary);

// Ажилтан гарын үсэг зурна
router.put('/:id/worker-sign', authMiddleware, contractController.workerSignContract);

// Ажилтан татгалзана
router.put('/:id/reject', authMiddleware, contractController.workerRejectContract);

// Гэрээний түүх
router.get('/contracthistory', authMiddleware, contractController.getContractHistory);

module.exports = router;
