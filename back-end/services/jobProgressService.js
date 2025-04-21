// services/jobProgressService.js

const jobDB = require('../dataAccess/jobDB');
const jobProgressDB = require('../dataAccess/jobProgressDB');
const notificationService = require('./notificationService');
const jobProgressDTO = require('../viewModels/viewJobProgressDTO');
const paymentDB = require('../dataAccess/paymentDB');
const paymentService = require('../services/paymentService');
const contractDB = require('../dataAccess/contractDB');

const startJob = async (jobId, userId) => {
  const job = await jobDB.getJobById(jobId);
  if (!job) throw new Error('Job not found');

  const isAuthorized = job.employees.some(emp => emp.toString() === userId.toString());

  if (!isAuthorized) throw new Error('Not authorized');

  // 🆕 Гэрээг шүүж олоно
  const contract = await contractDB.findByJobAndWorker(jobId, userId);
  if (!contract) throw new Error('Contract not found');

  const progress = await jobProgressDB.createJobProgress({
    jobId,
    workerId: userId,
    employerId: job.employerId,
    contractId: contract._id,
    status: 'pendingStart'
  });

  return progress;
};


const calculateWorkerSalary = async (jobId, workerId) => {
  const job = await jobDB.getJobById(jobId);
  if (!job) throw new Error('Job not found');

  const progress = await jobProgressDB.getByJobAndWorker(jobId, workerId);
  if (!progress) throw new Error('Job progress not found');

  const salaryResult = await calculateSalary(job, progress);

  // calculatedSalary хадгалах (optional)
  await jobProgressDB.updateCalculatedSalary(progress._id, salaryResult.total);

  return salaryResult;
};


const getStartRequests = async (jobId, employerId) => {
  const job = await jobDB.getJobById(jobId);
  console.log("job.employer:", job.employerId.toString());
console.log("employerId:", employerId);

  if (!job || job.employerId.toString() !== employerId.toString()) {
    throw new Error('Not authorized');
  }
  return await jobProgressDB.getStartRequests(jobId);
};


const confirmStart = async (jobId, userId, jobprogressIds, startTime) => {
  const job = await jobDB.getJobById(jobId);
  if (!job) throw new Error('Job not found');
  console.log("job.employerId:", job.employerId.toString());
  console.log("userId:", userId);
  if (job.employerId.toString() !== userId.toString()) throw new Error('Not authorized');

  const updateData = {
    status: 'in_progress', // 👈 in_progress
    startedAt: startTime ? new Date(startTime) : new Date(),
    lastUpdatedAt: new Date(),
  };
  console.log("Updating jobprogressIds:", jobprogressIds);
  return await jobProgressDB.updateJobProgress(jobprogressIds, updateData);
};


const requestCompletion = async (jobProgressId, userId) => {
  const progress = await jobProgressDB.getProgress(jobProgressId);
  if (!progress || progress.workerId._id.toString() !== userId.toString()) throw new Error('Not authorized');

  return await jobProgressDB.updateJobProgress([jobProgressId], { status: 'verified' });
};

const getCompletionRequests = async (jobId, userId) => {
  const job = await jobDB.getJobById(jobId);
  if (!job) throw new Error('Job not found');
  if (job.employerId.toString() !== userId) throw new Error('Not authorized');
  return await jobProgressDB.getCompletionRequests(jobId);
}

const getMyProgress = async (jobId, workerId) => {
  const progress = await jobProgressDB.findByJobAndWorker(jobId, workerId);
  if (!progress) throw new Error('JobProgress not found');

  const job = await jobDB.getJobById(jobId);
  if (!job) throw new Error('Job not found');

  const salary = await calculateSalary(job, progress);

  return {
    _id: progress._id,
    jobId: progress.jobId,
    status: progress.status,
    startedAt: progress.startedAt,
    endedAt: progress.endedAt,
    salary,
  };
};


