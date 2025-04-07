const express = require('express');
const connectDB = require('./config/db');
const userRoutes = require('./routes/userRoutes');
const jobRoutes = require('./routes/jobRoutes');
const applicationRoutes = require('./routes/applicationRoutes');
const contractRoutes = require('./routes/contractRoutes');
require('dotenv').config();

const app = express();

// Connect to DB
connectDB();

// Middleware
app.use(express.json());

// Routes
app.use('/api/auth', userRoutes);
app.use('/api/jobs', jobRoutes);
app.use('/api/applications', applicationRoutes );
//app.use('/api/contracts', contractRoutes);
module.exports = app;

//  require('./scripts/closeExpiredJobsCron');


if (require.main === module) {
    const PORT = process.env.PORT || 8080;
    app.listen(PORT, () => console.log(`✅ Server running at: http://localhost:${PORT}`));
  }
  