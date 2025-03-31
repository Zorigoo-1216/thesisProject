const express = require('express');
const router = express.Router();
const userController = require('../controllers/userControllers');


// ---------------------------login and Register-------------------------------------
router.post('/register', userController.register);
router.post('/login', userController.login);


// --------------------Manage Profile--------------------------------
router.post('/updateprofile', userController.updateProfile);
router.put('/verifyaccount', userController.verify);
router.delete('/deleteaccount', userController.deleteUser);
//router.get('/getprofile', userController.getProfile);
module.exports = router;
