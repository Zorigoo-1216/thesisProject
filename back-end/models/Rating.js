const mongoose = require('mongoose');

const ratingSchema = new mongoose.Schema({
  fromUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  toUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job', required: true },
  branchType: { type: String, required: true },
  manualRating: {
    score: { type: Number, min: 1, max: 5, required: true },
    comment: { type: String, default: '' }
  },
  systemRating: [
    {
      metric: { type: String, required: true },
      score: { type: Number, min: 1, max: 5, required: true }
    }
  ]
}, {
  timestamps: true
});

module.exports = mongoose.model('Rating', ratingSchema);
