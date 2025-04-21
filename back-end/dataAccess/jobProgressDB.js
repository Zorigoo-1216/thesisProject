const JobProgress = require('../models/jobProgress');
const Job = require('../models/Job');
const mongoose = require('mongoose');
const createJobProgress = async (data) => {
  return await JobProgress.create(data);
};

const getByJobAndWorker = async (jobId, workerId) => {
  return await JobProgress.findOne({ jobId, workerId });
};

const updateCalculatedSalary = async (id, amount) => {
  return await JobProgress.findByIdAndUpdate(
    id,
    {
      $set: {
        calculatedSalary: amount,
        lastUpdatedAt: new Date(),
      },
    },
    { new: true }
  );
};
const getProgress = async (jobProgressId) => {
  return await JobProgress.findById(jobProgressId).populate('workerId');
}

const getJobProgressByJobId = async (jobId) => {
  return await JobProgress.findOne({ jobId });
};
const getStartRequests = async (jobId) => {
  return await JobProgress.find({ jobId: new mongoose.Types.ObjectId(jobId) }).populate('workerId');
};

const getJobProgressById = async (progressId) =>{
  return await JobProgress.findOne({_id : progressId})
}

const findByJobAndWorker = async (jobId, workerId) => {
  return await JobProgress.findOne({
    jobId: new mongoose.Types.ObjectId(jobId),
    workerId: new mongoose.Types.ObjectId(workerId),
  });
};
const updateJobProgress = async (jobprogressIds, updateData) => {
  //console.log("Updating jobprogressIds:", jobprogressIds);

  const updates = jobprogressIds.map((id) =>
    JobProgress.findOneAndUpdate(
      { _id: new mongoose.Types.ObjectId(id) }, // ✅ `new` хэрэгтэй
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
  getJobProgressById, 
  getByJobAndWorker,
  updateCalculatedSalary, 
  findByJobAndWorker,
  getProgress
};
