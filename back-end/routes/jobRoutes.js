const express = require('express');
const router = express.Router();
const jobController = require('../controllers/jobController');
const applicationController = require('../controllers/applicationController');
const authMiddleware = require('../middleware/authMiddleware');

// -------------------------------ajil haih -----------------------
router.get('/', jobController.getJobList);  
router.get("/search", jobController.searchJobs);  
router.get('/suitable', authMiddleware, jobController.getSuitableJobsForUser);
// ---------------------------- manage job --------------------------
router.get('/:id', jobController.getJobById); 
router.post('/create', authMiddleware, jobController.createJob); 
router.put('/:id/edit', authMiddleware, jobController.editJob);
router.delete('/:id', authMiddleware, jobController.deleteJob); 
// ---------------------------- manage job application --------------------------
router.get('/postedJobHistory' , authMiddleware, jobController.getUserPostedJobHistory); 
router.get('/postedJobs', authMiddleware, jobController.getMyPostedJobs);
router.get('/:id/applications', authMiddleware, applicationController.getAppliedUsersByJob);
router.get('/:id/interviews', authMiddleware, applicationController.getInterviewsByJob);
router.get('/:id/candidates', authMiddleware, applicationController.getCandidatesByJob);
router.get('/:id/employers', authMiddleware, applicationController.getEmployeesByJob);




module.exports = router