const confirmCompletion = async (jobId, userId, jobprogressIds) => {
  const job = await jobDB.getJobById(jobId);
  if (!job) throw new Error('Job not found');
  if (job.employerId.toString() !== userId) throw new Error('Not authorized');

  const jobProgress = await jobProgressDB.updateJobProgress(jobprogressIds, {
    status: 'completed',
    endedAt: new Date(),
    isFinal: true
  });

  await paymentService.createPayments(jobprogressIds, jobId, userId );
  return jobProgress;
};

const rejectCompletion = async  (jobId, userId, jobprogressIds) => {
  const job = await jobDB.getJobById(jobId);
  if (!job) throw new Error('Job not found');
  if (job.employerId.toString() !== userId) throw new Error('Not authorized');
  return await jobProgressDB.updateJobProgress(jobprogressIds, {
    status: 'rejected',
    completedAt: new Date(),
  });
}

const viewProgress = async (jobId, userId) => {
  const job = await jobDB.getJobById(jobId);
  if (!job) throw new Error('Job not found');
  if (job.employerId.toString() !== userId) throw new Error('Not authorized');

  const progresses = await jobProgressDB.getJobProgressByJobId(jobId);

  const result = await Promise.all(
    progresses.map(async (progress) => {
      const salary = await calculateSalary(job, progress);
      return new jobProgressDTO(job, progress, salary);
    })
  );

  return result;
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

const calculateSalary = async (job, progress) => {
  const start = new Date(progress.startedAt);
  const end = new Date(progress.endedAt || new Date()); // одоо цаг хүртэлхийг авч болно

  let workedHours = (end - start) / (1000 * 60 * 60); // цаг руу хөрвүүлнэ

  // Цайны цагийг хасах
  const breakStart = parseFloat(job.breakStartTime?.split(':')[0] || 0);
  const breakEnd = parseFloat(job.breakEndTime?.split(':')[0] || 0);
  const breakHours = breakEnd - breakStart;
  if (workedHours > breakEnd) {
    workedHours -= breakHours;
  }

  // Цалин бодолт
  if (job.salary.type === 'hourly') {
    const baseSalary = workedHours * job.salary.amount;

    if (progress.status === 'completed' || progress.status === 'verified') {
      const transportAllowance = job.benefits.transportIncluded ? 5000 : 0;
      const mealAllowance = job.benefits.mealIncluded ? 4000 : 0;
      const gross = baseSalary + transportAllowance + mealAllowance;
      const tax = gross * 0.1;
      const insurance = gross * 0.05;
      const total = gross - tax - insurance;

      return {
        total: Math.round(total),
        breakdown: {
          baseSalary: Math.round(baseSalary),
          transportAllowance,
          mealAllowance,
          socialInsurance: Math.round(insurance),
          taxDeduction: Math.round(tax)
        }
      };
    } else {
      return {
        total: Math.round(baseSalary),
        breakdown: {
          baseSalary: Math.round(baseSalary),
          transportAllowance: 0,
          mealAllowance: 0,
          socialInsurance: 0,
          taxDeduction: 0
        },
        message: 'Ажил үргэлжилж байна. Бусад зардлуудыг дууссаны дараа тооцно.'
      };
    }
  }

  // Хэрвээ 'daily' эсвэл 'task-based' төрлийн ажил
  if (progress.status !== 'completed' && progress.status !== 'verified') {
    return {
      total: 0,
      breakdown: {
        baseSalary: 0,
        transportAllowance: 0,
        mealAllowance: 0,
        socialInsurance: 0,
        taxDeduction: 0
      },
      message: 'Ажил бүрэн дуусаагүй байна.'
    };
  }

  const base = job.salary.amount;
  const transportAllowance = job.benefits.transportIncluded ? 5000 : 0;
  const mealAllowance = job.benefits.mealIncluded ? 4000 : 0;

  const gross = base + transportAllowance + mealAllowance;
  const tax = gross * 0.1;
  const insurance = gross * 0.05;
  const total = gross - tax - insurance;

  return {
    total: Math.round(total),
    breakdown: {
      baseSalary: Math.round(base),
      transportAllowance,
      mealAllowance,
      socialInsurance: Math.round(insurance),
      taxDeduction: Math.round(tax)
    }
  };
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