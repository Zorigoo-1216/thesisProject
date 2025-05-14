const applicationDB = require('../dataAccess/applicationDB');
const Application = require('../models/Application');
const Job = require('../models/Job');
const notificationService = require("../services/notificationService");
const JobDb = require("../dataAccess/jobDB");
const User = require('../models/User');
const userDB = require("../dataAccess/userDB");
const viewUserDTO = require("../viewModels/viewUserDTO");
const mongoose = require("mongoose");


/**
 * Applies a user to a job.
 * @param {string} userId - The ID of the user applying to the job.
 * @param {string} jobId - The ID of the job the user is applying to.
 * @returns {Object} A JSON response with a "success" flag and a message.
 * @throws {Error} If an internal server error occurs during the application process.
 * 
 * @apiParam {String} userId - The ID of the user applying to the job.
 * @apiParam {String} jobId - The ID of the job the user is applying to.
 * 
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Application submitted successfully"
 * }
 * 
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 */
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
    const user = await userDB.getUserById(userId);
    try {
      const notificationData = {
        userId: updatedJob.employerId,
          type: "application_received",
          title: "Шинэ ажиллах хүсэлт ирлээ",
          message: `Таны ${updatedJob.title} ажилд ${user.firstName} хүсэлт илгээжээ`,
        };
      const notificationResult = await notificationService.sendNotification(userId, notificationData);
      if (!notificationResult) {
        console.error("❌ Notification failed:", notificationResult.message);
      } else {
        console.log("📨 Notification sent:", notificationData);
      }
    } catch (err) {
      console.error("❌ Notification failed:", err.message);
    }

    return { success: true, message: "Өргөдөл амжилттай илгээгдлээ." };
  } catch (error) {
    console.error("Error applying to job:", error.message);
    return { success: false, message: error.message };
  }
};



/**
 * Gets a list of jobs a user has applied to.
 * @param {string} userId - The ID of the user.
 * @param {string} [status] - The status of the applications to return. If not provided, all applications will be returned.
 * @returns {Object} A JSON response with a "success" flag, a message and a "data" property containing the list of jobs.
 * @throws {Error} If an internal server error occurs while getting the applied jobs.
 * 
 * @apiParam {String} userId - The ID of the user.
 * @apiParam {String} [status] - The status of the applications to return. If not provided, all applications will be returned.
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Applied jobs fetched successfully",
 *   data: [
 *     {
 *       _id: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       userId: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       jobId: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       status: "pending",
 *       createdAt: "2020-11-10T05:21:39.116Z",
 *       updatedAt: "2020-11-10T05:21:39.116Z",
 *       __v: 0
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
const getMyAppliedJobs = async (userId, status) => {
  try {
    const jobs = await applicationDB.getAppliedJobsByUserId(userId, status);
    return { success: true, data: jobs };
  } catch (error) {
    console.error("Error getting applied jobs:", error.message);
    return { success: false, message: error.message };
  }
};



/**
 * Gets all jobs a user has applied to.
 * @param {string} userId - The ID of the user.
 * @returns {Object} A JSON response with a "success" flag, a message and a "data" property containing the list of jobs.
 * @throws {Error} If an internal server error occurs while getting the applied jobs.
 * 
 * @apiParam {String} userId - The ID of the user.
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Applied jobs fetched successfully",
 *   data: [
 *     {
 *       _id: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       userId: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       jobId: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       status: "pending",
 *       createdAt: "2020-11-10T05:21:39.116Z",
 *       updatedAt: "2020-11-10T05:21:39.116Z",
 *       __v: 0
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
const getMyAllAppliedJobs = async (userId) => {
  try {
    const application = await applicationDB.getAllAppliedJobsByUserId(userId);
    return { success: true, data: Array.isArray(application) ? application : [] };
  } catch (error) {
    console.error("Error getting all applied jobs:", error.message);
    return { success: false, message: error.message };
  }
};



/**
 * Selects candidates from interview for a given job.
 * 
 * @param {string} jobId - The ID of the job for which candidates are selected.
 * @param {string[]} selectedUserIds - Array of user IDs selected from the interview.
 * @returns {Object} A JSON response with a "success" flag and a message.
 * 
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Сонгогдсон ажилчид амжилттай бүртгэгдлээ"
 * }
 * 
 * @apiError {Boolean} success - False if there is an error or no users are selected.
 * @apiError {String} message - Error message specifying the type of error encountered.
 * @apiErrorExample {json} Error-Response:
 *   { success: false, message: "No users selected for interview" }
 * 
 * @apiErrorExample {json} Job-Not-Found:
 *   { success: false, message: "Job not found" }
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 *   { success: false, message: "Internal Server Error" }
 */

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
    const userIds  = applications.map((app) => app.userId.toString());
    const result = await notificationService.sendNotification(userIds, 
      { title: job.title, message: `Та ${job.title} ажилд тэнцлээ`, type: 'application_received' });
    if (!result)  {
      console.log('Error sending notification:', result);
    } else {
      console.log('Notification sent successfully:', result);
    }
    return { success: true, message: "Сонгогдсон ажилчид амжилттай бүртгэгдлээ" };
  } catch (error) {
    console.error("Error selecting candidates from interview:", error.message);
    return { success: false, message: error.message };
  }
};



/**
 * Selects candidates for a job.
 * @param {string} jobId ID of the job to select candidates for.
 * @param {string[]} selectedUserIds IDs of the users to select as candidates.
 * @returns {Promise<string>} A promise that resolves to a success message.
 * @throws {Error} If the job is not found.
 */
