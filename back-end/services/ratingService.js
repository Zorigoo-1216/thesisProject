const ratingDB = require('../dataAccess/ratingDB');
const userDB = require('../dataAccess/userDB');
const jobDB = require('../dataAccess/jobDB');
const paymentDB = require('../dataAccess/paymentDB');
const Payment = require('../models/Payment');
const Rating = require('../models/Rating');
const Job = require('../models/Job');
const JobProgress = require('../models/jobProgress');
const createRating = async (data) => {
  const { fromUserId, toUserId, jobId } = data;

  // Duplicate шалгах
  const existing = await ratingDB.checkExisting(fromUserId, toUserId, jobId);
  if (existing) throw new Error('Rating already exists');

  // Save Rating
  const rating = await ratingDB.saveRating(data);

  // Recalculate average
  await userDB.updateAverageRating(toUserId);

  return rating;
};

const getUserRatings = async (userId) => {
  const ratings = await ratingDB.getRatingsByUser(userId);

  return ratings.map(r => ({
    fromUser: {
      id: r.fromUserId._id,
      name: `${r.fromUserId.firstName} ${r.fromUserId.lastName}`,
      role: r.fromUserId.role,
      companyName: r.fromUserId.companyName || null
    },
    job: {
      id: r.jobId._id,
      title: r.jobId.title,
      branchType: r.branchType
    },
    criteria: r.criteria,
    comment: r.comment,
    targetRole: r.targetRole,
    totalScore: r.totalScore ?? null,
    createdAt: r.createdAt
  }));
};


const getJobRatingsEmployees = async (userId, jobId) => {
  const job = await jobDB.getJobById(jobId);
  if (!job) return { success: false, message: "Job not found" };

  if (job.employerId.toString() !== userId.toString()) {
    return { success: false, message: "Not authorized" };
  }

  const payments = await paymentDB.getByJobByStatus(jobId, 'paid');
  if (!payments) return { success: false, message: "Failed to retrieve payments" };

  const workerIds = payments
    .map(p => p.workerId?._id || p.workerId)
    .filter(id => !!id);

  if (workerIds.length === 0) {
    return { success: true, data: [] };
  }

  const workers = await userDB.getUsersByIds(workerIds);

  const workerWithName = workers.map(w => ({
    id: w._id,
    name: `${w.lastName ?? ''} ${w.firstName ?? ''}`.trim(),
    phone: w.phone ?? '',
    role: w.role ?? ''
  }));

  return { success: true, data: workerWithName };
};

const getJobRatingByEmployer = async (userId, jobId) => {
  const job = await jobDB.getJobById(jobId);
  if (!job) return { success: false, message: "Job not found" };

  if (!job.employees.some(id => id.toString() === userId.toString())) {
    return { success: false, message: "Not authorized" };
  }

  const employer = await userDB.getUserById(job.employerId);
  if (!employer) return { success: false, message: "Employer not found" };

  const employerWithName = {
    id: employer._id,
    name: `${employer.lastName ?? ''} ${employer.firstName ?? ''}`.trim(),
    phone: employer.phone ?? '',
    role: employer.role ?? '',
    averageRating: employer.averageRatingForEmployer?.overall ?? 0,
  };

  return { success: true, data: employerWithName };
};


const rateEmployee = async (userId, employeeId, criteria, comment, jobId) => {
  const job = await jobDB.getJobById(jobId);
  const jobProgress = await JobProgress.findOne({ jobId, workerId: employeeId });

  // System rating: punctuality
  let punctualityScore = 0;
  if (jobProgress?.startedAt && job.workStartTime) {
    const scheduledTime = new Date(job.startDate);
    const [hours, minutes] = job.workStartTime.split(':');
    scheduledTime.setHours(Number(hours), Number(minutes));

    const actualStart = new Date(jobProgress.startedAt);
    const diffMinutes = Math.floor((actualStart - scheduledTime) / (60 * 1000));

    if (diffMinutes <= 0) punctualityScore = 5;
    else if (diffMinutes <= 15) punctualityScore = 4;
    else if (diffMinutes <= 30) punctualityScore = 3;
    else if (diffMinutes <= 45) punctualityScore = 2;
    else if (diffMinutes <= 60) punctualityScore = 1;
  }

  // System rating: completion
  let completionScore =
    jobProgress?.status === 'completed' || jobProgress?.status === 'verified'
      ? 5
      : 0;

  // Convert manual criteria average to 10 scale
  const manualScores = Object.values(criteria);
  const manualAvg = manualScores.reduce((sum, s) => sum + s, 0) / manualScores.length;
  const manualConverted = (manualAvg / 5) * 10;

  // Final calculation
  const total20 = manualConverted + punctualityScore + completionScore;
  const finalScore = +(total20 / 4).toFixed(1); // back to 5 scale

  const ratingData = {
    fromUserId: userId,
    toUserId: employeeId,
    jobId,
    branchType: job.branch || '',
    criteria: {
      ...criteria,
      punctuality: punctualityScore,
      job_completion: completionScore,
    },
    comment,
    targetRole: 'employee',
    totalScore: finalScore,
  };

  const created = await ratingDB.createRating(ratingData);
  if (!created) return { success: false, message: 'Already rated' };

  await userDB.updateEmployeeAverageRating(employeeId);

  const allRated = await checkIfAllEmployersRated(jobId);
  if (allRated) {
    await jobDB.updateJobStatus(jobId, 'completed');
  }

  return { success: true, message: 'Employee rated', data: ratingData };
};


