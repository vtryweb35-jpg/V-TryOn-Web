const express = require('express');
const router = express.Router();
const { getMyActivities, addActivity } = require('../controllers/activityController');
const { protect, admin } = require('../middleware/auth');

router.route('/')
    .get(protect, admin, getMyActivities)
    .post(protect, admin, addActivity);

module.exports = router;
