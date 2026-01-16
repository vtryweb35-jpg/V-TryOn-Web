const multer = require('multer');
const { storage } = require('../config/cloudinary');

const upload = multer({
    storage,
    fileFilter: function (req, file, cb) {
        console.log('Product upload attempting:', {
            originalname: file.originalname,
            mimetype: file.mimetype
        });

        const filetypes = /jpg|jpeg|png/;
        const extname = filetypes.test(
            file.originalname.toLowerCase()
        );
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
