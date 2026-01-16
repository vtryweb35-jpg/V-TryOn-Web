const multer = require('multer');
const { storage } = require('../config/cloudinary');

// Re-configure storage for try-on folder
const { cloudinary } = require('../config/cloudinary');
const { CloudinaryStorage } = require('multer-storage-cloudinary');

const tryOnStorage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
        folder: 'virtual-try-on/tryon',
        allowed_formats: ['jpg', 'png', 'jpeg'],
    },
});

const upload = multer({
    storage: tryOnStorage,
    fileFilter: function (req, file, cb) {
        console.log('Upload attempting:', {
            originalname: file.originalname,
            mimetype: file.mimetype
        });

        const filetypes = /jpg|jpeg|png/;
        const extname = filetypes.test(file.originalname.toLowerCase());
        const mimetype = filetypes.test(file.mimetype);

        if (extname || mimetype) {
            return cb(null, true);
        } else {
            console.error('File rejected. Ext:', extname, 'Mime:', mimetype);
            cb('Images only!');
        }
    },
});

module.exports = upload;
