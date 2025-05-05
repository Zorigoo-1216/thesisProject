const express = require('express');
const router = express.Router();
const ratingController = require('../controllers/ratingController');
const authenticate = require('../middleware/authMiddleware');


router.post('/', authenticate, ratingController.createRating);

// routes/ratings.js


router.get('/user/:userId', authenticate, ratingController.getUserRatings);
router.get('/job/:jobId', authenticate, ratingController.getJobRatingsEmployees);
router.get('/job/:jobId/employer', authenticate, ratingController.getJobRatingByEmployer);
router.post('/job/:jobId/employer', authenticate, ratingController.rateEmployer);
router.post('/job/:jobId/employee', authenticate, ratingController.rateEmployee);
module.exports = router;
