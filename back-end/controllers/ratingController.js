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

module.exports = { createRating, getUserRatings };