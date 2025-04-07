// 📁 controllers/jobController.js
const jobService = require('../services/JobService');

//----------------------------Create job --------------------
const createJob = async (req, res) => {
  try {
    console.log('📦 Job Data:', req.body);
    const employerId = req.user.id;
    const job = await jobService.createJob({ ...req.body, employerId });
    res.status(201).json({ message: 'Job created', job });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

//---------------------------- job list avah--------------------------------------------------------
const getJobList = async (req, res) => {
  try {
    const jobs = await jobService.getJobList();
    res.status(200).json({ message: 'Job list fetched successfully', jobs });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

// ajil haih 
const searchJobs = async (req, res) => {
  try {
    const filter = req.query;
    const jobs = await jobService.searchJobs(filter);
    res.status(200).json({ message: 'Job list fetched successfully', jobs });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const getJobById = async (req, res) => {
  try {
    const jobId = req.params.id;
    const job = await jobService.getJobById(jobId);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }
    res.status(200).json({ message: 'Job fetched successfully', job });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};
const getUserPostedJobHistory = async (req, res) => {
  try {
    const jobs = await jobService.getUserPostedJobHistory(req.user.id);
    res.status(200).json({ message: 'Job list fetched successfully', jobs });
  } catch (error) {
    res.status(400).json({ error: error.message }); 
  }
};
const getSuitableJobsForUser = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(400).json({ error: 'User ID required' });

    const filters = req.query; // sort, branchType, salaryMin/max гэх мэт
    const jobs = await jobService.getSuitableJobsForUser(userId, filters);
    res.status(200).json({ message: 'Suitable jobs fetched successfully', jobs });
  } catch (error) {
    console.error("❌ getSuitableJobsForUser Error:", error.message);
    res.status(400).json({ error: error.message });
  }
};
const editJob = async (req, res) => {
  try {
    const jobId = req.params.id;
    const updaterId = req.user.id;
    const role = req.user.role;

    const updated = await jobService.editJob(jobId, req.body, updaterId, role);
    res.status(200).json({ message: 'Job updated successfully', job: updated });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};
const deleteJob = async (req, res) => {
  try {
    const jobId = req.params.id;
    const updaterId = req.user.id;
    const role = req.user.role;
    const deleted = await jobService.deleteJob(jobId, updaterId, role);
    res.status(200).json({ message: 'Job deleted successfully', job: deleted });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const getMyPostedJobs = async (req, res) => {
  try {
    const userId = req.user.id;
    const jobs = await jobService.getMyPostedJobs(userId);
    res.status(200).json({ message: 'My posted jobs fetched successfully', jobs });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

module.exports = { 
  createJob, 
  getJobList, 
  searchJobs, 
  getJobById, 
  getUserPostedJobHistory, 
  getSuitableJobsForUser,
  editJob,
  deleteJob,
  getMyPostedJobs
};
