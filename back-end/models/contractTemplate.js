const mongoose = require('mongoose');

const contractTemplateSchema = new mongoose.Schema({
  employerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  templateName: { type: String, required: true },
  jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job', required: true },
  title: { type: String, required: true },
  status: { type: String, enum: ['draft', 'signed', 'rejected'], default: 'draft' },

  summary: { type: String },
  contentText: { type: String },     // Mustache placeholders
  contentHTML: { type: String },     // Rendered version (optional)
  contentJSON: [{ title: String, body: String }], // Editable blocks
  employerSigned : {type : Boolean, default : false},
}, {
  timestamps: true
});

module.exports = mongoose.model('ContractTemplate', contractTemplateSchema);
