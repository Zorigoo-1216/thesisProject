// 📁 controllers/jobController.js
const jobService = require('../services/JobService');

//----------------------------Create job --------------------
const createJob = async (req, res) => {
  try {
    const jobData = req.body;
    const employerId = req.user?.id;

    if (!employerId) {
      return res.status(401).json({ error: 'Unauthorized: Employer not found' });
    }

    // Шууд дамжуулна
    const job = await jobService.createJob(jobData, employerId);

    return res.status(201).json({ message: 'Job created successfully', job });
  } catch (error) {
    console.error('Error creating job:', error);
    return res.status(500).json({ error: error.message });
  }
};




//---------------------------- job list avah--------------------------------------------------------
const getJobList = async (req, res) => {
  try {
    const userId = req.user?.id;
    const jobs = await jobService.getJobList(userId);
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
  console.log("Received request for posted jobs...");
  try {
    const userId = req.user.id;
    console.log("User ID from request:", userId);
    const jobs = await jobService.getMyPostedJobs(userId);
    res.status(200).json({ message: 'My posted jobs fetched successfully', jobs });
  } catch (error) {
    console.error("Error fetching posted jobs:", error.message);
    res.status(400).json({ error: error.message });
  }
}

const getSuitableWorkersByJob = async (req, res) => {
  try {
    const jobId = req.params.id;
    console.log("📥 GET /jobs/:id/suitable-workers jobId:", jobId);
    if (!jobId) return res.status(400).json({ error: "Job ID required" });
    const workers = await jobService.getSuitableWorkersByJob(jobId);
    res.status(200).json({ message: 'Suitable workers fetched successfully', workers : workers || [] });
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
  getMyPostedJobs,
  getSuitableWorkersByJob
};
