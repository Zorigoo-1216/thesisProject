const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
  contractId: { type: mongoose.Schema.Types.ObjectId, ref: 'Contract' },
  jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job', required: true },
  jobProgressId :{type: mongoose.Schema.Types.ObjectId, ref: 'JobProgress', required: true},
  workerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  employerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  status: { type: String, enum: ['paid','paiding', 'unpaid'], default: 'unpaid' },
  totalAmount: { type: Number, default: 0 },
  breakdown: {
    baseSalary: { type: Number, default: 0 },
    transportAllowance: { type: Number, default: 0 },
    mealAllowance: { type: Number, default: 0 },
    socialInsurance: { type: Number, default: 0 },
    taxDeduction: { type: Number, default: 0 }
  },
  jobstartedAt: {type: Date},
  jobendedAt: {type: Date},
  paidAt: Date
}, {
  timestamps: true
});

module.exports = mongoose.model('Payment', paymentSchema);
