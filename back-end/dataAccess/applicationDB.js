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
const getAppliedJobsByUserId = async (userId) => {
    const applications =  await Application.find({ userId : userId , status:  { $ne: "closed" } });
    const jobs= [];
    for (const application of applications) {
        const job = await Job.findById(application.jobId);
        if (job) {
          jobs.push(new viewJobDTO(job));
        }
    }
    return jobs;
}
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
      return jobs;
}
// ajild huselt ilgeesen humuusiig erembeleed ilgeene
const getAppliedUsersByJobId = async (jobId) => {
  const job = await Job.findById(jobId);
  if (!job) throw new Error("Job not found");
  
    const applications = await Application.find({ jobId });
    const usersWithRating = [];
    
    for (const application of applications) {
      const user = await User.findById(application.userId);
      if (user) {
        let branchScore = 0;
        
        if (Array.isArray(user.averageRating?.byBranch)) {
          const branchRating = user.averageRating.byBranch.find(
            (r) => r.brachType === job.branch
          );
          branchScore = branchRating?.score || 0;
        } else {
          branchScore = user.averageRating?.byBranch?.[job.branchType] || 0;
        }
        
        usersWithRating.push({
          user: new viewUserDTO(user),
          rating: branchScore
        });
      }
    }
  
    // Эрэмбэлэх
    usersWithRating.sort((a, b) => b.rating - a.rating);
    
    // Зөвхөн хэрэглэгчийн DTO-г буцаана
    return usersWithRating.map(obj => obj.user);
  };

  const getInterviewUsers = async (jobId) => {
    const job = await Job.findById(jobId);
    if (!job) throw new Error("Job not found");
  
    const applications = await Application.find({ jobId, status: 'interview' });
    const branch = job.branchType || job.branch;
  
    const usersWithRating = [];
  
    for (const application of applications) {
      const user = await User.findById(application.userId);
      if (user) {
        const branchRating = user.averageRating?.byBranch?.find(
          (r) => r.branch === branch
        );
        const branchScore = branchRating?.score || 0;
  
        usersWithRating.push({
          user: new viewUserDTO(user),
          rating: branchScore,
        });
      }
    }
  
    // Эрэмбэлэх
    usersWithRating.sort((a, b) => b.rating - a.rating);
  
    return usersWithRating.map((obj) => obj.user);
  };
  

// application-Уудыг jobId-ээр нь олно
const getApplciationByJobId = async (jobId) => {
  return await Application.find({ jobId: jobId });
}
const getApplicationFilteredByJobId = async (jobId, status) => {
  return await Application.find({ jobId: jobId, status: status });
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
  
  return candidates;
}


const cancelApplication = async (jobId, userId) => {
  const application = await Application.findOneAndDelete({ jobId: jobId, userId: userId });
  if (!application) throw new Error("Application not found");
  await Job.findByIdAndUpdate(jobId, { $pull: { applications: application._id } });
  return "Application canceled";
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
    cancelApplication

};