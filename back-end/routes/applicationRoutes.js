

const express = require('express');
const router = express.Router();
const applicationController = require('../controllers/applicationController');
const authMiddleware = require('../middleware/authMiddleware');
// Ажилд хүсэлт илгээх
router.post('/apply', authMiddleware, applicationController.applyToJob);

// Ажилд хүсэлтийг хаах
router.delete('/apply/cancel/:id', authMiddleware, applicationController.cancelApplication);
// Ажиллах хүсэлт илгээсэн ажлууд
router.get('/myapplications',authMiddleware,  applicationController.getMyAppliedJobs);
// Миний бүх хүсэлт илгээсэн ажлын түүх
router.get('/myallapplications', authMiddleware, applicationController.getMyAllAppliedJobs);
// Ажиллах хүсэлт илгээсэн ажилчид 
router.get('/job/:jobId/applications', authMiddleware,  applicationController.getAppliedUsersByJob);
// Ажилчдыг сонгох, хэрэв ярилцлага байгаа бол ярилцлагад оруулах
router.post('/job/:id/select-from-application', authMiddleware,  applicationController.selectCandidates);
// Ярилцлагад орсон ажилчдыг сонгох, гэрээ байгуулах ажилчдыг сонгох
router.post('/job/:id/select-from-interview', authMiddleware,  applicationController.selectCandidatesfromInterview);
//router.post('/job/:id/selectCandidateforContract', applicationController.selectCandidateForContract);

module.exports = router;
