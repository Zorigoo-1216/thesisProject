const express = require('express');
const router = express.Router();
const jobController = require('../controllers/jobController');
const applicationController = require('../controllers/applicationController');
const authMiddleware = require('../middleware/authMiddleware');
const userController = require('../controllers/userControllers');
// -------------------------------ajil haih -----------------------

router.get('/', authMiddleware, jobController.getJobList);  
router.get('/topjobs', jobController.getTopJobs); 
router.get("/search", authMiddleware, jobController.searchJobs);  
router.get('/searchByTitle', jobController.searchJobs); 
router.get('/suitable', authMiddleware, jobController.getSuitableJobsForUser);
router.get('/postedJobHistory' , authMiddleware, jobController.getUserPostedJobHistory); 
router.get('/postedJobs', authMiddleware, jobController.getMyPostedJobs);
// ---------------------------- manage job --------------------------


router.get('/:id', jobController.getJobById); 
router.post('/create', authMiddleware, jobController.createJob); 
router.put('/:id/edit', authMiddleware, jobController.editJob);
router.delete('/:id', authMiddleware, jobController.deleteJob); 

router.get('/:jobId/employer', authMiddleware, jobController.getEmployerByJobId);

// ---------------------------- manage job application --------------------------
router.get('/:id/suitable-workers', authMiddleware, jobController.getSuitableWorkersByJob);
router.get('/:id/applications', authMiddleware, applicationController.getAppliedUsersByJob);
router.get('/:id/interviews', authMiddleware, applicationController.getInterviewsByJob);
router.get('/:id/candidates', authMiddleware, applicationController.getCandidatesByJob);
router.get('/:id/employers', authMiddleware, applicationController.getEmployeesByJob);


// use case 2.2

module.exports = router