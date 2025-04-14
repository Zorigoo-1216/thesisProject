const JobProgress = require('../models/jobProgress');
const Job = require('../models/Job');
const createJobProgress = async (data) => {
  return await JobProgress.create(data);
};
const getJobProgressByJobId = async (jobId) => {
  return await JobProgress.findOne({ jobId });
};
const getStartRequests = async (jobId) => {
  return await JobProgress.find({ jobId: jobId, status: 'pendingStart' });
};
const getJobProgressById = async (progressId) =>{
  return await JobProgress.findOne({_id : progressId})
}
const updateJobProgress = async (jobprogressIds, updateData) => {
  const updates = jobprogressIds.map((jobprogressId) =>
    JobProgress.findOneAndUpdate(
      { jobprogressId: jobprogressId},
      { $set: updateData },
      { new: true }
    )
  );
  return await Promise.all(updates);
};

const getCompletionRequests = async (jobId) => {
  return await JobProgress.find({ jobId: jobId, status: 'verified' });
}
module.exports = {
  createJobProgress,
  getJobProgressByJobId,
  updateJobProgress,
  getStartRequests,
  getCompletionRequests,
  getJobProgressById
};
