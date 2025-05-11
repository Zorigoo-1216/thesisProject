const Application = require('../models/Application');
const Job = require('../models/Job');
const viewJobDTO = require('../viewModels/viewJobDTO');
const viewUserDTO = require('../viewModels/viewUserDTO');
const User = require('../models/User');


/**
 * Creates a new application for a user to a specified job.
 * 
 * @param {string} userId - The ID of the user applying for the job.
 * @param {string} jobId - The ID of the job for which the user is applying.
 * @returns {Promise<Object>} The saved application object.
 * @throws {Error} If there is an error saving the application.
 */

const createApplication = async (userId, jobId ) => {
    const newApp = new Application({ userId, jobId });
    try {
      const saved = await newApp.save();
      console.log("✅ Saved Application:", saved);
      return saved;
    } catch (err) {
      console.error("❌ Application save error:", err.stack);
      throw err;
    }
}


/**
 * Gets a list of jobs a user has applied to.
 * 
 * @param {string} userId - The ID of the user.
 * @param {string} [status] - The status of the applications to return. If not provided, all applications will be returned.
 * @returns {Object[]} A list of jobs the user has applied to, with the respective application status.
 * @throws {Error} If an internal server error occurs while getting the applied jobs.
 */
const getAppliedJobsByUserId = async (userId, status) => {
  const query = { userId };
  if (status) query.status = status;

  const applications = await Application.find(query);
  const jobPromises = applications.map(async (application) => {
    const job = await Job.findById(application.jobId);
    if (job) {
      const employer = await User.findById(job.employerId);
      const dto = new viewJobDTO(job, [application], employer, true);
      dto.applicationStatus = application.status;
      return dto;
    }
    return null;
  });

  const jobsWithNull = await Promise.all(jobPromises);
  const jobs = jobsWithNull.filter(j => j !== null);
  return jobs;
};


/**
 * Gets all jobs a user has applied to.
 * @param {string} userId - The ID of the user.
 * @returns {Object[]} A list of jobs the user has applied to.
 * @throws {Error} If an internal server error occurs while getting the applied jobs.
 */
const getAllAppliedJobsByUserId = async (userId) => {
  const applications =  await Application.find({ userId : userId});
    const jobs= [];
    for (const application of applications) {
        const job = await Job.findById(application.jobId);
        if (job) {
          jobs.push(new viewJobDTO(job));
        }
      }
      return Array.isArray(jobs) ? jobs : [];
}

/**
 * Gets a list of users who have applied to a specific job.
 * 
 * @param {string} jobId - The ID of the job for which to fetch applied users.
 * @returns {Promise<Array<Object>>} A promise that resolves to an array of user DTOs representing the users who applied.
 * @throws {Error} If the job is not found.
 */

const getAppliedUsersByJobId = async (jobId) => {
  const job = await Job.findById(jobId);
  if (!job) throw new Error("Job not found");
  
    const applications = await Application.find({ jobId });
    const users = applications.map(app => User.findById(app.userId));
    return users.map(user => new viewUserDTO(user));
  };

/**
 * Gets a list of users who have applied to a specific job and have been selected for an interview.
 * @param {string} jobId - The ID of the job for which to fetch interview-selected users.
 * @returns {Promise<Array<Object>>} A promise that resolves to an array of user DTOs representing the users who applied and have been selected for an interview.
 * @throws {Error} If the job is not found.
 */
  const getInterviewUsers = async (jobId) => {
    const job = await Job.findById(jobId);
    if (!job) throw new Error("Job not found");
    const applications = await Application.find({ jobId });
    const users = applications.map(app => User.findById(app.userId)); 
    return users.map(user => new viewUserDTO(user));
    // Эрэмбэлэх
   
  };
  


/**
 * Retrieves applications for a specific job with a given status.
 * 
 * @param {string} jobId - The ID of the job for which to fetch applications.
 * @param {string} status - The status of applications to filter by.
 * @returns {Promise<Array<Object>>} A promise that resolves to an array of applications matching the job ID and status.
 */

