const mongoose = require('mongoose');

const jobSchema = new mongoose.Schema(
  {
    employerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },

    // General Information
    title: { type: String, required: true },
    description: { type: String, required: true }, // Single string for job description
    requirements: { type: [String], default: [] },
    location: { type: String, required: true },

    // Salary Information
    salary: {
      amount: { type: Number, required: true },
      currency: { type: String, default: 'MNT' },
      type: { type: String, enum: ['daily', 'hourly','performance'], required: true, default: 'hourly' },
    },

    // Additional Benefits
    benefits: {
      transportIncluded: { type: Boolean, default: false },
      mealIncluded: { type: Boolean, default: false },
      bonusIncluded: { type: Boolean, default: false },
      // Renamed for clarity
      includeDefaultBenefits: { type: Boolean, default: false }, 
    },

    seeker: { type: String, enum: ['individual', 'company'], required: true, default: 'individual' },
    capacity: { type: Number, required: true },
    branch: { type: String, required: true },
    jobType: { type: String, enum: ['hourly', 'part_time', 'full_time', ], required: true },
    level: { type: String, enum: ['none', 'mid', 'high'], default: 'none' },
    possibleForDisabled: { type: Boolean, default: false },

    // Job Status & Dates
    status: {
      type: String,
      enum: ['open', 'closed', 'working', 'deleted', 'completed'],
      default: 'open',
    },
    startDate: { type: Date, required: true },
    endDate: { type: Date, required: true },

    // Workday Time Schedules (consider using Date instead of String if working with actual times)
    workStartTime: { type: String, required: true },   // Example: "08:00"
    workEndTime: { type: String, required: true },     // Example: "17:00"
    breakStartTime: { type: String },
    breakEndTime: { type: String },

    // Other Information
    hasInterview: { type: Boolean, default: false },

    // Employees and Applications References
    employees: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    applications: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Application' }],
    additionalInfo: { type: [String], default: [] },

    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date },
    endedAt: { type: Date },
  },
  { timestamps: true } // Automatically adds createdAt and updatedAt
);

module.exports = mongoose.model('Job', jobSchema);
