const bcrypt = require('bcryptjs');
const userDB = require('../dataAccess/userDB');
const jobDB = require('../dataAccess/jobDB');
const { generateToken } = require('../utils/tokenUtils');
const viewUserDTO = require('../viewModels/viewUserDTO');
const jwt = require('jsonwebtoken');

// ------------------------------Login and Register----------------------------------

const registerUser = async ({ firstName, lastName, phone, password, role, gender }) => {
  try {
    if (!firstName || !lastName || !phone || !password || !role || !gender) {
      return { success: false, message: 'Бүх талбарыг бөглөнө үү' };
    }

    const existsByPhone = await userDB.checkUserbyPhoneNumber(phone);
    if (existsByPhone) {
      return { success: false, message: 'User already exists' };
    }

    const passwordHash = await hashPassword(password);
    const registeredUser = await userDB.createUser({ firstName, lastName, phone, role, gender, passwordHash });

    const token = generateToken(registeredUser._id);
    return { success: true, message: 'Амжилттай бүртгэгдлээ', token, user: new viewUserDTO(registeredUser) };
  } catch (error) {
    console.error('Error registering user:', error.message);
    return { success: false, message: error.message };
  }
};

const loginByEmail = async (email, password) => {
  try {
    const user = await userDB.getUserByEmailFull(email);
    if (!user) {
      return { success: false, message: 'Хэрэглэгч олдсонгүй' };
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      return { success: false, message: 'Нууц үг буруу байна' };
    }

    user.lastActiveAt = new Date();
    await user.save();

    const token = generateToken(user._id);
    return { success: true, message: 'Амжилттай нэвтэрлээ', token, user: new viewUserDTO(user) };
  } catch (error) {
    console.error('Error logging in by email:', error.message);
    return { success: false, message: error.message };
  }
};


const loginByPhone = async (phone, password) => {
  try {
    const user = await userDB.getUserByPhoneFull(phone);
    if (!user) {
      return { success: false, message: 'Хэрэглэгч олдсонгүй' };
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      return { success: false, message: 'Нууц үг буруу байна' };
    }

    user.lastActiveAt = new Date();
    await user.save();

    const token = generateToken(user._id);
    return { success: true, message: 'Амжилттай нэвтэрлээ', token, user: new viewUserDTO(user) };
  } catch (error) {
    console.error('Error logging in by phone:', error.message);
    return { success: false, message: error.message };
  }
};
// Hash Password
const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(10);
  return await bcrypt.hash(password, salt);
};

// ------------------------------Manage profile----------------------------------


const getProfile = async (userId) => {
  try {
    const user = await userDB.getProfileById(userId);
    if (!user) return { success: false, message: 'Хэрэглэгч олдсонгүй' };
    return { success: true, data: user };
  } catch (error) {
    console.error('Error getting profile:', error.message);
    return { success: false, message: error.message };
  }
};

const getUserByPhone = async (phone) => {
  try {
    const user = await userDB.getUserByPhone(phone);
    return { success: true, data: user };
  } catch (error) {
    console.error('Error getting user by phone:', error.message);
    return { success: false, message: error.message };
  }
};


const updateProfile = async (userId, profileUpdates) => {
  try {
    if (!userId) return { success: false, message: 'User ID is required' };
    const updatedUser = await userDB.updateUserFields(userId, profileUpdates);
    return { success: true, data: updatedUser };
  } catch (error) {
    console.error('Error updating profile:', error.message);
    return { success: false, message: error.message };
  }
};


const verifyUser = async (userId) => {
  try {
    const verifiedUser = await userDB.verifyUser(userId);
    return { success: true, data: verifiedUser };
  } catch (error) {
    console.error('Error verifying user:', error.message);
    return { success: false, message: error.message };
  }
};



const deleteUser = async (userId) => {
  try {
    if (!userId) return { success: false, message: 'User ID is required' };
    const deletedUser = await userDB.deleteUser(userId);
    if (deletedUser.state === 'Inactive') {
      return { success: true, message: 'Successfully deleted' };
    } else {
      return { success: false, message: 'User not found or already deleted' };
    }
  } catch (error) {
    console.error('Error deleting user:', error.message);
    return { success: false, message: error.message };
  }
};

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
