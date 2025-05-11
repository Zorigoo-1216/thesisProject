// 📁 models/user.model.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  avatar: { type: String, default: '' },
  verificationCode: { type: String, default: '' },
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  email: { type: String, default: '' },
  phone: { type: String, unique: true, required: true },
  passwordHash: { type: String, required: true },

  role: { type: String, enum: ['individual', 'company', 'admin'], required: true },
  companyName: { type: String, default: '' },
  companyType: { type: String, default: '' },
  gender: { type: String, enum: ['male', 'female', 'other'], required: true },

  isVerified: { type: Boolean, default: false },
  isOnline: { type: Boolean, default: false },
  lastActiveAt: { type: Date, default: null },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: null },
  state: { type: String, enum: ['Active', 'Inactive', 'Blocked'], default: 'Active' },

  schedule: {
    type: [
      {
        jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job' },
        startDate: Date,
        endDate: Date
      }
    ],
    default: []
  },
  completedJobs: {
    type: [
      {
        jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job' },
        branchType: String,
        completedAt: Date
      }
    ],
    default: []
  },

  profile: {
    birthDate: { type: Date, default: null },
    identityNumber: { type: String, default: '' },
    location: { type: String, default: '' },
    mainBranch: { type: String, default: '' },
    waitingSalaryPerHour: { type: Number, default: 0 },
    driverLicense: { type: [String], default: [] },
    skills: { type: [String], default: [] },
    additionalSkills: { type: [String], default: [] },
    experienceLevel: {
      type: String,
      enum: ['beginner', 'intermediate', 'expert'],
      default: 'beginner'
    },
    languageSkills: { type: [String], default: [] },
    isDisabledPerson: { type: Boolean, default: false }
  },

  reviews: {
    type: [
      {
        reviewerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        reviewerRole: { type: String, enum: ['individual', 'company'] },
        criteria: {
          speed: { type: Number, default: 0 },
          performance: { type: Number, default: 0 },
          quality: { type: Number, default: 0 },
          time_management: { type: Number, default: 0 },
          stress_management: { type: Number, default: 0 },
          learning_ability: { type: Number, default: 0 },
          ethics: { type: Number, default: 0 },
          communication: { type: Number, default: 0 },
          punctuality: { type: Number, default: 0 },
          job_completion: { type: Number, default: 0 },
          no_show: { type: Number, default: 0 },
          absenteeism: { type: Number, default: 0 }
        },
        comment: { type: String, default: '' },
        createdAt: { type: Date, default: Date.now }
      }
    ],
    default: []
  },

  ratingCriteriaForEmployer: {
    type: [
      {
        reviewerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        criteria: {
          employee_relationship: { type: Number, default: 0 },
          salary_fairness: { type: Number, default: 0 },
          work_environment: { type: Number, default: 0 },
          growth_opportunities: { type: Number, default: 0 },
          workload_management: { type: Number, default: 0 },
          leadership_style: { type: Number, default: 0 },
          decision_making: { type: Number, default: 0 },
          legal_compliance: { type: Number, default: 0 }
        },
        comment: { type: String, default: '' },
        createdAt: { type: Date, default: Date.now }
      }
    ],
    default: []
  },

  averageRating: {
    overall: { type: Number, default: 0 },
    byBranch: {
      type: [
        {
          branchType: { type: String, default: '' },
          score: { type: Number, default: 0 }
        }
      ],
      default: []
    },
    criteria: {
      speed: { type: Number, default: 0 },
      performance: { type: Number, default: 0 },
      quality: { type: Number, default: 0 },
      time_management: { type: Number, default: 0 },
      stress_management: { type: Number, default: 0 },
      learning_ability: { type: Number, default: 0 },
      ethics: { type: Number, default: 0 },
      communication: { type: Number, default: 0 },
      punctuality: { type: Number, default: 0 },
      job_completion: { type: Number, default: 0 },
      no_show: { type: Number, default: 0 },
      absenteeism: { type: Number, default: 0 }
    }
  },

  averageRatingForEmployer: {
    overall: { type: Number, default: 0 },
    totalRatings: { type: Number, default: 0 },
    criteria: {
      employee_relationship: { type: Number, default: 0 },
      salary_fairness: { type: Number, default: 0 },
      work_environment: { type: Number, default: 0 },
      growth_opportunities: { type: Number, default: 0 },
      workload_management: { type: Number, default: 0 },
      leadership_style: { type: Number, default: 0 },
      decision_making: { type: Number, default: 0 },
      legal_compliance: { type: Number, default: 0 }
    }
  }
});

module.exports = mongoose.model('User', userSchema);
