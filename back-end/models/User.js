const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  avatar: { type: String },
  verificationCode: { type: String },
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  email: { type: String },
  phone: { type: String, unique: true, required: true },
  passwordHash: { type: String, required: true },

  role: { type: String, enum: ['individual', 'company', 'admin'], required: true },
  companyName: { type: String },                 // Зөвхөн role === company үед ашиглана
  companyType: { type: String },                 // Хуулийн этгээдийн төрөл гэх мэт
  gender: { type: String, enum: ['male', 'female', 'other'], required: true },

  isVerified: { type: Boolean, default: false },
  isOnline: { type: Boolean, default: false },
  lastActiveAt: { type: Date, default: Date.now },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date },
  state: { type: String, enum: ['Active', 'Inactive', 'Blocked'], default: 'Active' },

  schedule: [
    {
      jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job' },
      startDate: Date,
      endDate: Date
    }
  ],
  completedJobs: [
    {
      jobId: { type: mongoose.Schema.Types.ObjectId, ref: 'Job' },
      branchType: String,
      completedAt: Date
    }
  ],
  profile: {
    birthDate: Date,
    identityNumber: String,
    location: String,
    mainBranch: String,
    waitingSalaryPerHour: Number,
    driverLicense: [String],
    skills: [String],
    additionalSkills: [String],
    experienceLevel: { type: String, enum: ['beginner', 'intermediate', 'expert'] },
    languageSkills: [String],
    isDisabledPerson: { type: Boolean, default: false }
  },
  averageRating: {
    overall: { type: Number, default: 0 },
    byBranch: [
      {
        branchType: String,
        score: Number,
      }
    ]
  }
});

module.exports = mongoose.model('User', userSchema);
