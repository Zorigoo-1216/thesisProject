const applicationDB = require('../dataAccess/applicationDB');
const Application = require('../models/Application');
const Job = require('../models/Job');
const notificationService = require("../services/notificationService");
const JobDb = require("../dataAccess/jobDB");
const User = require('../models/User');
const userDB = require("../dataAccess/userDB");
const viewUserDTO = require("../viewModels/viewUserDTO");
const mongoose = require("mongoose");
// ajild huselt ilgeeh
const applyToJob = async (userId, jobId) => {
  try {
    const existing = await Application.findOne({ userId, jobId });
    if (existing) return { success: false, message: "Та энэ ажилд аль хэдийн хүсэлт илгээсэн байна" };

    const application = await applicationDB.createApplication(userId, jobId);
    if (!application || !application._id) {
      return { success: false, message: "Application хадгалах үед алдаа гарлаа" };
    }

    //console.log("📨 Adding application to job:", jobId, application._id.toString());

    const updatedJob = await JobDb.updateJobApplications(jobId, application._id.toString());
    if (!updatedJob) return { success: false, message: "Job not found" };

    try {
      await notifyApplication(application._id);
    } catch (err) {
      console.error("❌ Notification failed:", err.message);
    }

    return { success: true, message: "Өргөдөл амжилттай илгээгдлээ." };
  } catch (error) {
    console.error("Error applying to job:", error.message);
    return { success: false, message: error.message };
  }
};

const notifyApplication = async (appID) => {
  try {
    const application = await applicationDB.getApplicationById(appID);
    if (!application) return { success: false, message: "Application not found" };

    await notificationService.sendapplyNotToEmployer(application);
    return { success: true, message: "Notification sent successfully" };
  } catch (error) {
    console.error("Error notifying application:", error.message);
    return { success: false, message: error.message };
  }
};

const getMyAppliedJobs = async (userId, status) => {
  try {
    const jobs = await applicationDB.getAppliedJobsByUserId(userId, status);
    return { success: true, data: jobs };
  } catch (error) {
    console.error("Error getting applied jobs:", error.message);
    return { success: false, message: error.message };
  }
};

const getMyAllAppliedJobs = async (userId) => {
  try {
    const application = await applicationDB.getAllAppliedJobsByUserId(userId);
    return { success: true, data: Array.isArray(application) ? application : [] };
  } catch (error) {
    console.error("Error getting all applied jobs:", error.message);
    return { success: false, message: error.message };
  }
};

const selectCandidatesfromInterview = async (jobId, selectedUserIds) => {
  try {
    if (!selectedUserIds || selectedUserIds.length === 0) {
      return { success: false, message: "No users selected for interview" };
    }

    const job = await JobDb.getJobById(jobId);
    if (!job) return { success: false, message: "Job not found" };

    //console.log("🔥 selectedUserIds:", selectedUserIds);

    const applications = await Application.find({ jobId, status: 'interview' });

    //console.log("✅ SELECTED USERS:", selectedUserIds);

    await Promise.all(
      applications.map(async (app) => {
        const isSelected = selectedUserIds.includes(app.userId.toString());
        const status = isSelected ? 'accepted' : 'rejected';
        return Application.findByIdAndUpdate(app._id, { status });
      })
    );

    const validUserIds = selectedUserIds.filter((id) =>
      mongoose.Types.ObjectId.isValid(id)
    );
    job.employees = validUserIds.map((id) => new mongoose.Types.ObjectId(id));

    await job.save();

    const updatedApplications = await Application.find({ jobId });
    // console.log(
    //   "🧪 Applications after update:",
    //   updatedApplications.map((a) => ({ id: a._id, status: a.status }))
    // );
    //console.log("📋 Final employees to assign:", selectedUserIds);

    return { success: true, message: "Сонгогдсон ажилчид амжилттай бүртгэгдлээ" };
  } catch (error) {
    console.error("Error selecting candidates from interview:", error.message);
    return { success: false, message: error.message };
  }
};
const selectCandidates = async (jobId, selectedUserIds) => {
  const job = await JobDb.getJobById(jobId);
  if (!job) throw new Error("Job not found");

  //console.log("🔥 selectedUserIds:", selectedUserIds);

  const allApplications = await applicationDB.getApplciationByJobId(
    jobId,
    "pending"
  );

  const updates = allApplications.map((app) => {
    const isSelected = selectedUserIds.includes(app.userId.toString());
    const status = job.hasInterview
      ? isSelected
        ? "interview"
        : "rejected"
      : isSelected
        ? "accepted"
        : "rejected";

    return Application.findByIdAndUpdate(app._id, { status });
  });

  await Promise.all(updates);

  // 🧼 description-ыг string болгож шалгах
  if (typeof job.description !== "string") {
    if (Array.isArray(job.description)) {
      job.description = job.description.join(", ");
    } else {
      job.description = "Тайлбар оруулаагүй";
    }
  }

  // ✅ hasInterview байхгүй үед шууд employee-д нэмэх
  if (!job.hasInterview) {
    const isValidObjectId = (id) => mongoose.Types.ObjectId.isValid(id);

    job.employees = selectedUserIds
      .filter((id) => isValidObjectId(id))
      .map((id) => new mongoose.Types.ObjectId(id));

    await job.save(); // ❗️save-г description зөв болсны дараа л дуудах
  }

  return "Сонгогдсон ажилчид амжилттай бүртгэгдлээ";
};





const getInterviewsByJob = async (jobId) => {
  const job = await Job.findById(jobId);
  if (!job) throw new Error("Job not found");

  //const applications = await Application.find({ jobId });
  const applications = await applicationDB.getApplciationByJobId(jobId, "interview");
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
  try {
    const job = await Job.findById(jobId);
    if (!job) return { success: false, message: "Job not found" };

    const applications = await applicationDB.getApplciationByJobId(jobId, "pending");
    const usersWithRating = [];

    for (const app of applications) {
      const user = await User.findById(app.userId);

      if (user) {
        const viewUser = new viewUserDTO(user);
        const branchType = job.branch;

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

    usersWithRating.sort((a, b) => b.rating - a.rating);

    return { success: true, data: usersWithRating };
  } catch (error) {
    console.error("Error getting applied users by job:", error.message);
    return { success: false, message: error.message };
  }
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

  return employees.map(user => new viewUserDTO(user));
};



const getCandidatesByJob = async (jobId) => {
  const job = await Job.findById(jobId);
  if (!job) throw new Error("Job not found");

  //const applications = await Application.find({ jobId, status: "accepted" });
  const applications = await applicationDB.getApplciationByJobId(jobId, "accepted");
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
  try {
    const job = await JobDb.getJobById(jobId);
    if (!job) return { success: false, message: "Job not found" };

    await applicationDB.cancelApplication(jobId, userId);
    return { success: true, message: "Application canceled" };
  } catch (error) {
    console.error("Error canceling application:", error.message);
    return { success: false, message: error.message };
  }
};
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