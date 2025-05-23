const jobDB = require("../dataAccess/jobDB");
const userDB = require("../dataAccess/userDB");
const notificationService = require("../services/notificationService"); // зөв service
const viewJobDTO = require("../viewModels/viewJobDTO"); // jobDTO
const mongoose = require('mongoose');
const applicationDB = require("../dataAccess/applicationDB"); // applicationDB
const viewUserDTO = require("../viewModels/viewUserDTO");

// ajliin zar uusgeh 
const createJob = async (jobData, employerId) => {
  try {
    const dataToSave = {
      ...jobData,
      employerId,
    };

    const job = await jobDB.createJob(dataToSave);

    const eligibleUsers = await findEligibleUsers(job);
    console.log("✅ Eligible users found in jobservice:", eligibleUsers?.length || 0);

   if(eligibleUsers.length > 0){
    const userIds = eligibleUsers.map(user => user._id);
    await notificationService.sendNotification(userIds, 
     { title: job.title, message: `${job.location} байршилд "${job.title}" ажил зарлагдлаа. Цалин: ${job.salary?.amount}₮/${job.salary?.type === 'hourly' ? 'цаг' : 'өдөр'}`, type: 'job_match' }
    );
   }
    return  { success: true, data: job };
  } catch (error) {
    console.error("Error creating job:", error.message);
    return { success: false, message: error.message };
  }
};



const findEligibleUsers = async (job) => {
  const combinedText = [job.title, ...(job.description || [])].join(" ").toLowerCase();
  const keywords = combinedText.split(/\s+/).filter(w => w.length > 2);
  const regexes = keywords.map(word => new RegExp(word, 'i'));

  const baseQuery = {
    state: 'Active',
    isVerified: true,
    _id: { $ne: job.employerId },
    ...(job.possibleForDisabled === false && { 'profile.isDisabledPerson': false })
  };

  // Get all users meeting the base query first
  const candidates = await userDB.findUsersByQuery(baseQuery);

  const start = new Date(job.startDate);
  const end = new Date(job.endDate);

  const isScheduleConflict = (schedule) => {
    return schedule.some(s => {
      const sStart = new Date(s.startDate);
      const sEnd = new Date(s.endDate);
      return (start <= sEnd && end >= sStart);
    });
  };

  // Filter based on partial matches: at least one match
  const filtered = candidates.filter(user => {
    const profile = user.profile || {};

    const hasMainBranchMatch = profile.mainBranch && job.branch && profile.mainBranch === job.branch;

    const hasSkillMatch = (job.requirements || []).some(req =>
      (profile.skills || []).includes(req)
    );

    const hasKeywordMatch = (profile.skills || []).some(skill =>
      regexes.some(rx => rx.test(skill))
    );

    const hasRatingMatch = (user.reviews || []).some(r =>
      r.branchType === job.branch && r.criteria && r.criteria.performance > 0
    );

    const hasNoScheduleConflict = !isScheduleConflict(user.schedule || []);

    // Match if ANY of the optional conditions are met
    return hasNoScheduleConflict || (
      hasMainBranchMatch || hasSkillMatch || hasKeywordMatch || hasRatingMatch
    );
  });

  return filtered;
};


// tohirson ajilchdad medegdel ilgeeh



/**
 * Gets the list of all jobs that the user has not posted and the user has not applied to.
 * @param {string} userId - The ID of the user.
 * @returns {Object} A JSON response with a "success" flag, a message and a "data" property containing the list of jobs.
 * @throws {Error} If an internal server error occurs while getting the job list.
 * 
 * @apiParam {String} userId - The ID of the user.
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Job list fetched successfully",
 *   data: [
 *     {
 *       _id: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       title: "Job title",
 *       description: "Job description",
 *       salary: { amount: 10000, type: 'hourly' },
 *       employer: { _id: "5f9f1c7b5f9f1c7b5f9f1c7b", name: "John Doe", email: "john@example.com" },
 *       applications: [
 *         {
 *           _id: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *           userId: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *           jobId: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *           status: "pending",
 *           createdAt: "2020-11-10T05:21:39.116Z",
 *           updatedAt: "2020-11-10T05:21:39.116Z",
 *           __v: 0
 *         }
 *       ],
 *       applied: true
 *     }
 *   ]
 * }
 * 
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 */
const getJobList = async (userId) => {
  try {
    const allJobs = await jobDB.getdJoblist();
    const jobs = allJobs.filter(job => job.employerId.toString() !== userId.toString());
    const users = await userDB.getUsersByIds(jobs.map(job => job.employerId));
    const applications = await applicationDB.getApplicationFilteredByJobId(jobs.map(job => job._id));

    const finalJobs = jobs.map(job => {
      const employer = users.find(u => u._id.toString() === job.employerId.toString());
      const jobApplications = applications.filter(app => app.jobId.toString() === job._id.toString());
      const applied = jobApplications.some(app => app.userId.toString() === userId?.toString());
      return new viewJobDTO(job, jobApplications, employer, applied);
    });

    return { success: true, data: finalJobs };
  } catch (error) {
    console.error("Error getting job list:", error.message);
    return { success: false, message: error.message };
  }
};

