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
  getUsersByIds
};
