const ratingService = require('../services/ratingService');

const createRating = async (req, res) => {
  try {
    const fromUserId = req.user.id;
    const { toUserId, jobId, branchType, manualRating, systemRating } = req.body;

    const result = await ratingService.createRating({
      fromUserId,
      toUserId,
      jobId,
      branchType,
      manualRating,
      systemRating,
    });

    if (result.success) {
      return res.status(201).json({ success: true, message: 'Rating created successfully', data: result.data });
    }

    return res.status(400).json({ success: false, message: result.message });
  } catch (error) {
    console.error('❌ Error in createRating:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

const getUserRatings = async (req, res) => {
  try {
    const { userId } = req.params;

    const result = await ratingService.getUserRatings(userId);

    if (result.success) {
      return res.status(200).json({ success: true, message: 'User ratings fetched successfully', data: result.data });
    }

    return res.status(400).json({ success: false, message: result.message });
  } catch (error) {
    console.error('❌ Error in getUserRatings:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

const getJobRatingsEmployees = async (req, res) => {
  try{
    const userId = req.user.id;
    const { jobId } = req.params;
    const result = await ratingService.getJobRatingsEmployees(userId, jobId);
    //console.log("result in getJobRatingsEmployees", result);
    if (!result.success) {
      return res.status(400).json({ success: false, message: result.message });
    }
    return res.status(200).json({ success: true, message: 'Job ratings fetched successfully', data: result.data });
  }
  catch (error) {
    console.error('❌ Error in getJobRatingsEmployees:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
}


const getJobRatingByEmployer = async (req, res) => {
  try{
    const userId = req.user.id;
    const { jobId } = req.params;
    const result = await ratingService.getJobRatingByEmployer(userId, jobId);

    if (!result.success) {
      return res.status(400).json({ success: false, message: result.message });
    }
    return res.status(200).json({ success: true, message: 'Job rating fetched successfully', data: result.data });
  }
  catch (error) {
    console.error('❌ Error in getJobRatingByEmployer:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
}


const rateEmployee = async (req, res) => {
    try {
        const userId = req.user.id;
        const jobId = req.params.jobId;
        const { employeeId, criteria, comment } = req.body;
        
    // Шалгах
      if (!criteria || typeof criteria !== 'object') {
        return res.status(400).json({ message: 'Invalid criteria' });
      }

      // Санамсаргүйгээр criteria.score гэж дуудаагүй эсэхийг шалгах
     // console.log("📥 Criteria:", criteria);

        const result = await ratingService.rateEmployee(
          userId,
          employeeId,
          criteria,
          comment,
          jobId
        );
        if (!result.success) {
          return res.status(400).json({ success: false, message: result.message });
        }
        return res.status(201).json({ success: true, message: 'Rating created successfully', data: result.data });
      }
    catch (error) {
      console.error('❌ Error in rateEmployee:', error.message);
      return res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
}

const rateEmployer = async (req, res) => {
  try {
    const userId = req.user.id;
    const jobId = req.params.jobId;
    const { employerId, criteria, comment } = req.body;
    const result = await ratingService.rateEmployer(
      userId,
      employerId,
      criteria,
      comment,
      jobId
    );
    if (!result.success) {
      return res.status(400).json({ success: false, message: result.message });
    }
    return res.status(201).json({ success: true, message: 'Rating created successfully', data: result.data });
    }
    catch (error) {
      console.error('❌ Error in rateEmployer:', error.message);
      return res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
}


// controllers/rating.controller.js
const checkIfEmployerRated = async (req, res) => {
  try {
    const { jobId } = req.params;
    const userId = req.user.id || req.params.userId || req.user._id;
    //console.log("user id in checkIfEmployerRated", userId);
    const existing = await ratingService.checkIfEmployerRated(userId, jobId);

    return res.status(200).json({
      success: true,
      isRated: !!existing,
    });
  } catch (error) {
    console.error('❌ Error checking if rated:', error.message);
    return res.status(500).json({ success: false, message: 'Internal error' });
  }
};

module.exports = { 
  createRating, 
  getUserRatings,
  getJobRatingsEmployees,
  getJobRatingByEmployer,
  rateEmployee,
  rateEmployer,
  checkIfEmployerRated
};