const getTopJobs = async () => {
  try {
    const jobs = await jobDB.getTopJobs();
    const users = await userDB.getUsersByIds(jobs.map(job => job.employerId));
    const applications = await applicationDB.getApplicationFilteredByJobId(jobs.map(job => job._id));

    const finalJobs = jobs.map(job => {
      const employer = users.find(u => u._id.toString() === job.employerId.toString());
      const jobApplications = applications.filter(app => app.jobId.toString() === job._id.toString());
      return new viewJobDTO(job, jobApplications, employer);
    });

    return { success: true, data: finalJobs };
  } catch (error) {
    console.error("Error getting top jobs:", error.message);
    return { success: false, message: error.message };
  }
}


const getEmployerByJobId = async (jobId) =>{
  try {
    //console.log("job in jobservice",job);
    const job = await jobDB.getJobById(jobId);
    const emp = await userDB.getUserById(job.employerId);
    const employer = new viewUserDTO(emp);
    return { success: true, data: employer };
  } catch (error) {
    console.error("Error getting employer:", error.message);
    return { success: false, message: error.message };
  }
}




/**
 * Searches for jobs based on query parameters.
 * 
 * @param {Object} filters - An object containing query filters.
 * @param {String} [filters.title] - The title of the job to search for.
 * @param {String} [filters.branchType] - The branch type to filter by.
 * @param {String} [filters.location] - The location to filter by.
 * @param {String} [filters.jobType] - The job type to filter by.
 * @param {Boolean} [filters.possibleForDisabled] - Whether the job is possible for disabled people.
 * @param {Number} [filters.salaryMin] - The minimum salary to filter by.
 * @param {Number} [filters.salaryMax] - The maximum salary to filter by.
 * @param {String} [filters.startDate] - The start date of the job to filter by.
 * @param {String} [filters.endDate] - The end date of the job to filter by.
 * 
 * @return {Promise<Object>} - A promise that resolves to an object containing a success flag and an array of job objects.
 * @property {Boolean} success - True if the job list was successfully fetched.
 * @property {viewJobDTO[]} data - An array of job objects.
 * 
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   data: [
 *     {
 *       _id: ObjectId,
 *       title: String,
 *       branchType: String,
 *       location: String,
 *       jobType: String,
 *       salary: {
 *         amount: Number,
 *         currency: String
 *       },
 *       startDate: Date,
 *       endDate: Date,
 *       description: String,
 *       requirements: [String],
 *       possibleForDisabled: Boolean,
 *       employerId: ObjectId,
 *       employer: {
 *         _id: ObjectId,
 *         email: String,
 *         phoneNumber: String,
 *         password: String,
 *         name: String,
 *         profile: {
 *           skills: [String],
 *           mainBranch: String,
 *           waitingSalaryPerHour: Number
 *         },
 *         __v: 0
 *       },
 *       applications: [
 *         {
 *           _id: ObjectId,
 *           userId: ObjectId,
 *           jobId: ObjectId,
 *           status: String,
 *           createdAt: Date,
 *           __v: 0
 *         }
 *       ],
 *       applied: true
 *     }
 *   ]
 * }
 * 
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 */
const searchJobs = async (filters) => {
  try {
    const query = {
      endDate: { $gt: new Date() },
      status: 'open',
    };

    // Filter: Title (partial match)
    if (filters.title) {
      query.title = { $regex: filters.title, $options: 'i' };
    }

    // Filter: Exact match
    if (filters.branchType) query.branchType = filters.branchType;
    if (filters.location) query.location = filters.location;
    if (filters.jobType) query.jobType = filters.jobType;

    // Filter: Boolean - convert from string
    if (filters.possibleForDisabled !== undefined) {
      query.possibleForDisabled = filters.possibleForDisabled === 'true';
    }

    // Filter: Salary range
    if (filters.salaryMin || filters.salaryMax) {
      query["salary.amount"] = {};
      if (filters.salaryMin) query["salary.amount"].$gte = Number(filters.salaryMin);
      if (filters.salaryMax) query["salary.amount"].$lte = Number(filters.salaryMax);
    }

    // Filter: Start and/or end dates
    if (filters.startDate) {
      query.startDate = { $gte: new Date(filters.startDate) };
    }
    if (filters.endDate) {
      query.endDate = { $lte: new Date(filters.endDate) };
    }

    // Fetch jobs
    const jobs = await jobDB.findJobsByQuery(query);

    // Related employer info
    const employerIds = jobs.map(job => job.employerId);
    const users = await userDB.getUsersByIds(employerIds);

    // Related applications (status optional: 'open')
    const applications = await applicationDB.getApplicationFilteredByJobId(
      jobs.map(job => job._id), 
      filters.applicationStatus || null // optional second param
    );

    // Final data mapping
    const finalJobs = jobs.map(job => {
      const employer = users.find(u =>
        u?._id?.toString() === job.employerId?.toString()
      );

      const jobApplications = applications.filter(app =>
        app?.jobId?.toString() === job._id?.toString()
      );

      return new viewJobDTO(
        job,
        jobApplications ?? [],
        employer ?? null
      );
    });

    return { success: true, data: finalJobs };
  } catch (error) {
    console.error("Error searching jobs:", error.message);
    return { success: false, message: error.message };
  }
};


