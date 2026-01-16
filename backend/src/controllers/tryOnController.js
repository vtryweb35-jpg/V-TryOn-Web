const { client, handle_file } = require("@gradio/client");
const fs = require('fs');
const path = require('path');

// @desc    Process Virtual Try-On
// @route   POST /api/try-on
// @access  Public (or Private depending on your needs)
const processTryOn = async (req, res) => {
    try {
        if (!req.files || !req.files.person || !req.files.cloth) {
            return res.status(400).json({ success: false, message: 'Please upload both person and cloth images' });
        }

        const personImage = req.files.person[0];
        const clothImage = req.files.cloth[0];

        console.log(`Processing try-on for: ${personImage.path} and ${clothImage.path}`);

        const app = await client("Huss67/Virtual-Try-On-Demo");

        const result = await app.predict("/tryon", [
            handle_file(personImage.path),
            handle_file(clothImage.path),
        ]);

        console.log("Gradio prediction result:", JSON.stringify(result, null, 2));

        if (result.data && result.data[0]) {
            const tempUrl = result.data[0].url;
            console.log("Uploading temporary result to Cloudinary:", tempUrl);

            // Upload the temporary Gradio URL to Cloudinary
            const { cloudinary } = require('../config/cloudinary');
            const uploadResponse = await cloudinary.uploader.upload(tempUrl, {
                folder: 'virtual-try-on/results',
            });

            res.json({
                success: true,
                imageUrl: uploadResponse.secure_url
            });
        } else {
            console.error("Unexpected response from Gradio Space:", result);
            res.status(500).json({ success: false, message: 'Unexpected response from try-on service', details: result });
        }

        // Optionally delete the uploaded files after processing
        // fs.unlinkSync(personImage.path);
        // fs.unlinkSync(clothImage.path);

    } catch (error) {
        console.error('Try-On Error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
};

module.exports = {
    processTryOn,
};
