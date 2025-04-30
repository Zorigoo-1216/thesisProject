const jobProgressService = require('../services/jobProgressService.js');

// ажилтан ажил эхлүүлэх хүсэлт илгээнэ
const startJob = async (req, res) => {
  try {
    const { jobId } = req.params;
    const workerId = req.user.id;

    // Service-ээс хариу авах
    const result = await jobProgressService.startJob(jobId, workerId);

    // Амжилттай хариу
    if (result.success) {
      return res.status(200).json(result);
    }

    // Алдааны хариу
    return res.status(400).json({ success: false, message: result.message });
  } catch (error) {
    // Системийн алдааны хариу
    console.error("❌ Error in startJob:", error.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
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
  if (result.success) {
    //console.log("✅ Start requests retrieved successfully:", result.data);
    res.status(200).json(result.data); // 🎯 зөвхөн data-г буцаа
  } else {
    res.status(400).json({ success: false, message: result.message });
  }
};


const confirmJobStart = async (req, res) => {
  try {
    const { jobId } = req.params;
    const userId = req.user.id;
    const { jobprogressIds, startTime } = req.body;

    const result = await jobProgressService.confirmStart(jobId, userId, jobprogressIds, startTime);

    if (result.success) {
      return res.status(200).json(result);
    }

    return res.status(400).json({ success: false, message: result.message });
  } catch (error) {
    console.error("❌ Error confirming job start:", error.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

// ajiltan ajil duussanaa medegdene
const requestCompletion = async (req, res) => {
  try {
    const { jobProgressId } = req.params;
    const userId = req.user.id;

    const result = await jobProgressService.requestCompletion(jobProgressId, userId);

    if (result.success) {
      return res.status(200).json(result);
    }

    return res.status(400).json({ success: false, message: result.message });
  } catch (error) {
    console.error("❌ Error in requestCompletion:", error.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};
const getCompletionRequests = async (req, res) => {
  try {
    const { jobId } = req.params;
    const userId = req.user.id;

    const result = await jobProgressService.getCompletionRequests(jobId, userId);

    if (result.success) {
      return res.status(200).json(result);
    }

    return res.status(400).json({ success: false, message: result.message });
  } catch (error) {
    console.error("❌ Error in getCompletionRequests:", error.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

const confirmCompletion = async (req, res) => {
  try {
    //console.log("Confirming completion..."); // Debug log
    const { jobId } = req.params;
    const userId = req.user.id;
    const { jobprogressIds } = req.body;

    const result = await jobProgressService.confirmCompletion(jobId, userId, jobprogressIds);

    if (result.success) {
      return res.status(200).json(result);
    }

    return res.status(400).json({ success: false, message: result.message });
  } catch (error) {
    console.error("❌ Error in confirmCompletion:", error.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};
const rejectCompletion = async (req, res) => {
  try {
    const { jobId } = req.params;
    const userId = req.user.id;
    const { jobprogressIds } = req.body;

    const result = await jobProgressService.rejectCompletion(jobId, userId, jobprogressIds);

    if (result.success) {
      return res.status(200).json(result);
    }

    return res.status(400).json({ success: false, message: result.message });
  } catch (error) {
    console.error("❌ Error in rejectCompletion:", error.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};


const viewProgress = async (req, res) => {
  try {
    const { jobId } = req.params;
    const userId = req.user.id;

    const result = await jobProgressService.viewProgress(jobId, userId);

    if (result.success) {
      return res.status(200).json(result.data); // 🎯 Зөвхөн `data` талбарыг буцаана
    }

    return res.status(400).json({ success: false, message: result.message });
  } catch (error) {
    console.error("❌ Error in viewProgress:", error.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};


const viewProgressDetails = async (req, res) => {
  try {
    const { jobId } = req.params;
    const userId = req.user.id;
    const { jobProgressId } = req.body;

    const result = await jobProgressService.viewProgressDetails(jobId, userId, jobProgressId);

    if (result.success) {
      return res.status(200).json(result);
    }

    return res.status(400).json({ success: false, message: result.message });
  } catch (error) {
    console.error("❌ Error in viewProgressDetails:", error.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

const getMyProgress = async (req, res) => {
  try {
    const { jobId } = req.params;
    const userId = req.user.id;

    const result = await jobProgressService.getMyProgress(jobId, userId);

    if (result.success) {
      return res.status(200).json(result.data); // зөвхөн data-г буцаана
    }

    return res.status(404).json({ success: false, message: result.message });
  } catch (error) {
    console.error("❌ Error in getMyProgress:", error.message);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
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