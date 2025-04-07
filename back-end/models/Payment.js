const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
  contractId: { type: mongoose.Schema.Types.ObjectId, ref: 'Contract' },
  workerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  employeeId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  status: { type: String, enum: ['paid', 'unpaid'], default: 'unpaid' },
  totalAmount: Number,
  breakdown: {
    baseSalary: Number,
    transportAllowance: Number,
    mealAllowance: Number,
    socialInsurance: Number,
    taxDeduction: Number
  },
  paidAt: Date
});


module.exports = mongoose.model('Payment', paymentSchema);
