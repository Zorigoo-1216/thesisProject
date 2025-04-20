const express = require('express');
const connectDB = require('./config/db');
const userRoutes = require('./routes/userRoutes');
const jobRoutes = require('./routes/jobRoutes');
const applicationRoutes = require('./routes/applicationRoutes');
const contractRoutes = require('./routes/contractRoutes');
const jobprogressRoutes = require('./routes/jobProgressRoutes');
const paymentRoutes = require('./routes/paymentRoute');
const ratingRoutes = require('./routes/ratingRoute');
const cors = require('cors');

require('dotenv').config();

const app = express();

// Connect to DB
connectDB();

// Middleware
app.use(express.json());
app.use(cors());
// Routes
app.use('/api/auth', userRoutes);
app.use('/api/jobs', jobRoutes);
app.use('/api/applications', applicationRoutes );
app.use('/api/jobprogress', jobprogressRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/contracts', contractRoutes);
app.use('/api/ratings', ratingRoutes);
//app.use('/api/ratings', ratingRoutes);

//app.use('/api/contracts', contractRoutes);
module.exports = app;

//  require('./scripts/closeExpiredJobsCron');
  