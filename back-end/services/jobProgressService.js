// services/jobProgressService.js

const jobDB = require('../dataAccess/jobDB');
const jobProgressDB = require('../dataAccess/jobProgressDB');
const notificationService = require('./notificationService');
const jobProgressDTO = require('../viewModels/viewJobProgressDTO');
const paymentDB = require('../dataAccess/paymentDB');
const paymentService = require('../services/paymentService');
const contractDB = require('../dataAccess/contractDB');
const { calculateSalary } = require('../utils/salaryCalculator');

const startJob = async (jobId, userId) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job) throw new Error('Job not found');

    const isAuthorized = job.employees.some(emp => emp.toString() === userId.toString());
    if (!isAuthorized) throw new Error('Not authorized');

    const contract = await contractDB.findByJobAndWorker(jobId, userId);
    if (!contract) throw new Error('Гэрээ үүсээгүй байна');

    const progress = await jobProgressDB.createJobProgress({
      jobId,
      workerId: userId,
      employerId: job.employerId,
      contractId: contract._id,
      status: 'pendingStart',
    });

    return { success: true, data: progress };
  } catch (error) {
    console.error('Error starting job:', error.message);
    return { success: false, message: error.message };
  }
};

const calculateWorkerSalary = async (jobId, workerId) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job) throw new Error('Job not found');

    const progress = await jobProgressDB.getByJobAndWorker(jobId, workerId);
    if (!progress) throw new Error('Job progress not found');

    const salaryResult = await calculateSalary(job, progress);

    await jobProgressDB.updateCalculatedSalary(progress._id, salaryResult.total);

    return { success: true, data: salaryResult };
  } catch (error) {
    console.error('Error calculating worker salary:', error.message);
    return { success: false, message: error.message };
  }
};

const getStartRequests = async (jobId, employerId) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job || job.employerId.toString() !== employerId.toString()) {
      throw new Error('Not authorized');
    }

    const requests = await jobProgressDB.getStartRequests(jobId);
    return { success: true, data: requests };
  } catch (error) {
    console.error('Error getting start requests:', error.message);
    return { success: false, message: error.message };
  }
};



const confirmStart = async (jobId, userId, jobprogressIds, startTime) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job) throw new Error('Job not found');
    if (job.employerId.toString() !== userId.toString()) throw new Error('Not authorized');

    const updateData = {
      status: 'in_progress',
      startedAt: startTime ? new Date(startTime) : new Date(),
      lastUpdatedAt: new Date(),
    };

    const updatedProgress = await jobProgressDB.updateJobProgress(jobprogressIds, updateData);
    return { success: true, data: updatedProgress };
  } catch (error) {
    console.error('Error confirming start:', error.message);
    return { success: false, message: error.message };
  }
};



const requestCompletion = async (jobProgressId, userId) => {
  try {
    const progress = await jobProgressDB.getProgress(jobProgressId);
    if (!progress || progress.workerId._id.toString() !== userId.toString()) {
      throw new Error('Not authorized');
    }

    const updatedProgress = await jobProgressDB.updateJobProgress([jobProgressId], { status: 'verified' });
    return { success: true, data: updatedProgress };
  } catch (error) {
    console.error('Error requesting completion:', error.message);
    return { success: false, message: error.message };
  }
};

const getCompletionRequests = async (jobId, userId) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job) throw new Error('Job not found');
    if (job.employerId.toString() !== userId) throw new Error('Not authorized');

    const requests = await jobProgressDB.getCompletionRequests(jobId);
    return { success: true, data: requests };
  } catch (error) {
    console.error('Error getting completion requests:', error.message);
    return { success: false, message: error.message };
  }
};

const getMyProgress = async (jobId, workerId) => {
  try {
    const progress = await jobProgressDB.findByJobAndWorker(jobId, workerId);
    if (!progress) return { success: false, message: 'JobProgress not found' };

    const job = await jobDB.getJobById(jobId);
    if (!job) return { success: false, message: 'Job not found' };

    const salary = await calculateSalary(job, progress);

    return {
      success: true,
      data: {
        _id: progress._id,
        jobId: progress.jobId,
        status: progress.status,
        startedAt: progress.startedAt,
        endedAt: progress.endedAt,
        salary,
        workerId: progress.workerId, // ✅ Worker model-д шаардлагатай
      }
    };
  } catch (error) {
    console.error("❌ getMyProgress error:", error.message);
    return { success: false, message: error.message };
  }
};


const confirmCompletion = async (jobId, userId, jobprogressIds) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job) throw new Error('Job not found');
    if (job.employerId.toString() !== userId.toString()) throw new Error('Not authorized');

    const updatedProgress = await jobProgressDB.updateJobProgress(jobprogressIds, {
      status: 'completed',
      endedAt: new Date(),
      isFinal: true,
    });

    await paymentService.createPayments(jobprogressIds, jobId);
    return { success: true, data: updatedProgress };
  } catch (error) {
    console.error('Error confirming completion:', error.message);
    return { success: false, message: error.message };
  }
};

const rejectCompletion = async (jobId, userId, jobprogressIds) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job) throw new Error('Job not found');
    if (job.employerId.toString() !== userId) throw new Error('Not authorized');

    const updatedProgress = await jobProgressDB.updateJobProgress(jobprogressIds, {
      status: 'rejected',
      completedAt: new Date(),
    });

    return { success: true, data: updatedProgress };
  } catch (error) {
    console.error('Error rejecting completion:', error.message);
    return { success: false, message: error.message };
  }
};

const viewProgress = async (jobId, employerId) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job) throw new Error('Job not found');
    if (job.employerId.toString() !== employerId.toString()) throw new Error('Not authorized');

    const progresses = await jobProgressDB.getJobProgressByJobId(jobId);

    const result = await Promise.all(
      progresses.map(async (progress) => {
        const salary = await calculateSalary(job, progress); // 💵
        
        return {
          _id: progress._id,
          jobId: progress.jobId,
          status: progress.status,
          startedAt: progress.startedAt,
          endedAt: progress.endedAt,
          salary,
          workerId: {
            _id: progress.workerId._id,
            firstName: progress.workerId.firstName,
            lastName: progress.workerId.lastName,
            phone: progress.workerId.phone,
            rating: progress.workerId.rating || 4.0,
            projects: progress.workerId.projects || 0,
          },
          createdAt: progress.createdAt
        };
      })
    );

    return { success: true, data: result };
  } catch (error) {
    console.error("❌ Error in viewProgress:", error.message);
    return { success: false, message: error.message };
  }
};



const viewProgressDetails = async (jobId, userId, jobProgressId) => {
  const job = await jobDB.getJobById(jobId);
  const jobprogress = await jobProgressDB.getJobProgressById(jobProgressId);

  if (!job) throw new Error('Job not found');
  if (!jobprogress) throw new Error('Progress not found');
  const isAuthorized = job.employerId.toString() === userId || jobprogress.workerId.toString() === userId;
  if (!isAuthorized) throw new Error('Not authorized');

  const salary = await calculateSalary(job, jobprogress);
  return new jobProgressDTO(job, jobprogress, salary);
};



module.exports = {
  startJob,
  confirmStart,
  requestCompletion,
  confirmCompletion,
  getStartRequests,
  getCompletionRequests,
  rejectCompletion,
  viewProgress,
  viewProgressDetails,
  calculateSalary,
  calculateWorkerSalary,
  getMyProgress
};