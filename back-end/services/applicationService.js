const applicationDB = require('../dataAccess/applicationDB');
const Application = require('../models/Application');
const Job = require('../models/Job');
const notificationService = require("../services/notificationService");
const JobDb = require("../dataAccess/jobDB");
const User = require('../models/User');
const userDB = require("../dataAccess/userDB");
const viewUserDTO = require("../viewModels/viewUserDTO");
// ajild huselt ilgeeh
const applyToJob = async (userId, jobId) => {
  const existing = await Application.findOne({ userId, jobId });
  if (existing) throw new Error("Та энэ ажилд аль хэдийн хүсэлт илгээсэн байна");

  const application = await applicationDB.createApplication(userId, jobId);
  if (!application || !application._id) {
    throw new Error("Application хадгалах үед алдаа гарлаа");
  }

  console.log("📨 Adding application to job:", jobId, application._id.toString());

  const updatedJob = await JobDb.updateJobApplications(jobId, application._id.toString());

  if (!updatedJob) throw new Error("Job not found");

  try {
    await notifyApplication(application._id);
  } catch (err) {
    console.error("❌ Notification failed:", err.message);
  }

  return "Өргөдөл амжилттай илгээгдлээ.";
}

// ajillah huseltiin ilgeehd ajil olgogchid medegdel ilgeeh 
const notifyApplication = async (appID) => {
    //const application = await Application.findOne({ _id : appID });
    const application = await applicationDB.getApplicationById(appID);
    if (!application) throw new Error("Application not found");

    await notificationService.sendapplyNotToEmployer(application);
    return "Notification sent successfully";
};
// ajliin huselt ilgeesen ajluudiig avah
const getMyAppliedJobs = async (userId) => {
  return await applicationDB.getAppliedJobsByUserId(userId);
}
// ajliin huselt ilgeesen buh ajluudiig avah
const getMyAllAppliedJobs = async (userId) => {
  const application = await applicationDB.getAllAppliedJobsByUserId(userId);
  return Array.isArray(application) ? application : [];
}
// tuhain ajild huselt ilgeesen ajilchdiig avah

const selectCandidatesfromInterview = async (jobId, selectedUserIds) => {
  if (!selectedUserIds || selectedUserIds.length === 0) {
    throw new Error("No users selected for interview");
  }

  const job = await JobDb.getJobById(jobId);
  if (!job) throw new Error("Job not found");

  const applications = await Application.find({ jobId, status: 'interview' });

  console.log("✅ SELECTED USERS:", selectedUserIds);

  // 🛠 Статус шинэчлэхийг зөв хийж байна
  const updates = await Promise.all(applications.map(async (app) => {
    const isSelected = selectedUserIds.includes(app.userId.toString());
    const status = isSelected ? 'accepted' : 'rejected';
    return Application.findByIdAndUpdate(app._id, { status });
  }));

  // 🟢 Сонгогдсон ажилчдыг job-д оноох
  job.employees = selectedUserIds;
  await job.save();

  // 🔍 Статус шинэчлэгдсэнийг шалгах лог
  const updatedApplications = await Application.find({ jobId });
  console.log("🧪 Applications after update:", updatedApplications.map(a => ({ id: a._id, status: a.status })));
  console.log("📋 Final employees to assign:", selectedUserIds);

  return "Сонгогдсон ажилчид амжилттай бүртгэгдлээ";
};
const selectCandidates = async (jobId, selectedUserIds) => {
  const job = await JobDb.getJobById(jobId);
  if (!job) throw new Error("Job not found");

  const allApplications = await applicationDB.getApplciationByJobId(jobId);
  const updates = allApplications.map(app => {
    const isSelected = selectedUserIds.includes(app.userId.toString());
    const status = job.haveInterview
      ? (isSelected ? 'interview' : 'rejected')
      : (isSelected ? 'accepted' : 'rejected');

    return Application.findByIdAndUpdate(app._id, { status });
  });

  // Хэрвээ interview байхгүй бол шууд employees талбарт нэмнэ
  if (!job.hasInterview) {
    job.employees = selectedUserIds;
    await job.save();
  }

  await Promise.all(updates);
  return "Сонгогдсон ажилчид амжилттай бүртгэгдлээ";
}




