const applicationService = require('../services/applicationService');
const Jobdb = require('../dataAccess/jobDB');

/**
 * @api {post} /applyToJob Apply to a job
 * @apiName ApplyToJob
 * @apiGroup Application
 * @apiDescription Apply to a job, requires user ID and job ID in the request body
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Application created successfully",
 *   application: {
 *     userId: String,
 *     jobId: String,
 *     status: String
 *   }
 * }
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 * @apiParam {String} userId User ID
 * @apiParam {String} jobId Job ID
 * @apiParamExample {json} Request-Example:
 * {
 *   "userId": "5fa3c2d3f6fca4002d4b7f9c",
 *   "jobId": "5fa3c2d3f6fca4002d4b7fa5"
 * }
 */
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

/**
 * Cancels a user's application for a specific job.
 *
 * @param {Object} req - The request object containing user and job information. 
 * @param {Object} res - The response object used to send back the desired HTTP response.
 *
 * @throws {Error} If an internal server error occurs during the cancelation process.
 *
 * @returns {Object} A JSON response indicating the success or failure of the cancelation request.
 * 
 * @apiParam {String} userId - The ID of the user canceling the application.
 * @apiParam {String} jobId - The ID of the job for which the application is being canceled.
 * 
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Application canceled successfully"
 * }
 * 
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "User ID and Job ID are required"
 * }
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 */
const cancelApplication = async (req, res) => {
/*************  ✨ Windsurf Command ⭐  *************/
/**
 * Cancels a user's application for a specific job.
 *
 * @param {Object} req - The request object containing user and job information. 
 * @param {Object} res - The response object used to send back the desired HTTP response.
 *
 * @throws {Error} If an internal server error occurs during the cancelation process.
 *
 * @returns {Object} A JSON response indicating the success or failure of the cancelation request.
 * 
 * @apiParam {String} userId - The ID of the user canceling the application.
 * @apiParam {String} jobId - The ID of the job for which the application is being canceled.
 * 
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Application canceled successfully"
 * }
 * 
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "User ID and Job ID are required"
 * }
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 */

/*******  fceb95ee-3a51-4abb-a18d-d71cad7d7977  *******/  try {
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

/**
 * @api {get} /getMyAppliedJobs Get my applied jobs
 * @apiName getMyAppliedJobs
 * @apiGroup Application
 * @apiVersion 1.0.0
 * 
 * @apiParam {String} userId User ID
 * @apiParam {String} [status] Application status
 * 
 * @apiSuccess {Boolean} success true if success
 * @apiSuccess {String} message Success message
 * @apiSuccess {Object[]} data Applied job list
 * 
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Applied jobs fetched successfully",
 *   data: [
 *     {
 *       _id: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       userId: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       jobId: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       status: "pending",
 *       createdAt: "2020-11-10T05:21:39.116Z",
 *       updatedAt: "2020-11-10T05:21:39.116Z",
 *       __v: 0
 *     }
 *   ]
 * }
 * 
 * @apiError {Boolean} success false
 * @apiError {String} message Error message
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "User ID required"
 * }
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 */
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

/**
 * @api {get} /application/getMyAllAppliedJobs Get all applied jobs of a user
 * @apiName getMyAllAppliedJobs
 * @apiGroup Application
 * @apiDescription Get all applied jobs of a user
 * @apiVersion  1.0.0
 * @apiPermission  User
 * 
 * @apiParam {String} userId User ID
 * 
 * @apiSuccess {Boolean} success true if success
 * @apiSuccess {String} message Success message
 * @apiSuccess {Object[]} data Applied job list
 * 
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "All applied jobs fetched successfully",
 *   data: [
 *     {
 *       _id: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       userId: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       jobId: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       status: "pending",
 *       createdAt: "2020-11-10T05:21:39.116Z",
 *       updatedAt: "2020-11-10T05:21:39.116Z",
 *       __v: 0
 *     }
 *   ]
 * }
 * 
 * @apiError {Boolean} success false
 * @apiError {String} message Error message
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "User ID required"
 * }
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 */
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

/**
 * @api {get} /application/getAppliedUsersByJob Get users applied to a job
 * @apiName getAppliedUsersByJob
 * @apiGroup Application
 * @apiDescription Get users applied to a job
 * @apiVersion  1.0.0
 * @apiPermission  User
 * 
 * @apiParam {String} jobId Job ID
 * 
 * @apiSuccess {Boolean} success true if success
 * @apiSuccess {String} message Success message
 * @apiSuccess {Object[]} data Applied user list
 * 
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Applied users fetched successfully",
 *   data: [
 *     {
 *       _id: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       name: "John Doe",
 *       email: "john@example.com",
 *       username: "john123",
 *       phoneNumber: "+8801234567890",
 *       address: "Dhaka, Bangladesh",
 *       avatar: "https://example.com/avatar.jpg",
 *       rating: 4.5,
 *       createdAt: "2020-11-10T05:21:39.116Z",
 *       updatedAt: "2020-11-10T05:21:39.116Z",
 *       __v: 0
 *     }
 *   ]
 * }
 * 
 * @apiError {Boolean} success false
 * @apiError {String} message Error message
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "Job ID required"
 * }
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 */
const getAppliedUsersByJob = async (req, res) => {
  try {
    console.log("📥 /getAppliedUsersByJob GET in applocationController - req.body:", req.params);
    const jobId = req.params.jobId || req.body.jobId || req.params.id;

    if (!jobId) {
      return res.status(400).json({ success: false, message: "Job ID required" });
    }

    const result = await applicationService.getAppliedUsersByJob(jobId);
    console.log("📥 /getAppliedUsersByJob GET - result:", result);
    console.log("📥 /getAppliedUsersByJob GET - result.data:", result.data);
    if (result.success) {
      return res.status(200).json({
        success: true,
        employees: result.data, // 👈 энд employees гэж frontend-тайгаа тохируул
      });
    } else {
      return res.status(400).json({
        success: false,
        message: result.message,
      });
    }
  
    
  } catch (err) {
    console.error("❌ GetAppliedUsersByJob Error:", err.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

/**
 * @api {get} /application/getInterviewsByJob Get interviews by job
 * @apiName getInterviewsByJob
 * @apiGroup Application
 * @apiDescription Get interviews by job
 * @apiVersion  1.0.0
 * @apiPermission  User
 * 
 * @apiParam {String} jobId Job ID
 * 
 * @apiSuccess {Boolean} success true if success
 * @apiSuccess {String} message Success message
 * @apiSuccess {Object[]} data Interview list
 * 
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Interviews fetched successfully",
 *   data: [
 *     {
 *       _id: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       userId: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       jobId: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       status: "pending",
 *       createdAt: "2020-11-10T05:21:39.116Z",
 *       updatedAt: "2020-11-10T05:21:39.116Z",
 *       __v: 0
 *     }
 *   ]
 * }
 * 
 * @apiError {Boolean} success false
 * @apiError {String} message Error message
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "Job ID required"
 * }
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 */
const getInterviewsByJob = async (req, res) => {
  try {
    console.log("📥 /get interviews GET in applocationController - req.body:", req.body);
    const jobId = req.params.id || req.body.jobId;
    if (!jobId) return res.status(400).json({ error: "Job ID required" });

    const interviews = await applicationService.getInterviewsByJob(jobId);
    console.log("📥 /get interviews GET - interviews:", interviews);
    
    if (!interviews) return res.status(400).json({ error: "Interviews not found" });

    res.status(200).json({success: true, message: "Амжилттай", interviews : interviews || [] });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
}

/**
 * Handles the selection of candidates for a job.
 * 
 * @param {Object} req - The request object containing job ID and selected user IDs.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @apiSuccess {Boolean} success - True if the candidates were successfully selected.
 * @apiSuccess {String} message - Success message.
 * 
 * @apiError {Boolean} success - False if there is an error.
 * @apiError {String} message - Error message specifying the type of error encountered.
 * 
 * @apiErrorExample {json} Error-Response:
 *   { success: false, message: "Job ID required" }
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 *   { success: false, message: "Internal Server Error" }
 */

const selectCandidates = async (req, res) => {
  try {
    console.log("📥 /select-candidates POST in applocationController - req.body:");
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

/**
 * Handles the selection of candidates from an interview for a job.
 * 
 * @param {Object} req - The request object containing job ID and selected user IDs.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @apiSuccess {Boolean} success - True if the candidates were successfully selected from the interview.
 * @apiSuccess {String} message - Success message.
 * 
 * @apiError {Boolean} success - False if there is an error.
 * @apiError {String} message - Error message specifying the type of error encountered.
 * 
 * @apiErrorExample {json} Error-Response:
 *   { success: false, message: "Job ID required" }
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 *   { success: false, message: "Internal Server Error" }
 */
const selectCandidatesfromInterview = async (req, res) => {
  try {
    console.log("📥 /select-candidates-from-interview POST in applocationController ");
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

/**
 * Gets the list of employees for a given job ID.
 * 
 * @param {Object} req - The request object containing the job ID.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @apiSuccess {Boolean} success - True if the employees were successfully fetched.
 * @apiSuccess {String} message - Success message.
 * @apiSuccess {Object[]} employers - List of employers.
 * 
 * @apiError {Boolean} success - False if there is an error.
 * @apiError {String} message - Error message specifying the type of error encountered.
 * 
 * @apiErrorExample {json} Error-Response:
 *   { success: false, message: "Job ID required" }
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 *   { success: false, message: "Internal Server Error" }
 */
const getEmployeesByJob = async (req, res) => {
  try {
    console.log("📥 /get-employees-by-job GET in applocationController ");
    const jobId = req.params.id || req.body.jobId;
    if (!jobId) return res.status(400).json({ error: "Job ID required" });
    //console.log("📥 /get employees GET - jobId:", jobId);
    const employers = await applicationService.getEmployeesByJob(jobId);
    //console.log("📥 /get employees GET - employers:", employers);
    res.status(200).json({ message: "Амжилттай", employers : employers || [] });
}
catch (err) {
  res.status(400).json({ error: err.message });
}
}

/**
 * Gets the list of candidates for a given job ID.
 * 
 * @param {Object} req - The request object containing the job ID.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @apiSuccess {Boolean} success - True if the candidates were successfully fetched.
 * @apiSuccess {String} message - Success message.
 * @apiSuccess {Object[]} candidates - List of candidates.
 * 
 * @apiError {Boolean} success - False if there is an error.
 * @apiError {String} message - Error message specifying the type of error encountered.
 * 
 * @apiErrorExample {json} Error-Response:
 *   { success: false, message: "Job ID required" }
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 *   { success: false, message: "Internal Server Error" }
 */

const getCandidatesByJob = async (req, res) => {
  try {
    console.log("📥 /get-candidates-by-job GET in applocationController ");
    const jobId = req.params.id || req.body.jobId;
    if (!jobId) return res.status(400).json({ error: "Job ID required" });
    const candidates = await applicationService.getCandidatesByJob(jobId);
    res.status(200).json({success: true, message: "Амжилттай", candidates : candidates || [] });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
}

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
