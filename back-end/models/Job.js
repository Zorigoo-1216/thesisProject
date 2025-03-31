const mongoose = require('mongoose');

const jobSchema = new mongoose.Schema({
  job_id: mongoose.Schema.Types.ObjectId,
  employerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  title: String,
  description: [String],
  requirements: [String],
  location: String,
  salary: {
    amount: Number,
    currency: { type: String, default: 'MNT' },
    type: { type: String, enum: ['daily', 'hourly'] }
  },
  benefits: {
    transportIncluded: Boolean,
    mealIncluded: Boolean,
    bonusIncluded: Boolean
  },
  jobType: { type: String, enum: ['hourly', 'part_time', 'full_time'] },
  branchType: String,
  level: { type: String, enum: ['none', 'mid', 'high'] },
  possibleForDisabled: Boolean,
  status: { type: String, enum: ['open', 'closed'] },
  startDate: Date,
  endDate: Date,
  createdAt: { type: Date, default: Date.now },
  updatedAt: Date
});

module.exports = mongoose.model('Job', jobSchema);
