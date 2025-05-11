// 📁 controllers/jobController.js
const jobService = require('../services/JobService');


/**
 * @api {post} /job/create Create a job
 * @apiName CreateJob
 * @apiGroup Job
 * @apiDescription Creates a new job with the given data and assigns it to the requesting user as the employer.
 * @apiParam {Object} jobData - The job data object to be created containing the following properties:
 *        - title: String - The title of the job
 *        - description: String - The description of the job
 *        - location: String - The location of the job
 *        - salary: Object - The salary object containing amount and type (hourly or daily)
 *        - category: String - The category of the job
 *        - skillsRequired: Array[String] - The skills required for the job
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Job created successfully",
 *   job: {
 *     ...jobData,
 *     _id: ObjectId,
 *     createdAt: Date,
 *     updatedAt: Date
 *   }
 * }
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 */
const createJob = async (req, res) => {
  try {
    const jobData = req.body;
    const employerId = req.user?.id;

    if (!employerId) {
      return res.status(401).json({ success: false, message: 'Unauthorized: Employer not found' });
    }

    const job = await jobService.createJob(jobData, employerId);

    return res.status(201).json({ success: true, message: 'Job created successfully', job });
  } catch (error) {
    console.error('❌ Error creating job:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};


/**
 * @api {get} /job/get-employer-by-job-id Get employer by job ID
 * @apiName GetEmployerByJobId
 * @apiGroup Job
 * @apiDescription Fetches the employer for a given job ID.
 * @apiParam {String} jobId - The job ID
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Employer fetched successfully",
 *   employer: {
 *     _id: ObjectId,
 *     firstName: String,
 *     lastName: String,
 *     email: String,
 *     phone: String,
 *     role: String,
 *     averageRatingForEmployer: {
 *       overall: Number,
 *       totalRatings: Number
 *     }
 *   }
 * }
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 */
const getEmployerByJobId = async (req, res) => {
  try {
    console.log ("📥 /get-employer-by-job-id GET :");
    const jobId = req.params.jobId || req.body.jobId ;
    //console.log(jobId);
    const employer = await jobService.getEmployerByJobId(jobId);
    console.log(" employer: ", employer.data);
    return res.status(200).json({ success: true, message: 'Employer fetched successfully', employer : employer.data });
  } catch (error) {
    console.error('❌ Error fetching employer:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
}

/**
 * Fetches a list of jobs for the requesting user.
 * 
 * @param {Object} req - The request object containing the user's authentication details.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @apiSuccess {Boolean} success - True if the job list was successfully fetched.
 * @apiSuccess {String} message - Success message.
 * @apiSuccess {Object[]} jobs - List of jobs.
 * 
 * @apiError {Boolean} success - False if there is an error.
 * @apiError {String} message - Error message specifying the type of error encountered.
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 *   { success: false, message: "Internal Server Error" }
 */

const getJobList = async (req, res) => {
  try {
    const userId = req.user?.id;
    const jobs = await jobService.getJobList(userId);
    if(jobs.success === true) {
      //console.log('Job list fetched successfully:', jobs);
      return res.status(200).json({ success: true, message: 'Job list fetched successfully', jobs: jobs.data });
    }
  //  return res.status(200).json({ success: true, message: 'Job list fetched successfully', jobs });
  } catch (error) {
    console.error('❌ Error fetching job list:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};


/**
 * Searches for jobs based on query parameters.
 * 
 * @param {Object} req - The request object containing query filters.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @apiSuccess {Boolean} success - True if the job list was successfully fetched.
 * @apiSuccess {String} message - Success message.
 * @apiSuccess {Object[]} jobs - List of jobs matching the search criteria.
 * 
 * @apiError {Boolean} success - False if there is an error.
 * @apiError {String} message - Error message specifying the type of error encountered.
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 *   { success: false, message: "Internal Server Error" }
 */

const searchJobs = async (req, res) => {
  try {
    const filter = req.query;
    const jobs = await jobService.searchJobs(filter);
    console.log('Job list fetched successfully:', jobs);
    return res.status(200).json({
      success: true,
      message: 'Job list fetched successfully',
      jobs: jobs.data
    });
  } catch (error) {
    console.error('❌ Error searching jobs:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Internal Server Error'
    });
  }
};


const getJobById = async (req, res) => {
  try {
    const jobId = req.params.id;
    const job = await jobService.getJobById(jobId);
    if (!job) {
      return res.status(404).json({ success: false, message: 'Job not found' });
    }
    return res.status(200).json({ success: true, message: 'Job fetched successfully',  job: job.data });
  } catch (error) {
    console.error('❌ Error fetching job by ID:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};
const getUserPostedJobHistory = async (req, res) => {
  try {
    const jobs = await jobService.getUserPostedJobHistory(req.user.id);
    return res.status(200).json({ success: true, message: 'Job list fetched successfully', jobs });
  } catch (error) {
    console.error('❌ Error fetching user posted job history:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};
const getSuitableJobsForUser = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(400).json({ success: false, message: 'User ID required' });

    const filters = req.query;
    const jobs = await jobService.getSuitableJobsForUser(userId, filters);
    return res.status(200).json({ success: true, message: 'Suitable jobs fetched successfully', jobs });
  } catch (error) {
    console.error('❌ Error fetching suitable jobs for user:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};


const editJob = async (req, res) => {
  try {
    const jobId = req.params.id;
    const updaterId = req.user.id;
    const role = req.user.role;

    const updated = await jobService.editJob(jobId, req.body, updaterId, role);
    return res.status(200).json({ success: true, message: 'Job updated successfully', job: updated });
  } catch (error) {
    console.error('❌ Error editing job:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};
const deleteJob = async (req, res) => {
  try {
    const jobId = req.params.id;
    const updaterId = req.user.id;
    const role = req.user.role;

    const deleted = await jobService.deleteJob(jobId, updaterId, role);
    return res.status(200).json({ success: true, message: 'Job deleted successfully', job: deleted });
  } catch (error) {
    console.error('❌ Error deleting job:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

const getMyPostedJobs = async (req, res) => {
  try {
    const userId = req.user.id;
    const jobs = await jobService.getMyPostedJobs(userId);
    return res.status(200).json({ success: true, message: 'My posted jobs fetched successfully', jobs });
  } catch (error) {
    console.error('❌ Error fetching my posted jobs:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};
const getSuitableWorkersByJob = async (req, res) => {
  try {
    const jobId = req.params.id;
    if (!jobId) return res.status(400).json({ success: false, message: 'Job ID required' });

    const workers = await jobService.getSuitableWorkersByJob(jobId);
    return res.status(200).json({ success: true, message: 'Suitable workers fetched successfully', workers: workers || [] });
  } catch (error) {
    console.error('❌ Error fetching suitable workers by job:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

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
  getSuitableWorkersByJob,
  getEmployerByJobId
};