// ajliin zar iig id-aar avah
const getJobById = async (jobId) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job) {
      return { success: false, message: "Job not found" };
    }
    const viewJob = new viewJobDTO(
      job,
    )
    return { success: true, data: viewJob };
  } catch (error) {
    console.error("Error getting job by ID:", error.message);
    return { success: false, message: error.message };
  }
};
const getSuitableJobsForUser = async (userId, filters) => {
  try {
    const user = await userDB.getUserById(userId);
    if (!user.profile || !user.profile.skills || user.profile.skills.length === 0) {
      return { success: true, data: [] };
    }

    const jobs = await jobDB.getJobLisForUser(user, filters);

    let filtered = jobs;

    if (user.schedule && user.schedule.length > 0) {
      filtered = filtered.filter(job => {
        return !user.schedule.some(s =>
          (s.startDate <= job.endDate && s.endDate >= job.startDate)
        );
      });
    }

    filtered = filtered.filter(job => job.employerId.toString() !== userId.toString());

    if (filters.sort === 'salary') {
      filtered.sort((a, b) => b.salary.amount - a.salary.amount);
    } else if (filters.sort === 'recent') {
      filtered.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    }

    if (filters.salaryMin || filters.salaryMax) {
      const salaryQuery = {};
      if (filters.salaryMin) salaryQuery.$gte = +filters.salaryMin;
      if (filters.salaryMax) salaryQuery.$lte = +filters.salaryMax;
      filtered = filtered.filter(job => job.salary.amount >= salaryQuery.$gte && job.salary.amount <= salaryQuery.$lte);
    }

    const users = await userDB.getUsersByIds(filtered.map(job => job.employerId));
    const applications = await applicationDB.getApplicationFilteredByJobId(filtered.map(job => job._id), 'open');

    const finalJobs = filtered.map(job => {
      const employer = users.find(u => u._id.toString() === job.employerId.toString());
      const jobApplications = applications.filter(app => app.jobId.toString() === job._id.toString());
      const isApplied = jobApplications.some(app => app.userId.toString() === userId.toString());
      return new viewJobDTO(job, jobApplications, employer, isApplied);
    });

    return { success: true, data: finalJobs };
  } catch (error) {
    console.error("Error getting suitable jobs for user:", error.message);
    return { success: false, message: error.message };
  }
};


const getUserPostedJobHistory = async (userId) => {
  const jobs = await jobDB.getUserPostedJobHistory(userId); // Ажлын зарын жагсаалтыг авах
  return jobs;
};

const editJob = async (jobId, updates, userId, role) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job) return { success: false, message: "Job not found" };

    if (job.employerId.toString() !== userId && role !== 'admin') {
      return { success: false, message: "Permission denied" };
    }

    updates.updatedAt = new Date();
    const updatedJob = await jobDB.updateJob(jobId, updates);
    return { success: true, data: updatedJob };
  } catch (error) {
    console.error("Error editing job:", error.message);
    return { success: false, message: error.message };
  }
};

const deleteJob = async (jobId, userId, role) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job) return { success: false, message: "Job not found" };

    if (job.employerId.toString() !== userId && role !== 'admin') {
      return { success: false, message: "Permission denied" };
    }

    await jobDB.deleteJob(jobId);
    return { success: true, message: "Job deleted successfully" };
  } catch (error) {
    console.error("Error deleting job:", error.message);
    return { success: false, message: error.message };
  }
};

const getMyPostedJobs = async (userId) => {
  try {
    const jobs = await jobDB.getMyPostedJobs(userId); 
  
    return jobs;
  } catch (error) {
    console.error("Error in getMyPostedJobs:", error); // This will log any errors encountered
    throw error;
  }
};

const getSuitableWorkersByJob = async (jobId) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job) throw new Error('Job not found');

    const employees = await findEligibleUsers(job);
    const branchType = job.branch;

    const usersWithRating = employees.map(user => {
      const viewUser = new viewUserDTO(user);

      const branchRating =
        viewUser.averageRating?.byBranch?.find(r => r.branchType === branchType)?.score || 0;

      return {
        viewUserDTO: viewUser, // ✅ root түвшинд name хадгалах
        rating: branchRating,
      };
    });

    usersWithRating.sort((a, b) => b.rating - a.rating);

    return usersWithRating;
  } catch (error) {
    console.error("Error in getSuitableWorkersByJob:", error);
    throw error;
  }
};



module.exports = { 
  createJob, 
  getJobList, 
  searchJobs, 
  getJobById, 
  getSuitableJobsForUser, 
  getUserPostedJobHistory,
  editJob,
  deleteJob,
  getMyPostedJobs,
  getSuitableWorkersByJob,
  getEmployerByJobId,
  getTopJobs
};
