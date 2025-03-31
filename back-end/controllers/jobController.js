
const jobService = require('../services/JobService');
//----------------------------Create job --------------------

const createJob = async (req, res) => {
    try {
      const job = await jobService.createJob(req.body);
      res.status(201).json({ message: 'Job created', job });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }

}

module.exports = { createJob}