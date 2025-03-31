const mongoose = require('mongoose');

const workProgressSchema = new mongoose.Schema({
  _id: mongoose.Schema.Types.ObjectId,
  contractId: { type: mongoose.Schema.Types.ObjectId, ref: 'Contract' },
  status: { type: String, enum: ['not_started', 'in_progress', 'completed', 'verified'] },
  startedAt: Date,
  endedAt: Date,
  calculatedSalary: Number,
  lastUpdatedAt: Date
});

module.exports = mongoose.model('WorkProgress', workProgressSchema);
