const applicationService = require('../services/applicationService');
const Jobdb = require('../dataAccess/jobDB');
// Ажилд хүсэлт илгээх
// controllers/applicationController.js
const applyToJob = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.userId;
    const { jobId } = req.body;

    if (!userId) return res.status(400).json({ success: false, message: "User ID required" });
    if (!jobId) return res.status(400).json({ success: false, message: "Job ID required" });

    const result = await applicationService.applyToJob(userId, jobId);

    if (result.success) {
      return res.status(200).json(result);
    }

    return res.status(400).json(result);
  } catch (err) {
    console.error("❌ ApplyToJob Error:", err.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};


const cancelApplication = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.userId;
    const jobId = req.params.id || req.body.jobId;

    if (!userId || !jobId) {
      return res.status(400).json({ success: false, message: "User ID and Job ID are required" });
    }

    const result = await applicationService.cancelApplication(userId, jobId);

    if (result.success) {
      return res.status(200).json(result);
    }

    return res.status(400).json(result);
  } catch (err) {
    console.error("❌ CancelApplication Error:", err.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};


// хүсэлт илгээсэн ажлууд
const getMyAppliedJobs = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.userId;
    const status = req.query.status || req.body.status || null;

    if (!userId) {
      return res.status(400).json({ success: false, message: "User ID required" });
    }
    //console.log("📥 /getMyAppliedJobs GET - userId:", userId);
    const result = await applicationService.getMyAppliedJobs(userId, status);

    if (result.success) {
     // console.log("📥 /getMyAppliedJobs GET - result:", result);
      return res.status(200).json(result);
    }
    
    return res.status(400).json(result);
  } catch (err) {
    console.error("❌ GetMyAppliedJobs Error:", err.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};


// Миний бүх хүсэлт илгээсэн ажлын түүх
const getMyAllAppliedJobs = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.userId;

    if (!userId) {
      return res.status(400).json({ success: false, message: "User ID required" });
    }

    const result = await applicationService.getMyAllAppliedJobs(userId);

    if (result.success) {
      return res.status(200).json(result);
    }

    return res.status(400).json(result);
  } catch (err) {
    console.error("❌ GetMyAllAppliedJobs Error:", err.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

// Ажилд хүсэлт илгээсэн ажилчид
const getAppliedUsersByJob = async (req, res) => {
  try {
    const jobId = req.params.id || req.body.jobId;

    if (!jobId) {
      return res.status(400).json({ success: false, message: "Job ID required" });
    }

    const result = await applicationService.getAppliedUsersByJob(jobId);

    if (result.success) {
      return res.status(200).json(result);
    }

    return res.status(400).json(result);
  } catch (err) {
    console.error("❌ GetAppliedUsersByJob Error:", err.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
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

    if (!jobId) {
      return res.status(400).json({ success: false, message: "Job ID required" });
    }

    const result = await applicationService.selectCandidates(jobId, selectedUserIds);

    if (result.success) {
      return res.status(200).json(result);
    }

    return res.status(400).json(result);
  } catch (err) {
    console.error("❌ SelectCandidates Error:", err.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};


// ✅ Интервьюд оролцох ажилчдыг сонгох
const selectCandidatesfromInterview = async (req, res) => {
  try {
    const jobId = req.params.id || req.body.jobId;
    const { selectedUserIds } = req.body;

    if (!jobId) {
      return res.status(400).json({ success: false, message: "Job ID required" });
    }

    const result = await applicationService.selectCandidatesfromInterview(jobId, selectedUserIds);

    if (result.success) {
      return res.status(200).json(result);
    }

    return res.status(400).json(result);
  } catch (err) {
    console.error("❌ SelectCandidatesFromInterview Error:", err.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};
const getEmployeesByJob = async (req, res) => {
  try {
    const jobId = req.params.id || req.body.jobId;
    if (!jobId) return res.status(400).json({ error: "Job ID required" });
    //console.log("📥 /get employees GET - jobId:", jobId);
    const employers = await applicationService.getEmployeesByJob(jobId);
    //console.log("📥 /get employees GET - employers:", employers);
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
