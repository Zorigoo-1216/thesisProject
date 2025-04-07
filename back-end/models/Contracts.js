const mongoose = require('mongoose');

const contractSchema = new mongoose.Schema({
  jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job' },
  employerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  workerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  contractType: { type: String, enum: ['standard', 'custom'] },
  status: { type: String, enum: ['pending', 'signed', 'cancelled', 'completed'] },
  isSignedByEmployer: Boolean,
  isSignedByWorker: Boolean,
  contractText: String,
  summary: String,
  createdAt: { type: Date, default: Date.now },
  updatedAt: Date,
  employerSignedAt: Date,
  workerSignedAt: Date
});


module.exports = mongoose.model('Contract', contractSchema);
