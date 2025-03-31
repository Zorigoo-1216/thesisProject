const userService = require('../services/UserService');
const viewUserDTO = require('../viewModels/viewUserDTO');
// ---------------------login and Register---------------------
const register = async (req, res) => {
  try {
    const user = await userService.registerUser(req.body);
    res.status(201).json({ message: 'Registered successfully', user });
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

    res.status(200).json({ message: 'Login successful', user });
  } catch (err) {
    res.status(401).json({ error: err.message });
  }
};


// ---------------------Manage Profile---------------------
// Хэрэглэгчинй мэдээлэл оруулах устгах засах
const updateProfile = async (req, res) => {
  try {
    //console.log("Request Body:", req.body);
    if (!req.body || typeof req.body !== "object") {
      return res.status(400).json({ error: "Request body is missing or invalid" });
    }

    const userId = req.user?.id || req.body.id;
    if (!userId) {
      return res.status(400).json({ error: "User ID is required" });
    }

    const profileUpdates = {};

    // Update general user fields
    if (req.body.firstName) profileUpdates.firstName = req.body.firstName;
    if (req.body.lastName) profileUpdates.lastName = req.body.lastName;
    if (req.body.phone) profileUpdates.phone = req.body.phone;
    if (req.body.gender) profileUpdates.gender = req.body.gender;

    // Update profile-specific fields safely
    if (req.body.profile && typeof req.body.profile === "object") {
      Object.keys(req.body.profile).forEach((key) => {
        profileUpdates[`profile.${key}`] = req.body.profile[key];
      });
    }
    //console.log("profileUpdates:", profileUpdates);
    const updated = await userService.updateUserFields(userId, profileUpdates);
    if (!updated) {
      return res.status(404).json({ error: "User not found" });
    }

    res.status(200).json({ message: "Profile updated successfully", user: updated });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Хэрэглэгчийн бүртгэлийг баталгаажуулах
const verify = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.id;
    console.log('Verifying user with ID:', userId);
    user = await userService.verifyUser(userId);
    res.status(200).json({ message: 'Account verified successfully' , user: user });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
}
  


//  Хэрэглэгчийн бүртгэлийг устгах
const deleteUser = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.id;
    console.log('Deleting user with ID:', userId);
    await userService.deleteUser(userId);
    res.status(200).json({ message: 'User deleted successfully' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
}
module.exports = {
  register,
  login,
  updateProfile,
  verify,
  deleteUser
};
