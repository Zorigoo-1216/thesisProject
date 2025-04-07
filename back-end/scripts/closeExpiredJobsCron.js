// 📁 scripts/closeExpiredJobsCron.js
const mongoose = require('mongoose');
const cron = require('node-cron');
require('dotenv').config();
const Job = require('../models/Job');

// DB холболт
mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/jobmatching', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

console.log('[CRON] Cron job started: job closing monitor');

// ⏱ 10 минут тутамд ажиллана
if (process.env.NODE_ENV !== 'test'){
  cron.schedule('*/10 * * * *', async () => {
  try {
    const now = new Date();
    const result = await Job.updateMany(
      { endDate: { $lte: now }, status: 'open' },
      { $set: { status: 'closed' } }
    );

    if (result.modifiedCount > 0) {
      console.log(`[CRON] ${result.modifiedCount} ажил хаагдлаа (${now.toISOString()})`);
    }
  } catch (err) {
    console.error('[CRON] Error closing jobs:', err.message);
  }
});
}