const getInterviewsByJob = async (jobId) => {
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
          (r) => r.branchType === job.branch
        );
        branchScore = branchRating?.score || 0;
      }

      usersWithRating.push({
        user: new viewUserDTO(user),
        rating: branchScore,
      });
    }
  }

  // Эрэмбэлэх
  usersWithRating.sort((a, b) => b.rating - a.rating);

  // Зөвхөн хэрэглэгчийн DTO-г буцаах
  return usersWithRating.map(obj => obj.user);
};
const getAppliedUsersByJob = async (jobId) => {
  const job = await Job.findById(jobId);
  if (!job) throw new Error("Job not found");

  const applications = await Application.find({ jobId });
  console.log("applications", applications);
  const usersWithRating = [];

  for (const app of applications) {
    const user = await User.findById(app.userId);

    if (user) {
      const viewUser = new viewUserDTO(user);
      const branchType = job.branch;

      // ✅ Тухайн ажлын төрөлтэй тохирох үнэлгээг авах
      let branchRating = 0;
      const found = Array.isArray(viewUser.averageRating.byBranch)
        ? viewUser.averageRating.byBranch.find(
            r => r.branchType === branchType
          )
        : null;
      branchRating = found?.score || 0;

      usersWithRating.push({
        user: viewUser,
        rating: branchRating,
      });
    }
  }

  console.log("usersWithRating", usersWithRating);

  // ✅ Рейтингээр бууруулж эрэмбэлэх
  usersWithRating.sort((a, b) => b.rating - a.rating);

  // ✅ Зөвхөн user болон rating-г буцаана
  return usersWithRating;
};
const getEmployeesByJob = async (jobId) => {
  const job = await Job.findById(jobId);
  if (!job) throw new Error("Job not found");

  const employees = await Promise.all(job.employees.map(async (employeeId) => {
    const user = await User.findById(employeeId.toString());
    return user;
  }));

  // Эрэмбэлэх: тухайн ажлын branch-р хамгийн өндөр score-той хэрэглэгчийг эхэнд нь
  employees.sort((a, b) => {
    const branch = job.branch;
    const aScore = a.averageRating?.byBranch?.find(r => r.branchType === branch)?.score || 0;
    const bScore = b.averageRating?.byBranch?.find(r => r.branchType === branch)?.score || 0;
    return bScore - aScore;
  });

  return employees.map(user => new ViewUserDTO(user));
};



const getCandidatesByJob = async (jobId) => {
  const job = await Job.findById(jobId);
  if (!job) throw new Error("Job not found");

  const applications = await Application.find({ jobId, status: "accepted" });
  const usersWithRating = [];

  for (const application of applications) {
    const user = await userDB.getUserById(application.userId); //await  User.findById(application.userId);
    if (user) {
      const byBranch = user.averageRating?.byBranch || [];
      const ratingEntry = byBranch.find(r => r.branchType === job.branch);
      const branchScore = ratingEntry?.score || 0;

      usersWithRating.push({
        user: new viewUserDTO(user),
        rating: branchScore
      });
    }
  }

  // ✨ Эрэмбэлэх: өндөр оноотой нь эхэнд
  usersWithRating.sort((a, b) => b.rating - a.rating);

  return usersWithRating;
};



const cancelApplication = async (userId, jobId) => {
    const job = await JobDb.getJobById(jobId);
    if (!job) throw new Error("Job not found");
    await applicationDB.cancelApplication(jobId, userId);
    return "application canceled";
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
  //selectCandidateForContract,
  cancelApplication
};