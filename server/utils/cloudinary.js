const cloudinary = require('cloudinary').v2;
const dotenv = require('dotenv');

dotenv.config();

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Test Cloudinary connection
const testCloudinaryConnection = async () => {
  try {
    // Check if all required env variables are present
    if (!process.env.CLOUDINARY_CLOUD_NAME || !process.env.CLOUDINARY_API_KEY || !process.env.CLOUDINARY_API_SECRET) {
      console.error('❌ Cloudinary: Missing required environment variables');
      return false;
    }

    // Test the connection by making a simple API call
    const result = await cloudinary.api.ping();
    
    if (result.status === 'ok') {
      console.log('✅ Cloudinary connected successfully');
      console.log(`📁 Cloud Name: ${process.env.CLOUDINARY_CLOUD_NAME}`);
      return true;
    } else {
      console.error('❌ Cloudinary connection failed:', result);
      return false;
    }
  } catch (error) {
    console.error('❌ Cloudinary connection error:', error.message);
    return false;
  }
};

// Test connection when module is loaded
testCloudinaryConnection();

module.exports = cloudinary;