const jobProgressService = require('../services/jobProgressService.js');

// ажилтан ажил эхлүүлэх хүсэлт илгээнэ
const startJob = async (req, res) => {
  const { jobId } = req.params;
  const workerId = req.user.id;
  const result = await jobProgressService.startJob(jobId, workerId);
  res.json(result);
};


const getWorkerSalary = async (req, res) => {
  try {
    const { jobId } = req.params;
    const workerId = req.user.id;

    const result = await jobProgressService.calculateWorkerSalary(jobId, workerId);
    res.json(result);
  } catch (err) {
    console.error("❌ Error in getWorkerSalary:", err.message);
    res.status(500).json({ error: err.message });
  }
};



// ilgeesen ajil heluuleh huseltuudiig zovhon ajil olgoch harna
const getStartRequests = async (req, res) => {
  const { jobId } = req.params;
  const userId = req.user.id;
  
  const result = await jobProgressService.getStartRequests(jobId, userId);
  console.log("getStartRequests result:", result);
  res.json(result);
};


const confirmJobStart = async (req, res) => {
  try {
    const { jobId } = req.params;
    const userId = req.user.id;
    const jobprogressIds = req.body.jobprogressIds;
    const startTime = req.body.startTime;

    

    const result = await jobProgressService.confirmStart(jobId, userId, jobprogressIds, startTime);
    console.log("confirmJobStart result:", result);
    res.json(result);
  } catch (error) {
    console.error('❌ Error confirming job start:', error.message);
    res.status(500).json({ error: error.message });
  }
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
  console.log("confirmCompletion called");
  const { jobId } = req.params;
  const userId = req.user.id;
  const { jobprogressIds } = req.body;
  console.log("jobprogressIds:", jobprogressIds);
  console.log("confirmCompletion jobId:", jobId);
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
const getMyProgress = async (req, res) => {
  try {
    const { jobId } = req.params;
    const userId = req.user.id;

    const result = await jobProgressService.getMyProgress(jobId, userId);
    res.json(result);
  } catch (err) {
    console.error('❌ Error in getMyProgress:', err.message);
    res.status(500).json({ error: err.message });
  }
};


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
  getWorkerSalary,
  getMyProgress, 
};