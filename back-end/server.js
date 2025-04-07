// server.js
const app = require('./app');
const mongoose = require('mongoose');

mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/jobmatching')
  .then(() => {
    console.log('connected to database');
    app.listen(process.env.PORT || 3000, () => {
      console.log('Server is running');
    });
  })
  .catch(err => console.error(err));
