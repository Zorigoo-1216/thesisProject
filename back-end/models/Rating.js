const mongoose = require('mongoose');

const ratingSchema = new mongoose.Schema({
  _id: mongoose.Schema.Types.ObjectId,
  fromUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  toUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job' },
  manualRating: {
    score: Number,
    comment: String
  },
  systemRating: {
    attendance: Number,
    onTimePayment: Number,
    jobCompleted: Number
  },
  createdAt: { type: Date, default: Date.now }
});
module.exports = mongoose.model('Rating', ratingSchema);
