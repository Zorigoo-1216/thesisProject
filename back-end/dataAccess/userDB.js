const User = require('../models/User');
const viewUserDTO = require('../viewModels/viewUserDTO');
const Rating = require('../models/Rating');
//-----------------------login хэсгийн логик------------------------
// Email хаяг бүртгэлтэй байгаа эсэхийг шалгах
const checkUserbyEmail = async (email) => {
  return await User.exists({ email });
};
// Утасны дугаар бүртгэлтэй байгаа эсэхийг шалгах
const checkUserbyPhoneNumber = async (phoneNumber) => {
  return await User.exists({ phoneNumber });
}
// хэрэглэгчийг бүртгэх
const createUser = async (user) => {
  return await User.create(user);
};
// Email хаягтай хэрэглэгчийн нууц үгийг шалгах
const checkPasswordByEmail = async (email, passwordHash) => {
  return await User.findOne({ email, passwordHash });
};
// Утасны дугаартай хэрэглэгчийн нууц үгийг шалгах
const checkPasswordByPhoneNumber = async (phoneNumber, passwordHash) => {
  return await User.findOne({ phoneNumber, passwordHash });
};

// хэрэглэгчийн мэдээллийг авах
const getProfileByPhone = async (email) => {
  const user =  await User.findOne({ email }, 'profile');
  return new viewUserDTO(user);
};
const getProfileByEmail =async (email) => {
  const user=  await User.findOne({ email }, 'profile');
  return new viewUserDTO(user);
};
const getProfileById = async (userId) => {
  const user = await User.findById(userId);
  return new viewUserDTO(user);
}
const getUserByPhone = async (phone) => {
  const user= await User.findOne({ phone });
  return new viewUserDTO(user);
};
const getUserByEmail = async (email) => {
  const user =  await User.findOne({ email });
  return new viewUserDTO(user);
}
const getUserById = async (userId) => {
  return await User.findById(userId);
}
// хэрэглэгчийн мэдээллийг шинэчлэх
const updateUserFields = async (userId, profileUpdates) => {
  const user = await User.findByIdAndUpdate(userId, { $set: profileUpdates }, { new: true });
  return new viewUserDTO(user);
}
// хэрэглэгчийн бүртгэлийг баталгаажуулах
const verifyUser = async (userId) => {
  const user= await User.findByIdAndUpdate(userId, { isVerified: true });
  return new viewUserDTO(user);
};
// хэрэглэгчийн бүртгэлийгч устгах
const deleteUser = async (userId) => {
  return await User.findByIdAndUpdate(userId, {state: 'Inactive' });
};

// Хэрэглэгчийн профайлыг устгах
const deleteProfile = async (userId) => {
  const user = await User.findByIdAndUpdate(userId, { profile: null });
  return new viewUserDTO(user);
}
const getUserByEmailFull = async (email) => {
  return await User.findOne({ email });
};

const getUserByPhoneFull = async (phone) => {
  return await User.findOne({ phone });
};
const findUsersByQuery = async (query) => {
  return await User.find(query);
}

const updateAverageRating = async (userId) => {
  const ratings = await Rating.find({ toUserId: userId });

  if (ratings.length === 0) return;

  const branchScores = {};
  const branchCounts = {};

  ratings.forEach(r => {
    const score = r.manualRating.score;
    const branch = r.branchType;

    branchScores[branch] = (branchScores[branch] || 0) + score;
    branchCounts[branch] = (branchCounts[branch] || 0) + 1;
  });

  const byBranch = Object.keys(branchScores).map(branch => ({
    branchType: branch,
    score: +(branchScores[branch] / branchCounts[branch]).toFixed(1)
  }));

  const overall = ratings.reduce((sum, r) => sum + r.manualRating.score, 0) / ratings.length;

  await User.findByIdAndUpdate(userId, {
    $set: {
      averageRating: {
        overall: +overall.toFixed(1),
        byBranch
      }
    }
  });
};
// Ажилд тохирох ажилчдыг олох
// const findUsersByQuery = async (query) => {
//   return await User.find(query);
// };

// const getUserById = async (userId) => {
//   return await User.findById(userId);
// }
const getUsersByIds = async (userIds) => {
  return await User.find({ _id: { $in: userIds } });
}


