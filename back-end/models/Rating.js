const mongoose = require('mongoose');

const ratingSchema = new mongoose.Schema({
  fromUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  toUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job' },
  branchType: { type: String },
  manualRating: {
    score: Number,
    comment: String
  },
  systemRating: [
    {
      metric : String,
      score: Number,
    },
  ],
  createdAt: { type: Date, default: Date.now }
});
module.exports = mongoose.model('Rating', ratingSchema);
