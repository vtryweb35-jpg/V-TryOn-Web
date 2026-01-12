const express = require('express');
const router = express.Router();
const { registerUser, authUser, getUserProfile, updateUserProfile, uploadUserProfileImage } = require('../controllers/authController');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/uploadMiddleware');

router.post('/register', registerUser);
router.post('/login', authUser);
router.post('/upload-profile', protect, upload.single('profilePic'), uploadUserProfileImage);
router.route('/profile')
    .get(protect, getUserProfile)
    .put(protect, updateUserProfile);

module.exports = router;
