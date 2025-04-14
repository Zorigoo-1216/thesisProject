const mongoose = require('mongoose');

const jobProgressSchema = new mongoose.Schema({
  contractId: { type: mongoose.Schema.Types.ObjectId, ref: 'Contract' },
  jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job', required: true },
  employerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  workerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  status: {
    type: String,
    enum: ['not_started', 'in_progress', 'completed', 'verified', 'pendingStart'],
    default: 'not_started'
  },
  startedAt: Date,
  endedAt: Date,
  calculatedSalary: { type: Number, default: 0 },
  lastUpdatedAt: { type: Date, default: Date.now }
}, {
  timestamps: true
});

module.exports = mongoose.model('JobProgress', jobProgressSchema);
