const User = require('../models/User');
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
  return await User.findOne({ email }, 'profile');
};
const getProfileByEmail =async (email) => {
  return await User.findOne({ email }, 'profile');
};
const getUserByPhone = async (phone) => {
  return await User.findOne({ phone });
};
const getUserByEmail = async (email) => {
  return await User.findOne({ email });
}
// хэрэглэгчийн мэдээллийг шинэчлэх
const updateUserFields = async (userId, profileUpdates) => {
  return await User.findByIdAndUpdate(userId, { $set: profileUpdates }, { new: true });
}
// хэрэглэгчийн бүртгэлийг баталгаажуулах
const verifyUser = async (userId) => {
  return await User.findByIdAndUpdate(userId, { isVerified: true });
};
// хэрэглэгчийн бүртгэлийгч устгах
const deleteUser = async (userId) => {
  return await User.findByIdAndUpdate(userId, {state: 'Inactive' });
};

// Хэрэглэгчийн профайлыг устгах
const deleteProfile = async (userId) => {
  return await User.findByIdAndUpdate(userId, { profile: null });
}
// Ажилд тохирох ажилчдыг олох
const getEligibleUsersForJob = async (createdJob) => {
  return await User.find({
    isActive: true,
    'profile.skills': { $in: job.requirements },
    scheduledJobs: { $ne: job._id } // no job conflict
  });
}

module.exports = {
  checkUserbyEmail,
  checkUserbyPhoneNumber,
  createUser,
  checkPasswordByEmail,
  checkPasswordByPhoneNumber,
  getUserByEmail,
  getUserByPhone,
  updateUserFields,
  deleteProfile,
  verifyUser,
  deleteUser,
  updateUserFields,
  getProfileByPhone,
  getProfileByEmail,
  getEligibleUsersForJob
};
