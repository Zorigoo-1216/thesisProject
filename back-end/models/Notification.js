const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  title: String,
  message: String,
  isRead: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
  type: {
    type: String,
    enum: ['job_match', 'contract_update', 'payment', 'rating', 'system_alert', 'interview_schedule', "application_received", "cancelApplication", "generic", "job_alert"]
  },
  tags: [String], // жишээ: ['urgent', 'new_branch', 'disabled_friendly']
  isDeleted: { type: Boolean, default: false }
});

module.exports = mongoose.model('Notification', notificationSchema);
