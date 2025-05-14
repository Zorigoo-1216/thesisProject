const Job = require("../models/Job");
const Application = require('../models/Application');
const User = require('../models/User');
const viewJobDTO = require("../viewModels/viewJobDTO");
const viewUserDTO = require("../viewModels/viewUserDTO");
const mongoose = require('mongoose');
//------------------------Create jobs------------------------

// Ажлын зар үүсгэх
const createJob = async (jobData) => {
  const job = new Job(jobData);
  return await job.save();
};


// hereglegchiin uusgesen zariin jagsaaltiig haruulah
const getUserPostedJobHistory = async (userId) => {
    const jobs = await Job.find({employerId: userId, status: { $ne: 'closed' } });
    const userJobs = await Promise.all(jobs.map(async (job) => {
        const applications = await Application.find({ jobId: job._id });
        const employees = await User.find({ _id: { $in: job.employees } });
    
         testjob =  new viewJobDTO(job, applications, employees);
       // console.log(testjob);
        return testjob;
      }));
    return userJobs;
}
// zariin jagsaaltiig haruulah
const getdJoblist = async () => {
    const jobs = await Job.find({
        endDate: { $gt: new Date()},
        status: 'open' });
   
    return jobs;
}


/**
 * Finds jobs by a given query.
 * 
 * @param {Object} query - The MongoDB query to filter the jobs by.
 * @returns {Promise<Object[]>} A promise resolving to an array of Job objects.
 * 
 * @note The query is sorted by the createdAt field in descending order (newest first).
 */
const findJobsByQuery = async (query) => {
   return await Job.find(query).sort({ createdAt: -1 });
  };


// ajliin zar iig id-aar avah
const getJobById = async (id) => {
    return await Job.findById(id);
}
// ajliin huselt ilgeesen ajliin zar der huseltiig ni nemeh
const updateJobApplications = async (jobId, applicationId) => {
  try {
    const updatedJob = await Job.findByIdAndUpdate(
      jobId,
      { $addToSet: { applications: applicationId } },
      { new: true }
    );

    if (!updatedJob) {
      console.log("⚠️ Job not found when trying to update applications");
    } else {
      console.log("✅ Application added to job:", updatedJob.applications);
    }

    return updatedJob;
  } catch (err) {
    console.error("❌ Error updating job applications:", err.stack);
    throw err;
  }
}

const getJobLisForUser = async (user, filters) => {
  const query = {
      status: 'open',
      endDate: { $gte: new Date() },
      'requirements': { $in: user.profile.skills },
      'salary.amount': { $lte: user.profile.waitingSalaryPerHour },
      ...(filters.branchType && { branchType: filters.branchType }),
      ...(filters.location && { location: filters.location }),
      ...(filters.possibleForDisabled !== undefined && {
        possibleForDisabled: filters.possibleForDisabled
      }),
      ...(user.profile.mainBranch && { branchType: user.profile.mainBranch })
    };
  
    return await Job.find(query);
};


  const updateJob = async (jobId, updates) => {
    return await Job.findByIdAndUpdate(jobId, { $set: updates }, { new: true });
  }

  const deleteJob = async (jobId) => {
    return await Job.findByIdAndUpdate(jobId, { status: 'deleted' });
  }
  const getMyPostedJobs = async (userId) => {
  const endDate = new Date();
   return await Job.find({ employerId: userId, status: { $ne: 'deleted', $ne: 'completed' }, endDate: { $gte: endDate } });
    
  }
  const getEmployeesByJob = async (jobId) => {
    const job = await Job.findById(jobId);
    if (!job) throw new Error("Job not found");
    console.log("👥 EMPLOYEES:", job.employees);
    
    const employees = await Promise.all(job.employees.map(async (employeeId) => {
      const employee = await User.findById(employeeId.toString());
      return new viewUserDTO(employee);
    })
  
  );
    
  return employees;

  }

  const cancelApplication = async (jobId, userId) => {
    const job = await Job.findById(jobId);
    if (!job) throw new Error("Job not found");
    job.applications = job.applications.filter(
      appId => appId.toString() !== userId.toString()
    );
    return await job.save();
  }
  const findUsersByQuery = async (query) => {
    return await User.find(query);
  };
  const addEmployeeToJob = async (jobId, employeeId) => {
    const job = await Job.findById(jobId);
    if (!job) throw new Error("Job not found");
    job.employees.push(employeeId);
    return await job.save();
  } 

  const updateJobStatus = async (jobId, newStatus) => {
    return await Job.findByIdAndUpdate(jobId, { status: newStatus });
  };
  
  /**
   * Gets the top 5 jobs by views, sorted in descending order.
   * @returns {Object[]} An array of the top 5 jobs.
   */
  const getTopJobs = async () => {
    return await Job.find().sort({ views: -1 }).limit(5);
  }


module.exports = {
    createJob, 
    getdJoblist, 
    findJobsByQuery, 
    getJobById,
    updateJobApplications,
    getJobLisForUser,
    updateJob,
    deleteJob,
    getUserPostedJobHistory,
    getMyPostedJobs,
    getEmployeesByJob,
    cancelApplication,
    findUsersByQuery,
    addEmployeeToJob,
    updateJobStatus,
    getTopJobs
};