const mongoose = require('mongoose');
const User = require('../models/User'); // Загварын замаа тохируулна уу
const userDB = require('../dataAccess/userDB');
const fillMissingFields = async (userId) => {
  try {
    const user = await userDB.getUserByPhone(phone);
    if (!user) return console.error("User not found");

    const update = {};

    // ✅ Root level fields
    if (!user.avatar) update.avatar = 'https://example.com/avatar.png';
    if (!user.verificationCode) update.verificationCode = '123456';
    if (!user.email) update.email = `${user.firstName.toLowerCase()}@example.com`;
    if (!user.companyName) update.companyName = '';
    if (!user.companyType) update.companyType = '';
    if (!user.updatedAt) update.updatedAt = new Date();

    if (!Array.isArray(user.schedule)) update.schedule = [];
    if (!Array.isArray(user.completedJobs)) update.completedJobs = [];

    // ✅ Profile
    const defaultProfile = {
      birthDate: new Date('2000-01-01'),
      identityNumber: 'АБ12345678',
      location: 'Улаанбаатар',
      mainBranch: 'Барилга',
      waitingSalaryPerHour: 12000,
      driverLicense: ['B'],
      skills: ['Хүнд даацын машин барих'],
      additionalSkills: ['Гагнуур'],
      experienceLevel: 'intermediate',
      languageSkills: ['Англи', 'Орос'],
      isDisabledPerson: false,
    };

    if (!user.profile) {
      update.profile = defaultProfile;
    } else {
      update.profile = {
        ...defaultProfile,
        ...user.profile.toObject(),
      };
    }

    // ✅ averageRating
    const defaultRating = {
      overall: 3.5,
      byBranch: [{ branchType: 'Барилга', score: 4 }],
    };
    update.averageRating = {
      ...defaultRating,
      ...user.averageRating,
    };

    // ✅ averageRatingForEmployer
    const defaultEmployerRating = {
      overall: 4,
      totalRatings: 1,
    };
    update.averageRatingForEmployer = {
      ...defaultEmployerRating,
      ...user.averageRatingForEmployer,
    };

    // ✅ reviews
    if (!Array.isArray(user.reviews)) {
      update.reviews = [
        {
          reviewerId: user._id,
          reviewerRole: 'company',
          criteria: {
            speed: 4,
            performance: 4,
            quality: 4,
            time_management: 3,
            stress_management: 4,
            learning_ability: 4,
            ethics: 5,
            communication: 4,
          },
          comment: 'Сайн ажилласан',
          createdAt: new Date(),
        },
      ];
    }

    // ✅ ratingCriteriaForEmployer
    if (!Array.isArray(user.ratingCriteriaForEmployer)) {
      update.ratingCriteriaForEmployer = [
        {
          reviewerId: user._id,
          criteria: {
            employee_relationship: 4,
            salary_fairness: 5,
            work_environment: 4,
            growth_opportunities: 3,
            workload_management: 4,
            leadership_style: 4,
            decision_making: 5,
            legal_compliance: 5,
          },
          comment: 'Хамт олон найрсаг, сайн нөхцөлтэй.',
          createdAt: new Date(),
        },
      ];
    }

    // 🔄 Update user
    const updated = await User.findByIdAndUpdate(userId, { $set: update }, { new: true });
    console.log(`✅ Шинэчлэгдсэн хэрэглэгч: ${updated.firstName} ${updated.lastName}`);
  } catch (err) {
    console.error('❌ Алдаа:', err.message);
  }
};

// Example usage:
mongoose.connect('mongodb://localhost:27017/your_db_name')
  .then(() => fillMissingFields('68034f559fad88c4664b7298'))
  .catch(console.error);
