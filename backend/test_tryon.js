const { client, handle_file } = require("@gradio/client");
const fs = require('fs');
const path = require('path');

async function testTryOn() {
    try {
        console.log("Connecting to Gradio client...");
        const app = await client("Huss67/Virtual-Try-On-Demo");

        // Use some sample images if they exist, or just placeholder data
        const personUrl = "https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png";
        const clothUrl = "https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png";

        console.log("Sending prediction request with handle_file...");
        const result = await app.predict("/tryon", [
            handle_file(personUrl),
            handle_file(clothUrl),
        ]);

        console.log("Success! Result:");
        console.log(JSON.stringify(result, null, 2));

        if (result.data && result.data[0]) {
            console.log("Image URL:", result.data[0].url);
        }
    } catch (error) {
        console.error("Test failed:", error);
    }
}

testTryOn();
