const mongoose = require('mongoose');

const jobSchema = new mongoose.Schema({
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
  seeker :{type : String, enum: ['individual', 'company']},
  capacity: Number,
  branch: { type: String, enum: ['Cleaning', 'Building', 'Transport'] },
  jobType: { type: String, enum: ['hourly', 'part_time', 'full_time'] },
  level: { type: String, enum: ['none', 'mid', 'high'] },
  possibleForDisabled: Boolean,
  status: { type: String, enum: ['open', 'closed', 'working', 'deleted', 'completed'] },
  startDate: Date,
  endDate: Date,
  createdAt: { type: Date, default: Date.now },
  endedAt: Date,
  updatedAt: Date,
  haveInterview: { type: Boolean, default: false },
  employees: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],      // Сонгогдсон ажилчид
  applications: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Application' }] // Бүх өргөдөл
});

module.exports = mongoose.model('Job', jobSchema);
