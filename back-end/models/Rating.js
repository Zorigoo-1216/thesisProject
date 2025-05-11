// 📁 models/rating.model.js
const mongoose = require('mongoose');

const ratingSchema = new mongoose.Schema({
  fromUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  toUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job', required: true },
  branchType: { type: String, required: true },
  criteria: {
    // For employee manual rating
    speed: { type: Number, min: 1, max: 5 },
    performance: { type: Number, min: 1, max: 5 },
    quality: { type: Number, min: 1, max: 5 },
    time_management: { type: Number, min: 1, max: 5 },
    stress_management: { type: Number, min: 1, max: 5 },
    learning_ability: { type: Number, min: 1, max: 5 },
    ethics: { type: Number, min: 1, max: 5 },
    communication: { type: Number, min: 1, max: 5 },

    // For employer rating
    employee_relationship: { type: Number, min: 1, max: 5 },
    salary_fairness: { type: Number, min: 1, max: 5 },
    work_environment: { type: Number, min: 1, max: 5 },
    growth_opportunities: { type: Number, min: 1, max: 5 },
    workload_management: { type: Number, min: 1, max: 5 },
    leadership_style: { type: Number, min: 1, max: 5 },
    decision_making: { type: Number, min: 1, max: 5 },
    legal_compliance: { type: Number, min: 1, max: 5 },

    // System rating fields
    punctuality: { type: Number, min: 0, max: 5 },        // Цаг баримталсан эсэх
    job_completion: { type: Number, min: 0, max: 5 },     // Ажлаа бүрэн хийсэн эсэх
    no_show: { type: Number, min: 0, max: 5 },            // Ирээгүй / орхисон
    absenteeism: { type: Number, min: 0, max: 5 }         // Олон удаа тасалсан
  },
  comment: { type: String, default: '' },
  targetRole: { type: String, enum: ['employee', 'employer'], required: true }
}, {
  timestamps: true
});

module.exports = mongoose.model('Rating', ratingSchema);
