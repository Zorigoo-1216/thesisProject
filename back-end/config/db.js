
const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    await mongoose.connect('mongodb://localhost:27017/jobmatching');
    console.log('connected to database');
  } catch (error) {
    console.error('not connected ', error.message);
    process.exit(1);
  }
};

module.exports = connectDB;
