const ratingService = require('../services/ratingService');

const createRating = async (req, res) => {
  const fromUserId = req.user.id;
  const { toUserId, jobId, branchType, manualRating, systemRating } = req.body;

  const result = await ratingService.createRating({ fromUserId, toUserId, jobId, branchType, manualRating, systemRating });
  res.json(result);
};
const getUserRatings = async (req, res) => {
  const { userId } = req.params;
  const result = await ratingService.getUserRatings(userId);
  res.json(result);
};


module.exports = { createRating, getUserRatings };