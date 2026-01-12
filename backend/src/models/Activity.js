const mongoose = require('mongoose');

const activitySchema = mongoose.Schema(
    {
        user: {
            type: mongoose.Schema.Types.ObjectId,
            required: true,
            ref: 'User',
        },
        label: { type: String, required: true },
        icon: { type: String, required: true },
        color: { type: String, required: true },
        createdAt: {
            type: Date,
            default: Date.now,
            expires: 86400, // 24 hours
        },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model('Activity', activitySchema);
