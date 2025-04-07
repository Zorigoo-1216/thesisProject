const userService = require('../services/UserService');
const generateToken = require('../utils/tokenUtils');
const jwt = require('jsonwebtoken');
// ---------------------login and Register---------------------
const register = async (req, res) => {
  try {
    const { firstName, lastName, phone, password, role, gender } = req.body;
    const { token, user } = await userService.registerUser({ firstName, lastName, phone, password, role, gender });

    //const user = await userService.getUserByPhone(phone); // viewUserDTO ашиглаж буцаана
    res.status(201).json({ message: 'Registered successfully', user, token });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

const login = async (req, res) => {
  try {
    const { email, phone, password } = req.body;
    let user;
    
    if (email) {
      user = await userService.loginByEmail(email, password);
    } else if (phone) {
      user = await userService.loginByPhone(phone, password);
    } else {
      throw new Error('Email or phone is required');
    }

    res.status(200).json({ message: 'Login successful', user: user.user, token: user.token });


  } catch (err) {
    res.status(401).json({ error: err.message });
  }
};

const getProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const result = await userService.getProfile(userId);
    res.status(200).json(result);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
}
const updateProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const updates = req.body;
    const result = await userService.updateProfile(userId, updates);
    res.status(200).json({ message: 'Profile updated successfully', user: result });
    
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

const verify = async (req, res) => {
  try {
    const userId = req.user.id;
    const result = await userService.verify(userId);
    res.status(200).json(result);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};
const deleteUser = async (req, res) => {
  try {
    const userId = req.user.id;
    await userService.deleteUser(userId);
    res.status(200).json({ message: 'User deleted successfully' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};



module.exports = {
  register,
  login,
  getProfile,
  updateProfile,
  verify,
  deleteUser,

};
