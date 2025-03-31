const express = require('express');
const connectDB = require('./config/db');
const userRoutes = require('./routes/userRoutes');
const jobRoutes = require('./routes/jobRoutes');
require('dotenv').config();

const app = express();

// Connect to DB
connectDB();

// Middleware
app.use(express.json());

// Routes
app.use('/api/auth', userRoutes);
app.use('/api/jobs', jobRoutes);
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`✅ Server running at: http://localhost:${PORT}`));