const selectCandidates = async (jobId, selectedUserIds) => {
  const job = await JobDb.getJobById(jobId);
  if (!job) throw new Error("Job not found");

  //console.log("🔥 selectedUserIds:", selectedUserIds);

  const allApplications = await applicationDB.getApplciationByJobId(
    jobId,
    "pending"
  );

  const updates = allApplications.map(async (app) => {
    const isSelected = selectedUserIds.includes(app.userId.toString());
    const status = job.hasInterview
      ? isSelected
        ? "interview"
        : "rejected"
      : isSelected
        ? "accepted"
        : "rejected";
        let message = "";
        if (status === "interview") {
          message = `Та "${job.title}" ажлын ярилцлагад уригдлаа`;
        } else if (status === "accepted") {
          message = `Та "${job.title}" ажилд тэнцсэн байна`;
        } else {
          message = `Уучлаарай, "${job.title}" ажилд тэнцээгүй байна`;
        }
        const result = await notificationService.sendNotification(app.userId.toString(), {
          title: job.title,
          message,
          type: "application_received",
        });
        if (!result) {
          console.log("Error sending notification:", result);
        } else  {
          console.log("Notification sent successfully:", result);
        }
      
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
      .filter(isValidObjectId)
      .map((id) => new mongoose.Types.ObjectId(id));

    await job.save(); // ❗️save-г description зөв болсны дараа л дуудах
  }

  return { success: true, message: "Сонгогдсон ажилчид амжилттай бүртгэгдлээ" };
};



/**
 * @api {get} /application/getInterviewsByJob Get interviews by job
 * @apiName getInterviewsByJob
 * @apiGroup Application
 * @apiDescription Get interviews by job
 * @apiVersion  1.0.0
 * @apiPermission  User
 * 
 * @apiParam {String} jobId Job ID
 * 
 * @apiSuccess {Boolean} success true if success
 * @apiSuccess {String} message Success message
 * @apiSuccess {Object[]} data Interview list
 * 
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Interviews fetched successfully",
 *   data: [
 *     {
 *       _id: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       userId: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       jobId: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       status: "pending",
 *       createdAt: "2020-11-10T05:21:39.116Z",
 *       updatedAt: "2020-11-10T05:21:39.116Z",
 *       __v: 0
 *     }
 *   ]
 * }
 * 
 * @apiError {Boolean} success false
 * @apiError {String} message Error message
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "Job ID required"
 * }
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 */
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
  return usersWithRating;
};


/**
 * @api {get} /application/getAppliedUsersByJob Get users applied to a job
 * @apiName getAppliedUsersByJob
 * @apiGroup Application
 * @apiDescription Get users applied to a job
 * @apiVersion  1.0.0
 * @apiPermission  User
 * 
 * @apiParam {String} jobId Job ID
 * 
 * @apiSuccess {Boolean} success true if success
 * @apiSuccess {String} message Success message
 * @apiSuccess {Object[]} data Applied user list
 * 
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Applied users fetched successfully",
 *   data: [
 *     {
 *       _id: "5f9f1c7b5f9f1c7b5f9f1c7b",
 *       name: "John Doe",
 *       email: "john@example.com",
 *       username: "john123",
 *       phoneNumber: "+8801234567890",
 *       address: "Dhaka, Bangladesh",
 *       avatar: "https://example.com/avatar.jpg",
 *       rating: 4.5,
 *       createdAt: "2020-11-10T05:21:39.116Z",
 *       updatedAt: "2020-11-10T05:21:39.116Z",
 *       __v: 0
 *     }
 *   ]
 * }
 * 
 * @apiError {Boolean} success false
 * @apiError {String} message Error message
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "Job ID required"
 * }
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 */
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


/**
 * @function getEmployeesByJob
 * @description Get the employees who were hired to work on the given job, sorted by their rating in the job's branch
 * @param {string} jobId The ID of the job
 * @returns {Promise<{success: boolean, data: viewUserDTO[]} | {success: boolean, message: string}>} A promise that resolves with an array of viewUserDTO objects representing the employees, sorted by their rating in the job's branch. If the job is not found, the promise will reject with a 404 error.
 */
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

/**
 * Retrieves candidates for a given job, sorted by their rating in the job's branch.
 *
 * @param {String} jobId - The ID of the job for which candidates are being fetched.
 * @returns {Promise<Array<Object>>} A promise that resolves to an array of objects, each containing a user DTO and their branch-specific rating.
 * @throws {Error} If the job is not found.
 */

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

/**
 * Cancels a user's application for a specific job.
 *
 * @param {String} userId - The ID of the user canceling the application.
 * @param {String} jobId - The ID of the job for which the application is being canceled.
 *
 * @returns {Object} A JSON response indicating the success or failure of the cancelation request.
 * 
 * @apiSuccessExample {json} Success-Response:
 * {
 *   success: true,
 *   message: "Application canceled successfully"
 * }
 * 
 * @apiErrorExample {json} Error-Response:
 * {
 *   success: false,
 *   message: "Job not found"
 * }
 * 
 * @apiErrorExample {json} Internal-Server-Error:
 * {
 *   success: false,
 *   message: "Internal Server Error"
 * }
 */
const cancelApplication = async (userId, jobId) => {
  try {
    const job = await JobDb.getJobById(jobId);
    const user = await userDB.getUserById(userId);
    if (!job) return { success: false, message: "Job not found" };

    const  result = await applicationDB.cancelApplication(jobId, userId);
    const notResult = await notificationService.sendNotification(job.employerId, {title:"Ажиллах хүсэлт цуцаллаа", message: `${user.name} нэртэй ажилтан хүсэлтээ цуцалсан байна`, type:"cancelApplication"});
    if( !notResult ) {
      console.log("Notification sent error");
    } else {
      console.log("Notification sent");
    }
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
  cancelApplication
};