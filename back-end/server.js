const app = require('./app');
const mongoose = require('mongoose');
const http = require('http');
const { initSocket } = require('./socket');

mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/jobmatching')
  .then(() => {
    console.log('✅ MongoDB connected');

    const PORT = process.env.PORT || 8080;
    const server = http.createServer(app);
    initSocket(server);

    // ✅ Express биш server-г асана
    server.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Server running at: http://192.168.56.1:${PORT}`);
    });
  })
  .catch(err => console.error('❌ DB connection error:', err));