const updateEmployeeAverageRating = async (userId) => {
  console.log('📊 updateEmployeeAverageRating');
  const ratings = await Rating.find({ toUserId: userId });

  if (ratings.length === 0) return;

  const manualCriteria = [
    'speed',
    'performance',
    'quality',
    'time_management',
    'stress_management',
    'learning_ability',
    'ethics',
    'communication'
  ];

  const systemCriteria = [
    'punctuality',
    'job_completion',
    'no_show',
    'absenteeism'
  ];

  const allCriteria = [...manualCriteria, ...systemCriteria];

  const branchScores = {};
  const branchCounts = {};
  const branchCriteriaSums = {};
  const branchCriteriaCounts = {};

  // Салбар тус бүрийн нийт дундаж болон шалгуур бүрээр дундаж цуглуулах
  ratings.forEach(r => {
    const branch = r.branchType || 'unknown';
    const all = r.criteria || {};

    const manualValues = manualCriteria.map(k => all[k] || 0);
    const avg = manualValues.reduce((sum, v) => sum + v, 0) / manualValues.length;

    branchScores[branch] = (branchScores[branch] || 0) + avg;
    branchCounts[branch] = (branchCounts[branch] || 0) + 1;

    // Шалгуур бүрээр салбар тус бүрийн оноо цуглуулах
    if (!branchCriteriaSums[branch]) {
      branchCriteriaSums[branch] = {};
      branchCriteriaCounts[branch] = {};
    }

    allCriteria.forEach(k => {
      const score = all[k] || 0;
      branchCriteriaSums[branch][k] = (branchCriteriaSums[branch][k] || 0) + score;
      branchCriteriaCounts[branch][k] = (branchCriteriaCounts[branch][k] || 0) + 1;
    });
  });

  // Салбар тус бүрийн дундаж оноо
  const byBranch = Object.keys(branchScores).map(branch => ({
    branchType: branch,
    score: +(branchScores[branch] / branchCounts[branch]).toFixed(1)
  }));

  // Талбар бүрийн дундаж оноо (нийт ажилтны хувьд)
  const criteriaAverages = {};
  allCriteria.forEach(k => {
    const values = ratings.map(r => (r.criteria?.[k] ?? 0));
    const avg = values.reduce((sum, v) => sum + v, 0) / values.length;
    criteriaAverages[k] = +avg.toFixed(1);
  });

  // Ерөнхий дундаж
  const totalManualAverages = ratings.map(r => {
    const all = r.criteria || {};
    const values = manualCriteria.map(k => all[k] || 0);
    return values.reduce((sum, v) => sum + v, 0) / values.length;
  });
  const overall = totalManualAverages.reduce((a, b) => a + b, 0) / totalManualAverages.length;

  // Шинэ үнэлгээг хэрэглэгч дээр хадгалах
  const updated = await User.findByIdAndUpdate(userId, {
    $set: {
      averageRating: {
        overall: +overall.toFixed(1),
        byBranch,
        criteria: criteriaAverages
      }
    }
  });
  
  console.log("✅ Updated employee averageRating:", updated?._id?.toString() || 'Not updated');
};
const updateEmployeeBranchReview = async (userId, branchType, criteria) => {
  console.log("updating branch review");
  const user = await User.findById(userId);
  const reviewIndex = user.reviews.findIndex(r => r.branchType === branchType);

  const manualKeys = Object.keys(criteria);
  
  if (reviewIndex === -1) {
    // Шинэ салбар үүсгэх
    const newReview = {
      branchType,
      count: 1,
      criteria: {}
    };

    manualKeys.forEach(k => {
      newReview.criteria[k] = criteria[k];
    });

    user.reviews.push(newReview);
  } else {
    // Хуучин салбарын үнэлгээг шинэчлэх
    const review = user.reviews[reviewIndex];
    const newCount = review.count + 1;

    manualKeys.forEach(k => {
      const prevAvg = review.criteria[k] || 0;
      const newAvg = ((prevAvg * review.count) + criteria[k]) / newCount;
      review.criteria[k] = +newAvg.toFixed(1);
    });

    review.count = newCount;
  }

  await user.save();
};


const updateEmployerAverageRating = async (userId) => {
  const ratings = await Rating.find({
    toUserId: userId,
    targetRole: 'employer'
  });

  if (ratings.length === 0) return;

  const employerCriteria = [
    'employee_relationship',
    'salary_fairness',
    'work_environment',
    'growth_opportunities',
    'workload_management',
    'leadership_style',
    'decision_making',
    'legal_compliance'
  ];

  // 👇 Талбар бүрийн дундаж тооцоолол
  const criteriaAverages = {};
  employerCriteria.forEach(key => {
    const values = ratings.map(r => (r.criteria?.[key] ?? 0));
    const avg = values.reduce((sum, v) => sum + v, 0) / values.length;
    criteriaAverages[key] = +avg.toFixed(1);
  });

  // 👇 Нийт дундаж (бүх шалгуурын дундаж)
  const totalAverages = ratings.map(r => {
    const values = employerCriteria.map(k => r.criteria?.[k] ?? 0);
    return values.reduce((sum, v) => sum + v, 0) / values.length;
  });

  const overall = totalAverages.reduce((a, b) => a + b, 0) / totalAverages.length;

  // 👇 DB-д хадгалах
  const updated  =await User.findByIdAndUpdate(userId, {
    $set: {
      averageRatingForEmployer: {
        overall: +overall.toFixed(1),
        totalRatings: ratings.length,
        criteria: criteriaAverages
      }
    }
  });
  console.log("updated employer", updated);
};

module.exports = {
  checkUserbyEmail,
  checkUserbyPhoneNumber,
  createUser,
  checkPasswordByEmail,
  checkPasswordByPhoneNumber,
  getProfileByPhone,
  getProfileByEmail,
  getProfileById,
  getUserByPhone,
  getUserByEmail,
  updateUserFields,
  verifyUser,
  deleteUser,
  deleteProfile,
  getUserById,
  getUserByEmailFull,
  getUserByPhoneFull,
  findUsersByQuery,
  updateAverageRating,
  getUsersByIds,
  updateEmployeeAverageRating,
  updateEmployerAverageRating,
  updateEmployeeBranchReview
};
