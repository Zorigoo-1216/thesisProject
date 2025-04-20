// server.js
const app = require('./app');
const mongoose = require('mongoose');

mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/jobmatching')
  .then(() => {
    console.log('MongoDB connected');
    console.log('connected to database');
    const PORT = process.env.PORT || 8080;
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`✅ Server running at: http://192.168.56.1:${PORT}`);
    });
  })
  .catch(err => console.error(err));