const rateEmployer = async (userId, employerId, criteria, comment, jobId) => {
  const job = await jobDB.getJobById(jobId);

  const ratingData = {
    fromUserId: userId,
    toUserId: employerId,
    jobId,
    branchType: job.branch || '',
    criteria,
    comment,
    targetRole: 'employer',
    totalScore: Object.values(criteria).length
      ? +(Object.values(criteria).reduce((a, b) => a + b, 0) / Object.values(criteria).length).toFixed(1)
      : 0,
  };

  const created = await ratingDB.createRating(ratingData);
  if (!created) return { success: false, message: 'Already rated' };

  await userDB.updateEmployerAverageRating(employerId);

  const allRated = await checkIfAllEmployersRated(jobId);
  if (allRated) {
    await jobDB.updateJobStatus(jobId, 'completed');
    await autoRateUnratedEmployees(jobId);
  }

  return { success: true, message: 'Employer rated', data: ratingData };
};


const checkIfAllEmployersRated = async (jobId) => {
  // 1. job-д хамаарах 'paid' төлөвтэй payments-ийг авна
  const payments = await Payment.find({ jobId, status: 'paid' });

  if (!payments.length) return false;

  // 2. Ажилтнуудын ID-уудыг цуглуулна
  

  const employerIdRaw = payments[0]?.employerId;
  if (!employerIdRaw) {
    console.error('❌ checkIfAllEmployersRated: employerId is undefined in payments[0]');
    console.error('📦 payment object:', payments[0]);
    return false;
  }
  const employerId = employerIdRaw.toString();
  const workerIds = payments
  .map(p => p.workerId)
  .filter(Boolean) // undefined-үүдийг хасна
  .map(id => id.toString());
  // 3. Ажилтан бүр ажил олгогчийг үнэлсэн эсэхийг шалгана
  for (const workerId of workerIds) {
    const rating = await Rating.findOne({
      fromUserId: workerId,
      toUserId: employerId,
      jobId
    });
    if (!rating) return false;

    const reverseRating = await Rating.findOne({
      fromUserId: employerId,
      toUserId: workerId,
      jobId
    });
    if (!reverseRating) return false;
  }

  return true; // бүгд үнэлсэн
};

const autoRateUnratedEmployees = async (jobId) => {
  const job = await jobDB.getJobById(jobId);
  const jobProgresses = await JobProgress.find({ jobId });
  const ratedUserIds = (await Rating.find({ jobId }))
    .map(r => r.toUserId.toString());

  const unratedWorkers = job.employees.filter(id => !ratedUserIds.includes(id.toString()));

  for (const workerId of unratedWorkers) {
    const jp = jobProgresses.find(jp => jp.workerId.toString() === workerId.toString());
    const punctuality = 0;
    const completion = jp?.status === 'completed' || jp?.status === 'verified' ? 5 : 0;
    const totalScore = +(completion / 4).toFixed(1); // зөвхөн 1 metric ашиглаж байгаа тул 5-аас буулгана

    const ratingData = {
      fromUserId: job.employerId,
      toUserId: workerId,
      jobId,
      branchType: job.branch || '',
      manualRating: { score: 0, comment: '' },
      systemRating: [
        { metric: 'punctuality', score: punctuality },
        { metric: 'completion', score: completion }
      ],
      totalScore
    };

    await ratingDB.createRating(ratingData);
    await userDB.updateEmployeeAverageRating(workerId);
  }
};


module.exports = { 
  createRating, 
  getUserRatings,
  getJobRatingsEmployees,
  getJobRatingByEmployer,
  rateEmployee,
  rateEmployer
};
