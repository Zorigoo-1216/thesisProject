const Application = require('../models/Application');
const Job = require('../models/Job');
const viewJobDTO = require('../viewModels/viewJobDTO');
const viewUserDTO = require('../viewModels/viewUserDTO');
const User = require('../models/User');

//------------------------Create applications------------------------
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

// Hereglegchiin huselt ilgeesen ajluudiig olno
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

// hereglegchiin huselt ilgeesen buh ajluudiig olno
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
// ajild huselt ilgeesen humuusiig erembeleed ilgeene
const getAppliedUsersByJobId = async (jobId) => {
  const job = await Job.findById(jobId);
  if (!job) throw new Error("Job not found");
  
    const applications = await Application.find({ jobId });
    const users = applications.map(app => User.findById(app.userId));
    return users.map(user => new viewUserDTO(user));
  };

  const getInterviewUsers = async (jobId) => {
    const job = await Job.findById(jobId);
    if (!job) throw new Error("Job not found");
    const applications = await Application.find({ jobId });
    const users = applications.map(app => User.findById(app.userId)); 
    return users.map(user => new viewUserDTO(user));
    // Эрэмбэлэх
   
  };
  

// application-Уудыг jobId-ээр нь олно
const getApplciationByJobId = async (jobId, status) => {
  return await Application.find({ jobId: jobId, status: status });
}
const getApplicationFilteredByJobId = async (jobId) => {
  return await Application.find({ jobId: { $in: jobId } });
}

// hereglegchiin ilgeesen huseltuudiig olno ene ni idevhitei bga ajluudiig songono
const getapplicationsByUserId = async (userId) => {
  return await Application.find({ userId : userId , status:  { $ne: "closed" } });
}

// application-ийг id-ээр нь буцаана
const getApplicationById = async (appID) => {
  return await Application.findById(appID);
}
  
  
  // hereglegchiin ajil ni idevhitei bga huseltuudiig butsaana 
const getMyApplications = async (userId) => {
  return await Application.find({ userId: userId, status: { $ne: "closed" } });
}
// Hereglegchiin application-ийг avna
const getMyAllApplications = async (userId) => {
    return await Application.find({ userId: userId });
  }

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


const cancelApplication = async (jobId, userId) => {
  const application = await Application.findOneAndDelete({ jobId: jobId, userId: userId });
  if (!application) throw new Error("Application not found");
  await Job.findByIdAndUpdate(jobId, { $pull: { applications: application._id } });
  return "Application canceled";
}

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
    //-----------------------------------------------------------
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