const jobDB = require("../dataAccess/jobDB");
const userDB = require("../dataAccess/userDB");
const notificationService = require("../services/notificationService"); // зөв service
const viewJobDTO = require("../viewModels/viewJobDTO"); // jobDTO
const mongoose = require('mongoose');
const applicationDB = require("../dataAccess/applicationDB"); // applicationDB
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

    if (Array.isArray(eligibleUsers) && eligibleUsers.length > 0) {
      await notifyEligibleUsers(job, eligibleUsers);
    }

    return { success: true, data: job };
  } catch (error) {
    console.error("Error creating job:", error.message);
    return { success: false, message: error.message };
  }
};



// ajild tohiroh ajilchdiig oloh
const findEligibleUsers = async (job) => {
  const combinedText = [job.title, ...(job.description || [])].join(" ").toLowerCase();
  const keywords = combinedText.split(/\s+/).filter(w => w.length > 2); // богино үгс хасна

  const regexes = keywords.map(word => new RegExp(word, 'i'));

  const query = {
    state: 'Active',
    isVerified: true,
    'profile.waitingSalaryPerHour': { $lte: job.salary.amount },
    ...(job.possibleForDisabled === false && { 'profile.isDisabledPerson': false }),
    ...(job.branch && { 'profile.mainBranch': job.branch }),
    $or: [
      { 'profile.skills': { $in: job.requirements || [] } },
      {
        'profile.skills': {
          $elemMatch: { $in: regexes }
        }
      }
    ]
  };

  const result = await userDB.findUsersByQuery(query);
  return Array.isArray(result) ? result : [];
};

// tohirson ajilchdad medegdel ilgeeh
const notifyEligibleUsers = async (job, users) => {
  await notificationService.sendBulkNotifications(users, job);
};

// ajliin jagsaaltiig default aar haruulah
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





// ajliin zar filter eer haih
const searchJobs = async (filters) => {
  try {
    const query = {
      endDate: { $gt: new Date() },
      status: 'open',
    };

    if (filters.title) {
      query.title = { $regex: filters.title, $options: 'i' };
    }
    if (filters.branchType) {
      query.branchType = filters.branchType;
    }
    if (filters.location) {
      query.location = filters.location;
    }
    if (filters.jobType) {
      query.jobType = filters.jobType;
    }
    if (filters.possibleForDisabled !== undefined) {
      query.possibleForDisabled = filters.possibleForDisabled;
    }
    if (filters.salaryMin || filters.salaryMax) {
      query["salary.amount"] = {};
      if (filters.salaryMin) {
        query["salary.amount"].$gte = filters.salaryMin;
      }
      if (filters.salaryMax) {
        query["salary.amount"].$lte = filters.salaryMax;
      }
    }
    if (filters.startDate && filters.endDate) {
      query.startDate = { $gte: new Date(filters.startDate) };
      query.endDate = { $lte: new Date(filters.endDate) };
    }

    const jobs = await jobDB.findJobsByQuery(query);
    const users = await userDB.getUsersByIds(jobs.map(job => job.employerId));
    const applications = await applicationDB.getApplicationFilteredByJobId(jobs.map(job => job._id), 'open');

    const finalJobs = jobs.map(job => {
      const employer = users.find(u => u._id.toString() === job.employerId.toString());
      const jobApplications = applications.filter(app => app.jobId.toString() === job._id.toString());
      return new viewJobDTO(job, jobApplications, employer);
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
    return { success: true, data: job };
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
    //console.log("User ID received:", userId); // This logs the user ID being passed
    //const userObjectId = new mongoose.Types.ObjectId(userId); // Convert string to ObjectId
   // console.log("Converted ObjectId:", userId); // This logs the converted ObjectId
    const jobs = await jobDB.getMyPostedJobs(userId); // Fetch jobs using the converted ObjectId
    //const jobs = await Job.find({ employerId: userObjectId, status: { $ne: 'closed' } });
   // console.log("Jobs fetched:", jobs); // This logs the fetched jobs

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

    const employees = await findEligibleUsers(job); // Find eligible users for the job
    console.log("✅ Eligible workers found in jobservice:", employees?.length || 0);

    const branchType = job.branch;
    const usersWithRating = [];

    for (const user of employees) {
      const viewUser = new viewUserDTO(user);

      // ✅ Тухайн ажлын төрөлтэй тохирох үнэлгээг авах
      let branchRating = 0;
      const found = Array.isArray(viewUser.averageRating?.byBranch)
        ? viewUser.averageRating.byBranch.find(
            r => r.branchType === branchType
          )
        : null;
      branchRating = found?.score || 0;

      usersWithRating.push({
        user: new UserDTO(user),
        rating: branchRating,
      });
    }

    // ✅ Рейтингээр бууруулж эрэмбэлэх
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
  getSuitableWorkersByJob
};
