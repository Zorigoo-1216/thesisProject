const mongoose = require('mongoose');
const contractTemplate = require('./contractTemplate');

const contractSchema = new mongoose.Schema({
  jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job' },
  employerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  workerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  contractTemplateId: { type: mongoose.Schema.Types.ObjectId, ref: 'ContractTemplate' },
  contractNumber: { type: Number, unique: true }, // автоматаар өсөх тоо
  templateId: { type: String },
  contractType: {
    type: String,
    enum: ['standard', 'custom'],
    required: true
  },
  contractCategory: {
    type: String,
    enum: ['wage-based', 'task-based', 'cooperation', 'employment'],
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'signed', 'cancelled', 'completed', 'rejected'],
    default: 'pending'
  },
  contractText: { type: String, required: true },
  summary: { type: String },

  isSignedByEmployer: { type: Boolean, default: false },
  isSignedByWorker: { type: Boolean, default: false },

  employerSignedAt: { type: Date },
  workerSignedAt: { type: Date },

  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date }
});

// Автомат дугаарлалт — хамгийн сүүлийн contractNumber-оос 1-р өсгөнө
contractSchema.pre('save', async function (next) {
  if (!this.contractNumber) {
    const latest = await mongoose.model('Contract').findOne().sort('-contractNumber');
    this.contractNumber = latest?.contractNumber + 1 || 1;
  }
  next();
});

module.exports = mongoose.model('Contract', contractSchema);
