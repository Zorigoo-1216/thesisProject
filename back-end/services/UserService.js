const bcrypt = require('bcryptjs');
const userDB = require('../dataAccess/userDB');
const jobDB = require('../dataAccess/jobDB');
const { generateToken } = require('../utils/tokenUtils');
const viewUserDTO = require('../viewModels/viewUserDTO');
const jwt = require('jsonwebtoken');

// ------------------------------Login and Register----------------------------------

const registerUser = async ({ firstName, lastName, phone, password, role, gender }) => {
  if (!firstName || !lastName || !phone || !password || !role || !gender) {
    throw new Error('Бүх талбарыг бөглөнө үү');
  }

  const existsByPhone = await userDB.checkUserbyPhoneNumber(phone);
  if (existsByPhone) {
    throw new Error('User already exists');
  }

  const passwordHash = await hashPassword(password);
  const registeredUser = await userDB.createUser({ firstName, lastName, phone, role, gender, passwordHash });

  const token = generateToken(registeredUser._id);
  return { message: 'Амжилттай бүртгэгдлээ', token, user: new viewUserDTO(registeredUser) };
};

const loginByEmail = async (email, password) => {
  const user = await userDB.getUserByEmailFull(email); // шинэ функц, доор нэмнэ
  if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
    throw new Error('Invalid credentials');
  }

  user.lastActiveAt = new Date();
  await user.save();

  const token = generateToken(user._id);
  return { message: 'Амжилттай нэвтэрлээ', token, user: new viewUserDTO(user) };
};

const loginByPhone = async (phone, password) => {
  const user = await userDB.getUserByPhoneFull(phone); // шинэ функц, доор нэмнэ
  if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
    throw new Error('Invalid credentials');
  }

  user.lastActiveAt = new Date();
  await user.save();

  const token = generateToken(user._id);
  return { message: 'Амжилттай нэвтэрлээ', token, user: new viewUserDTO(user) };
};


// Hash Password
const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(10);
  return await bcrypt.hash(password, salt);
};

// ------------------------------Manage profile----------------------------------


const getProfile = async (userId) => {
  const user = await userDB.getProfileById(userId);
  if (!user) throw new Error('Хэрэглэгч олдсонгүй');
  return user;
};

const getUserByPhone = async (phone) => {
  const user = await userDB.getUserByPhone(phone); // энэ нь viewUserDTO буцаадаг
  return user;
};

const updateProfile = async (userId, profileUpdates) => {
  if (!userId) throw new Error("User ID is required");
  const updatedUser =  await userDB.updateUserFields(userId, profileUpdates);
  return updatedUser
};


const verifyUser = async (userId) => {
  var verifiedUser = await userDB.verifyUser(userId);
  return verifiedUser;
};


const deleteUser = async (userId) => {
  if (!userId) throw new Error("User ID is required");
  const deletedUser = await userDB.deleteUser(userId);
  if(deletedUser.state == 'Inactive') return "successfully deleted";
  else throw new Error("User not found or already deleted");
}

module.exports = {
  registerUser,
  loginByEmail,
  loginByPhone,
  getProfile,
  verifyUser,
  updateProfile,
  deleteUser,
  getUserByPhone
};
