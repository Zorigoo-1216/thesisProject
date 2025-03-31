const bcrypt = require('bcryptjs');
const userDB = require('../dataAccess/userDB');
const viewUserDTO = require('../viewModels/viewUserDTO')

// ------------------------------Login and Register----------------------------------

const registerUser = async (user) => {
  if (!user.firstName || !user.lastName || !user.phone || !user.password || !user.role) {
    throw new Error('All required fields must be provided.');
}
  //const existsByEmail = await userDB.checkUserbyEmail(user.email);
  const existsByPhone = await userDB.checkUserbyPhoneNumber(user.phone);

  if (existsByPhone) {
    throw new Error('User already exists');
  }

  user.passwordHash = await hashPassword(user.password);
  delete user.password;

  //return await userDB.createUser(user);
  regsiteredUser = await userDB.createUser(user);
  if(regsiteredUser) return "successfully registered";
};

// Login by Email
const loginByEmail = async (email, password) => {
  const user = await userDB.getUserbyEmail(email);
  if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
    throw new Error('Invalid credentials');
  }
  user.lastActiveAt = new Date();
  await user.save();
 return new viewUserDTO(user);
};

// Login by Phone
const loginByPhone = async (phone, password) => {
  const user = await userDB.getUserByPhone(phone);
  if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
    throw new Error('Invalid credentials');
  }
  user.lastActiveAt = new Date();
  await user.save();
  return new viewUserDTO(user);
};

// Hash Password
const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(10);
  return await bcrypt.hash(password, salt);
};

// ------------------------------Manage profile----------------------------------



const updateUserFields = async (userId, profileUpdates) => {
  if (!userId) throw new Error("User ID is required");
  
  console.log('Updating user fields:', profileUpdates);
  const updatedUser =  await userDB.updateUserFields(userId, profileUpdates);
  return new viewUserDTO(updatedUser);
};


const verifyUser = async (userId) => {
  var verifiedUser = await userDB.verifyUser(userId);
  return new viewUserDTO(verifiedUser);
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
  verifyUser,
  updateUserFields,
  deleteUser
};
