const Rating = require('../models/Rating');

const checkExisting = async (fromUserId, toUserId, jobId) => {
  return await Rating.findOne({ fromUserId, toUserId, jobId });
};

const saveRating = async (data) => {
  return await Rating.create(data);
};

const getRatingsByUser = async (userId) => {
  return await Rating.find({ toUserId: userId })
    .populate('fromUserId', 'firstName lastName role companyName') // үнэлгээ өгсөн хүн
    .populate('jobId', 'title'); // холбогдсон ажил
};
module.exports = {
  checkExisting,
  saveRating,
  getRatingsByUser
};
