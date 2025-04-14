const express = require('express');
const router = express.Router();
const ratingController = require('../controllers/ratingController');
const authenticate = require('../middleware/authMiddleware');


router.post('/', authenticate, ratingController.createRating);
router.get('/user/:userId', authenticate, ratingController.getUserRatings);

module.exports = router;
