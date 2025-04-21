const applicationService = require('../services/applicationService');
const Jobdb = require('../dataAccess/jobDB');
// Ажилд хүсэлт илгээх
// controllers/applicationController.js
const applyToJob = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.userId; 
    const { jobId } = req.body || req.body.jobId; // jobId-г req.body-оос авна

    console.log("📩 APPLY TO JOB - jobId:", jobId);
    if (!userId) return res.status(400).json({ error: "User ID required" });
    if (!jobId) return res.status(400).json({ error: "Job ID required" });

    if (!userId && !jobId) {
      return res.status(400).json({ error: 'userId and jobId are required' });
    }
    console.log("📥 POST /apply jobId:", jobId);
    console.log("📥 APPLY TO JOB");
    console.log("➡️ userId:", userId);
    console.log("➡️ jobId:", jobId);
    const result = await applicationService.applyToJob(userId, jobId);
    res.status(200).json({ message: result });
  } catch (err) {
    console.error("❌ ApplyToJob Error:", err); // Энэ log одоо харагдах ёстой
    console.error("❌ ApplyToJob Error Stack:", err.stack); 
    res.status(400).json({ error: err.message });
  }
};

const cancelApplication = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.id;
    const jobId = req.params.id || req.body.jobId;
    if (!userId ||!jobId) {
      return res.status(400).json({ error: 'userId and jobId are required' });
    }
    const result = await applicationService.cancelApplication(userId, jobId);
    res.status(200).json({ message: result });
} catch (err) {
  res.status(400).json({ error: err.message });
}

}


// хүсэлт илгээсэн ажлууд
const getMyAppliedJobs = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.id;
    const status = req.query.status || req.body.status || null;

    if (!userId) {
      return res.status(400).json({ error: "User ID required" });
    }
    console.log("📥 /myapplications GET - userId:", userId);
    const jobs = await applicationService.getMyAppliedJobs(userId, status);
    console.log("📥 /myapplications GET - jobs:", jobs);
    return res.status(200).json({
      message: "Амжилттай",
      jobs: jobs || [],
    });
  } catch (err) {
    console.error('❌ getMyAppliedJobs error:', err.message);
    return res.status(500).json({ error: "Серверийн алдаа" });
  }
};


// Миний бүх хүсэлт илгээсэн ажлын түүх
const getMyAllAppliedJobs = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.id;
    if (!userId) return res.status(400).json({ error: "User ID required" });
    
    const jobs = await applicationService.getMyAllAppliedJobs(userId);
    res.status(200).json({ message: "Амжилттай", jobs });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Ажилд хүсэлт илгээсэн ажилчид
const getAppliedUsersByJob = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.id;
    if (!userId) return res.status(400).json({ error: "User ID required" });
    const jobId = req.params.id || req.body.jobId;
    if (!jobId) return res.status(400).json({ error: "Job ID required" });
    console.log("📥 /applications GET - jobId:", jobId);
    const employees = await applicationService.getAppliedUsersByJob(jobId);
    console.log("📥 /applications GET - employees:", employees);
    if (!employees) return res.status(404).json({ error: "No applicants found" });
    res.status(200).json({ message: "Амжилттай", employees : employees || [] });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};


const getInterviewsByJob = async (req, res) => {
  try {
    const jobId = req.params.id || req.body.jobId;
    if (!jobId) return res.status(400).json({ error: "Job ID required" });

    const interviews = await applicationService.getInterviewsByJob(jobId);
    res.status(200).json({ message: "Амжилттай", interviews : interviews || [] });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
}
// ажилтан сонгох
const selectCandidates = async (req, res) => {
  try {
    const jobId = req.params.id || req.body.jobId;
    const { selectedUserIds } = req.body;

    if (!jobId) return res.status(400).json({ error: "Job ID required" });
    const result = await applicationService.selectCandidates(jobId, selectedUserIds);
    res.status(200).json({ message: "Амжилттай", result });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// ✅ Интервьюд оролцох ажилчдыг сонгох
const selectCandidatesfromInterview = async (req, res) => {
  try {
    const jobId = req.params.id || req.body.jobId;
    const { selectedUserIds } = req.body;

    if (!jobId) return res.status(400).json({ error: "Job ID required" });
    const result = await applicationService.selectCandidatesfromInterview(jobId, selectedUserIds);
    res.status(200).json({ message: "Амжилттай", result });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};
const getEmployeesByJob = async (req, res) => {
  try {
    const jobId = req.params.id || req.body.jobId;
    if (!jobId) return res.status(400).json({ error: "Job ID required" });
    console.log("📥 /get employees GET - jobId:", jobId);
    const employers = await applicationService.getEmployeesByJob(jobId);
    console.log("📥 /get employees GET - employers:", employers);
    res.status(200).json({ message: "Амжилттай", employers });
}
catch (err) {
  res.status(400).json({ error: err.message });
}
}

const getCandidatesByJob = async (req, res) => {
  try {
    const jobId = req.params.id || req.body.jobId;
    if (!jobId) return res.status(400).json({ error: "Job ID required" });
    const candidates = await applicationService.getCandidatesByJob(jobId);
    res.status(200).json({ message: "Амжилттай", candidates : candidates || [] });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
}

// const selectCandidateForContract = async (req, res) => {
//   try {
//     const jobId = req.params.id || req.body.jobId;
//     const { selectedUserIds } = req.body;

//     if (!jobId) return res.status(400).json({ error: "Job ID required" });
//     const result = await applicationService.selectCandidateForContract(jobId, selectedUserIds);
//     res.status(200).json({ message: "Амжилттай", result });
//   } catch (err) {
//     res.status(400).json({ error: err.message });
//   }
//}
module.exports = {
  applyToJob,
  getMyAppliedJobs,
  getMyAllAppliedJobs,
  getAppliedUsersByJob,
  selectCandidates,
  selectCandidatesfromInterview,
  getInterviewsByJob,
  getEmployeesByJob,
  getCandidatesByJob,
  cancelApplication
};
