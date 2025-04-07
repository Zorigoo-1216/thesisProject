const express = require('express');
const router = express.Router();
const contractController = require('../controllers/contractController');

// router.get('/contracts/templates', authMiddleware, contractController.getTemplates); // Бэлэн гэрээний загварууд
// router.post('/contracts/generate-summary', authMiddleware, contractController.generateSummary); // Гэрээний хураангуй үүсгэх
// router.post('/contracts/send/:jobId', authMiddleware, contractController.sendContractToEmployees); // Гэрээг ажилчдад илгээх
// router.post('/contracts/confirm/:contractId', authMiddleware, contractController.confirmContractByEmployee); // Ажилчин гэрээ батлах
// router.get('/contracts/job/:jobId/summaries', authMiddleware, contractController.getSummariesByJob); // Ажлын гэрээний хураангуй
// router.get('/contracts/my', authMiddleware, contractController.getMyContracts); // Миний гэрээнүүд
// router.get('/contracts/job/:jobId', authMiddleware, contractController.getContractsByJob);
// router.post('/contracts/create', authMiddleware, contractController.createContract); // Гэрээ байгуулах
// router.get('/contracts/my', authMiddleware, contractController.getMyContracts);      // Миний гэрээнүүд
// router.get('/contracts/job/:jobId', authMiddleware, contractController.getContractsByJob); // Ажлын гэрээнүүд
