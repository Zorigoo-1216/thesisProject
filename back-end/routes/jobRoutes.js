const express = require('express');
const router = express.Router();
const jobController = require('../controllers/jobController');


router.post('/createjob', jobController.createJob);


module.exports = router