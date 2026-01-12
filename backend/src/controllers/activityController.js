const Activity = require('../models/Activity');
const asyncHandler = require('../middleware/errorMiddleware');

// @desc    Get logged in brand's activities
// @route   GET /api/activities
// @access  Private/Admin
const getMyActivities = asyncHandler(async (req, res) => {
    const activities = await Activity.find({ user: req.user._id })
        .sort({ createdAt: -1 })
        .limit(15);
    res.json(activities);
});

// @desc    Log a new activity
// @route   POST /api/activities
// @access  Private/Admin
const addActivity = asyncHandler(async (req, res) => {
    const { label, icon, color } = req.body;

    const activity = new Activity({
        user: req.user._id,
        label,
        icon,
        color,
    });

    const createdActivity = await activity.save();
    res.status(201).json(createdActivity);
});

module.exports = {
    getMyActivities,
    addActivity,
};
