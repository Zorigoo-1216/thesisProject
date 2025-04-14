const jobProgressService = require('../services/jobProgressService.js');

// ажилтан ажил эхлүүлэх хүсэлт илгээнэ
const startJob = async (req, res) => {
  const { jobId } = req.params;
  const userId = req.user.id;
  const result = await jobProgressService.startJob(jobId, userId);
  res.json(result);
};

// ilgeesen ajil heluuleh huseltuudiig zovhon ajil olgoch harna
const getStartRequests = async (req, res) => {
  const { jobId } = req.params;
  const userId = req.user.id;
  const result = await jobProgressService.getStartRequests(jobId, userId);
  res.json(result);
};

const confirmJobStart = async (req, res) => {
  const { jobId } = req.params;
  const userId = req.user.id;
  const {jobprogressIds} = req.body.jobprogressIds;
  const result = await jobProgressService.confirmStart(jobId, userId, jobprogressIds);
  res.json(result);
};

// ajiltan ajil duussanaa medegdene
const requestCompletion = async (req, res) => {
  const { jobProgressId } = req.params;
  const userId = req.user.id;
  const result = await jobProgressService.requestCompletion(jobProgressId, userId);
  res.json(result);
};
const getCompletionRequests = async (req, res) => {
  const { jobId } = req.params;
  const userId = req.user.id;
  const result = await jobProgressService.getCompletionRequests(jobId, userId);
  res.json(result);
}
const confirmCompletion = async (req, res) => {
  const { jobId } = req.params;
  const userId = req.user.id;
  const {jobprogressIds} = req.body.jobprogressIds;
  const result = await jobProgressService.confirmCompletion(jobId, userId, jobprogressIds);
  res.json(result);
};

const rejectCompletion = async (req, res) => {
  const { jobId } = req.params;
  const userId = req.user.id;
  const {jobprogressIds} = req.body.jobprogressIds;
  const result = await jobProgressService.rejectCompletion(jobId, userId, jobprogressIds);
  res.json(result);
};

const viewProgress = async (req, res) => {
  const { jobId } = req.params;
  const userId = req.user.id;
  //const jobProgressIds = req.body.jobprogressIds;
  const result = await jobProgressService.viewProgress(jobId, userId);
  res.json(result);
};

const viewProgressDetails = async (req, res) =>{
  const { jobId } = req.params;
  const userId = req.user.id;
  const {jobProgressId} = req.body.jobprogressId;
  const result = await jobProgressService.viewProgressDetails(jobId, userId, jobProgressId);
  res.json(result);
}



module.exports = {
  startJob,
  confirmJobStart,
  requestCompletion,
  confirmCompletion,
  rejectCompletion,
  viewProgress,
  getStartRequests,
  getCompletionRequests,
  viewProgressDetails,

};