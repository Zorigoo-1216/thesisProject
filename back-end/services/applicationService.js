const applicationDB = require('../dataAccess/applicationDB');
const Application = require('../models/Application');
const Job = require('../models/Job');
const notificationService = require("../services/notificationService");
const JobDb = require("../dataAccess/jobDB")

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
  return await applicationDB.getAllAppliedJobsByUserId(userId);
}
// tuhain ajild huselt ilgeesen ajilchdiig avah
const getAppliedUsersByJob = async (jobId) => {
  return await applicationDB.getAppliedUsersByJobId(jobId);
}
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
  if (!job.haveInterview) {
    job.employees = selectedUserIds;
    await job.save();
  }

  await Promise.all(updates);
  return "Сонгогдсон ажилчид амжилттай бүртгэгдлээ";
}

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


const getInterviewsByJob = async (jobId) => {
  const job = await JobDb.getJobById(jobId);
  if (!job) throw new Error("Job not found");
  const applications = await applicationDB.getInterviewUsers(jobId);
  return applications;
}
const getEmployeesByJob = async (jobId) => {
  const job = await JobDb.getJobById(jobId);
  if (!job) throw new Error("Job not found");
  const employers = await JobDb.getEmployeesByJob(jobId);
  return employers;
}


const getCandidatesByJob = async (jobId) => {
  const job = await Job.findById(jobId);
  if (!job) throw new Error("Job not found");
  const candidates = await applicationDB.getCandidatesByJob(jobId);
  return candidates;
}


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