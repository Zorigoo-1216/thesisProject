const express = require('express');
const router = express.Router();
const userController = require('../controllers/userControllers');
const authMiddleware = require('../middleware/authMiddleware');

// ---------------------------login and Register-------------------------------------
router.post('/register', userController.register); // use case 1.1
router.post('/login', userController.login); // use case 1.2 
//router.post('/forgotpassword', userController.forgotPassword); // use case 1.3 daraa hiinee haha
router.get('/profile', authMiddleware, userController.getProfile);

router.put('/profile/:id/update', authMiddleware, userController.updateProfile);
//router.get('/getuserinfo/:id', userController.getUserInfo);
// --------------------Manage Profile--------------------------------
router.put('/profile/verifyaccount',authMiddleware, userController.verify);  // use case 2.1
router.delete('/profile', authMiddleware, userController.deleteUser);

router.get('/workers', userController.getTopWorkers); // use case 2.2


module.exports = router;
