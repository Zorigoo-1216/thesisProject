const ratingDB = require('../dataAccess/ratingDB');
const userDB = require('../dataAccess/userDB');

const createRating = async (data) => {
  const { fromUserId, toUserId, jobId, branchType, manualRating, systemRating } = data;

  // Duplicate шалгах
  const existing = await ratingDB.checkExisting(fromUserId, toUserId, jobId);
  if (existing) throw new Error('Rating already exists');

  // Save Rating
  const rating = await ratingDB.saveRating(data);

  // Recalculate average rating
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
    manualRating: r.manualRating,
    systemRating: r.systemRating,
    createdAt: r.createdAt
  }));
};

module.exports = { createRating, getUserRatings };
