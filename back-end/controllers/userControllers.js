const userService = require('../services/UserService');
const generateToken = require('../utils/tokenUtils');
const jwt = require('jsonwebtoken');
// ---------------------login and Register---------------------
const register = async (req, res) => {
  try {
    const { firstName, lastName, phone, password, role, gender } = req.body;
    const { token, user } = await userService.registerUser({ firstName, lastName, phone, password, role, gender });

    res.status(201).json({ success: true, message: 'Registered successfully', user, token });
  } catch (err) {
    console.error('❌ Error in register:', err.message);
    res.status(400).json({ success: false, message: err.message });
  }
};
const login = async (req, res) => {
  try {
    const { emailOrPhone, password } = req.body;

    if (!emailOrPhone || !password) {
      return res.status(400).json({ success: false, message: 'Email/Phone болон нууц үг шаардлагатай' });
    }

    let user;
    if (emailOrPhone.includes('@')) {
      user = await userService.loginByEmail(emailOrPhone, password);
    } else {
      user = await userService.loginByPhone(emailOrPhone, password);
    }

    res.status(200).json({
      success: true,
      message: 'Login successful',
      user: user.user,
      token: user.token,
    });
  } catch (err) {
    console.error('❌ Error in login:', err.message);
    res.status(401).json({ success: false, message: err.message });
  }
};


const getProfile = async (req, res) => {
  try {
    
    const userId = req.user.id;
    //console.log('📥 /getProfile GET :', userId);
    const result = await userService.getProfile(userId);
    //console.log('📤 /getProfile GET :', result);
    res.status(200).json({ success: true, data: result });
  } catch (err) {
    console.error('❌ Error in getProfile:', err.message);
    res.status(400).json({ success: false, message: err.message });
  }
};
const updateProfile = async (req, res) => {
  try {
  //console.log('📥 /updateProfile PUT :', req.body);
    const userId = req.user.id || req.params.userId || req.user._id;
    const updates = req.body;
    const result = await userService.updateProfile(userId, updates);

    res.status(200).json({ success: true, message: 'Profile updated successfully', user: result });
  } catch (err) {
    console.error('❌ Error in updateProfile:', err.message);
    res.status(400).json({ success: false, message: err.message });
  }
};

const verify = async (req, res) => {
  try {
    const userId = req.user.id;
    const result = await userService.verify(userId);

    res.status(200).json({ success: true, data: result });
  } catch (err) {
    console.error('❌ Error in verify:', err.message);
    res.status(400).json({ success: false, message: err.message });
  }
};
const deleteUser = async (req, res) => {
  try {
    const userId = req.user.id;
    await userService.deleteUser(userId);

    res.status(200).json({ success: true, message: 'User deleted successfully' });
  } catch (err) {
    console.error('❌ Error in deleteUser:', err.message);
    res.status(400).json({ success: false, message: err.message });
  }
};

const getUserInfo = async (req, res) => {
  try {
    const user = await userService.getUser();
    res.status(200).json({ success: true, data: user });
  } catch (err) {
    console.error('❌ Error in getUser:', err.message);
    res.status(400).json({ success: false, message: err.message });
  }
};

const getTopWorkers = async (req, res) => {
  try {
    //console.log('📥 /fetching top workers GET');
    const workers = await userService.getTopWorkers();
    if (!workers) {
      return res.status(404).json({ success: false, message: 'Top workers not found' });
    }
   // console.log('📤 /fetched top workers GET:', workers);
    res.status(200).json({ success: true, workers: workers.data });
  } catch (err) {
    console.error('❌ Error in getTopWorkers:', err.message);
    res.status(400).json({ success: false, message: err.message });
  }
}

module.exports = {
  register,
  login,
  getProfile,
  updateProfile,
  verify,
  deleteUser,
 getUserInfo ,
 getTopWorkers
};
