const jobDB = require("../dataAccess/jobDB");
const userDB = require("../dataAccess/userDB");
const notificationService = require("../services/notificationService"); // зөв service
const viewJobDTO = require("../viewModels/viewJobDTO"); // jobDTO
// ajliin zar uusgeh 
const createJob = async (jobData, employerId) => {
  if (jobData.haveInterview) {
    console.log("🗓 Interview required. Please prepare interview setup.");
  }
  const job = await jobDB.createJob(jobData, employerId); // Job үүсгэх

  const eligibleUsers = await findEligibleUsers(job); 
  console.log("Eligible users:", eligibleUsers?.length || 0);

  if (Array.isArray(eligibleUsers) && eligibleUsers.length > 0) {
    await notifyEligibleUsers(job, eligibleUsers); // мэдэгдэл илгээх
  }

  return job;
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

  return await userDB.findUsersByQuery(query);
};

// tohirson ajilchdad medegdel ilgeeh
const notifyEligibleUsers = async (job, users) => {
  await notificationService.sendBulkNotifications(users, job);
};

// ajliin jagsaaltiig default aar haruulah
const getJobList = async () => {
  const jobs = await jobDB.getdJoblist(); // Ажлын зарын жагсаалтыг авах
  return jobs;
};

// ajliin zar filter eer haih
const searchJobs = async (filters) => {
  const query = {
    endDate: { $gt: new Date() }, 
    status: 'open'               
  };

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

  return await jobDB.findJobsByQuery(query);
};

// ajliin zar iig id-aar avah
const getJobById = async (jobId) => {
  const job = await jobDB.getJobById(jobId);
  if (!job) {
    throw new Error('Job not found');
  }
  return job;
};

const getSuitableJobsForUser = async (userId, filters) => {
  const user = await userDB.getUserById(userId);
  if (!user.profile || !user.profile.skills || user.profile.skills.length === 0) {
    return []; // instead of throwing
  }
  const jobs = await jobDB.getJobLisForUser(user, filters);

  let filtered = jobs;

  // filter by time availability
  if (user.schedule && user.schedule.length > 0) {
    filtered = filtered.filter(job => {
      return !user.schedule.some(s =>
        (s.startDate <= job.endDate && s.endDate >= job.startDate)
      );
    });
  }

  // sort logic
  if (filters.sort === 'salary') {
    filtered.sort((a, b) => b.salary.amount - a.salary.amount);
  } else if (filters.sort === 'recent') {
    filtered.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  }
  if (filters.salaryMin || filters.salaryMax) {
    query["salary.amount"] = {};
    if (filters.salaryMin) query["salary.amount"].$gte = +filters.salaryMin;
    if (filters.salaryMax) query["salary.amount"].$lte = +filters.salaryMax;
  }
  return filtered.map(job => new viewJobDTO(job));
};

const getUserPostedJobHistory = async (userId) => {
  const jobs = await jobDB.getUserPostedJobHistory(userId); // Ажлын зарын жагсаалтыг авах
  return jobs;
};

const editJob = async (jobId, updates, userId, role) => {
  const job = await jobDB.getJobById(jobId);
  if (!job) throw new Error('Job not found');

  // зөвхөн өөрийн ажил болон admin бол засах эрхтэй
  if (job.employerId.toString() !== userId && role !== 'admin') {
    throw new Error('Permission denied');
  }

  updates.updatedAt = new Date();
  const updatedJob = await jobDB.updateJob(jobId, updates);
  return updatedJob;
};

const deleteJob = async (jobId, userId, role) => {
  const job = await jobDB.getJobById(jobId);
  if (!job) throw new Error('Job not found');

  // зөвхөн өөрийн ажил болон admin бол устгах эрхтэй
  if (job.employerId.toString() !== userId && role !== 'admin') {
    throw new Error('Permission denied');
  }

  return await jobDB.deleteJob(jobId);
};

const getMyPostedJobs = async (userId) => {
  const jobs = await jobDB.getMyPostedJobs(userId); // Ажлын зарын жагсаалтыг авах
  return jobs;
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
  getMyPostedJobs
};
