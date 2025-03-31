const jobDB = require("../dataAccess/jobDB");
const userDB = require("../dataAccess/userDB");
const notificationDB = require("../dataAccess/notificationDB");

// Ajliin zar uusgeh
// const createJob = async (employerId, jobData) => {
//     const job = {
//         ...jobData,
//         employerId,
//         createdAt: new Date(),
//         updatedAt: new Date(),
//         status: 'open'
//     };

//     const createdJob = await jobDb.createJob(job);
//     const eligibleUsers = await findEligibleEmployees(createdJob);  
//     await notifyEligibleUsers(createdJob, eligibleUsers);  
//     return "Job created successfully";
// };
// // Ajliin zarand tohirson ajilchidig oloh
// const findEligibleEmployees = async (createdJob) => {
//     return await jobDb.getPossibleEmployees(createdJob); 
// };
// // tohirson achilchdad medegdel ilgeeh
// const notifyEligibleUsers = async (job, eligibleUsers) => {
//     if (!eligibleUsers || eligibleUsers.length === 0) return;
    
//     const notifications = eligibleUsers.map(user => ({
//         userId: user._id,
//         type: 'job_match',
//         title: 'Танд тохирох ажил байна',
//         message: `${job.location} байршилд ${job.title} ажил зарлагдлаа.`,
//         createdAt: new Date(),
//     }));

//     await Notification.insertMany(notifications);
//     console.log(`${eligibleUsers.length} хэрэглэгчдэд мэдэгдэл илгээгдлээ.`);
// };

// const updateJob = async (jobId, updates, employerId) => {
//     const updatedJob = await jobDb.updateJob(jobId, updates, employerId);
//     if (!updatedJob) return "Job not found or you don't have permission to update this job.";
// }

// const deleteJob = async (jobId, employerId) => {
//       const deletedJob = await jobDb.deleteJob(jobId, employerId);
//       if (!deletedJob) return "Job not found or you don't have permission to delete this job.";
// }


const createJob = async (jobData) => {

    const job = await jobDB.createJob(jobData);  // job iig uusgene 
    const eligibleUsers = await userDB.getEligibleUsersForJob(job);  // ajliin zard tohiroh ajilchdiig oloh function
    for (const user of eligibleUsers) {          // ajilchin burt medegdel ilgeene
      await notificationDB.sendJobMatchNotification(user._id, job);
    }
  
    return job;
  };
module.exports = { createJob };
