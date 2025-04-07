const User = require('../models/User');
const viewUserDTO = require('../viewModels/viewUserDTO');
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
// Ажилд тохирох ажилчдыг олох
// const findUsersByQuery = async (query) => {
//   return await User.find(query);
// };

// const getUserById = async (userId) => {
//   return await User.findById(userId);
// }

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
  findUsersByQuery
};
