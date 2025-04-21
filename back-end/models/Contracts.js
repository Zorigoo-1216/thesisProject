const mongoose = require('mongoose');

const contractSchema = new mongoose.Schema({
  jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job', required: true },
  employerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  workerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  contractTemplateId: { type: mongoose.Schema.Types.ObjectId, ref: 'ContractTemplate', required: true },

  contractNumber: { type: Number, unique: true }, // Автомат өсөх дугаар

  contractType: {
    type: String,
    enum: ['standard', 'custom'],
    required: true,
  },
  contractCategory: {
    type: String,
    enum: ['wage_contract', 'task_contract', 'cooperation', 'employment'],
    required: true,
  },

  status: {
    type: String,
    enum: ['pending', 'signed', 'cancelled', 'completed', 'rejected'],
    default: 'pending',
  },

  contentText: { type: String, required: true },       // Mustache эх загвар
  contentHTML: { type: String, required: true },       // Rendered version
  contentJSON: [{ title: String, body: String }],      // Хэсэгчилсэн JSON
  summary: { type: String },                           // Хураангуй

  isSignedByEmployer: { type: Boolean, default: false },
  isSignedByWorker: { type: Boolean, default: false },
  employerSignedAt: { type: Date },
  workerSignedAt: { type: Date },

  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date },
});

// Автомат дугаарлалт
contractSchema.pre('save', async function (next) {
  if (!this.contractNumber) {
    const latest = await mongoose.model('Contract').findOne().sort('-contractNumber');
    this.contractNumber = latest?.contractNumber + 1 || 1;
  }
  next();
});

module.exports = mongoose.model('Contract', contractSchema);
