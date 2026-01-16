const { client, handle_file } = require("@gradio/client");
const { cloudinary } = require('../config/cloudinary');

// @desc    Process Virtual Try-On
// @route   POST /api/try-on
// @access  Public
const processTryOn = async (req, res, next) => {
    try {
        console.log('--- START TRY-ON PROCESS ---');

        if (!req.files || !req.files.person || !req.files.cloth) {
            console.warn('Missing files in request');
            return res.status(400).json({ success: false, message: 'Please upload both person and cloth images' });
        }

        const personImage = req.files.person[0];
        const clothImage = req.files.cloth[0];

        // and .path with Cloudinary storage is the URL
        console.log('Person Image:', { path: personImage.path, public_id: personImage.filename });
        console.log('Cloth Image:', { path: clothImage.path, public_id: clothImage.filename });

        console.log('Connecting to Gradio Space...');
        const app = await client("Huss67/Virtual-Try-On-Demo");

        console.log('Requesting prediction from Gradio...');
        const result = await app.predict("/tryon", [
            handle_file(personImage.path),
            handle_file(clothImage.path),
        ]);

        console.log('Gradio Result received');

        if (result.data && result.data[0]) {
            const tempUrl = result.data[0].url;
            console.log('Gradio temporary URL:', tempUrl);

            console.log('Uploading result to Cloudinary...');
            const uploadResponse = await cloudinary.uploader.upload(tempUrl, {
                folder: 'virtual-try-on/results',
            });
            console.log('Cloudinary upload success:', uploadResponse.secure_url);

            res.json({
                success: true,
                imageUrl: uploadResponse.secure_url
            });
        } else {
            console.error('Unexpected Gradio response format:', JSON.stringify(result, null, 2));
            throw new Error('The AI model returned an empty or invalid result. Please try again with different images.');
        }

        console.log('--- END TRY-ON PROCESS ---');

    } catch (error) {
        console.error('TRY-ON CONTROLLER ERROR:', error);
        // Pass to global error handler to ensure consistent response format
        next(error);
    }
};

module.exports = {
    processTryOn,
};
