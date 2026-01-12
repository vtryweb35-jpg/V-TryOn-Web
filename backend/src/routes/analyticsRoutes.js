const express = require('express');
const router = express.Router();
const { logTryOn, getAnalytics } = require('../controllers/analyticsController');
const { protect, admin, optionalProtect } = require('../middleware/auth');

router.post('/try-on', optionalProtect, logTryOn);

router.get('/', protect, admin, getAnalytics);

module.exports = router;
