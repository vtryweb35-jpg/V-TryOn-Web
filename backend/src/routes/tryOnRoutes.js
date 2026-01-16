const express = require('express');
const router = express.Router();
const { processTryOn } = require('../controllers/tryOnController');
const upload = require('../middleware/tryOnUploadMiddleware');

// Define fields for person and cloth images
const tryOnUpload = upload.fields([
    { name: 'person', maxCount: 1 },
    { name: 'cloth', maxCount: 1 }
]);

router.post('/', tryOnUpload, processTryOn);

module.exports = router;