const getApplciationByJobId = async (jobId, status) => {
  return await Application.find({ jobId: jobId, status: status });
}
/**
 * Retrieves applications filtered by a given job ID.
 * 
 * @param {string|string[]} jobId - A single job ID or an array of job IDs to filter by.
 * @returns {Promise<Array<Object>>} A promise that resolves to an array of applications matching the provided job ID(s).
 */
const getApplicationFilteredByJobId = async (jobIds) => {
return await Application.find({ jobId: { $in: jobIds } });
}


/**
 * Gets all applications for a given user ID that are not closed.
 * @param {string} userId - The ID of the user for which to fetch applications.
 * @returns {Promise<Array<Object>>} A promise that resolves to an array of applications matching the user ID and not closed.
 */
const getapplicationsByUserId = async (userId) => {
  return await Application.find({ userId : userId , status:  { $ne: "closed" } });
}


/**
 * Retrieves a single application by ID.
 * @param {string} appID - The ID of the application to fetch.
 * @returns {Promise<Object>} A promise that resolves to the application matching the provided ID.
 * @throws {Error} If the application is not found.
 */
const getApplicationById = async (appID) => {
  return await Application.findById(appID);
}
  

/**
 * Retrieves all applications for a given user ID that are not closed.
 * @param {string} userId - The ID of the user for which to fetch applications.
 * @returns {Promise<Array<Object>>} A promise that resolves to an array of applications matching the user ID and not closed.
 */
const getMyApplications = async (userId) => {
  return await Application.find({ userId: userId, status: { $ne: "closed" } });
}

/**
 * Retrieves all applications for a given user ID.
 * @param {string} userId - The ID of the user for which to fetch applications.
 * @returns {Promise<Array<Object>>} A promise that resolves to an array of applications matching the user ID.
 */
const getMyAllApplications = async (userId) => {
    return await Application.find({ userId: userId });
  }

/**
 * Retrieves all candidates for a given job ID. A candidate is a user who has applied
 * to the job and has been accepted.
 * @param {string} jobId - The ID of the job for which to fetch candidates.
 * @returns {Promise<Array<Object>>} A promise that resolves to an array of user DTOs
 * representing the candidates for the given job.
 */

const getCandidatesByJob = async (jobId) => {
  const applications = await Application.find({ jobId: jobId, status: "accepted" });
  console.log("🧪 All Applications for Job:", applications.map(a => ({ id: a._id, status: a.status })));
  const candidates = [];
  for (const application of applications) {
    const user = await User.findById(application.userId);
    if (user) {
      candidates.push(new viewUserDTO(user));
    }
  }
  
  return Array.isArray(candidates) ? candidates : [];
}


/**
 * Cancels a user's application for a specific job.
 * @param {string} jobId - The ID of the job for which the application is being canceled.
 * @param {string} userId - The ID of the user canceling the application.
 * @returns {Promise<string>} A promise that resolves to a string indicating the success or failure of the cancelation request.
 * @throws {Error} If the application is not found.
 */
const cancelApplication = async (jobId, userId) => {
  const application = await Application.findOneAndDelete({ jobId: jobId, userId: userId });
  if (!application) throw new Error("Application not found");
  await Job.findByIdAndUpdate(jobId, { $pull: { applications: application._id } });
  return "Application canceled";
}

/**
 * Updates the status of a user's application for a specific job.
 * 
 * @param {string} jobId - The ID of the job for which the application status is being updated.
 * @param {string} userId - The ID of the user whose application status is being updated.
 * @param {string} status - The new status to be assigned to the application.
 * @returns {Promise<string>} A promise that resolves to a string indicating the success of the status update.
 * @throws {Error} If the application is not found.
 */

const updateStatus = async (jobId, userId, status) => {
  const application = await Application.findOne({ jobId: jobId, userId: userId });
  if (!application) throw new Error("Application not found");
  application.status = status;
  await application.save();
  return "Application status updated";
}
  module.exports = {
    createApplication, 
    getAllAppliedJobsByUserId,
    getAppliedJobsByUserId,
    getAppliedUsersByJobId,
    getApplciationByJobId,
    getapplicationsByUserId,
    getApplicationById,
    getMyApplications,
    getMyAllApplications,
    getInterviewUsers,
    getCandidatesByJob,
    cancelApplication,
    updateStatus,
    getApplicationFilteredByJobId
};