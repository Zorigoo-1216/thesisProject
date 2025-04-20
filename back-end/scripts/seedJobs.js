// const mongoose = require('mongoose');
// const Job = require('../models/Job'); // Adjust the path if necessary

// const jobs = [
//   // Jobs for Зоригоо
//   {
//     employerId: '68034f559fad88c4664b7298',
//     title: 'Барилгын туслах ажилтан авна',
//     description: ['Барилгын ажилд туршлагатай', 'Бие дааж ажиллах чадвартай'],
//     location: 'Улаанбаатар, Баянгол дүүрэг',
//     salary: { amount: 100000, type: 'daily' },
//     benefits: { transportIncluded: true, mealIncluded: true },
//     seeker: 'individual',
//     capacity: 3,
//     branch: 'Барилга',
//     jobType: 'full_time',
//     level: 'mid',
//     status: 'open',
//     startDate: new Date('2025-05-01'),
//     endDate: new Date('2025-05-10'),
//     workStartTime: '08:00',
//     workEndTime: '17:00',
//     breakStartTime: '12:00',
//     breakEndTime: '13:00',
//     haveInterview: false,
//     endedAt: new Date('2025-05-01')
//   },
//   {
//     employerId: '68034f559fad88c4664b7298',
//     title: 'Цэвэрлэгээний ажилтан авна',
//     description: ['Цэвэрлэгээний туршлагатай', 'Эмэгтэй хүн'],
//     location: 'Улаанбаатар, Чингэлтэй дүүрэг',
//     salary: { amount: 80000, type: 'daily' },
//     benefits: { bonusIncluded: true },
//     seeker: 'individual',
//     capacity: 2,
//     branch: 'Цэвэрлэгээ',
//     jobType: 'part_time',
//     level: 'none',
//     status: 'open',
//     startDate: new Date('2025-06-01'),
//     endDate: new Date('2025-06-10'),
//     workStartTime: '10:00',
//     workEndTime: '15:00',
//     breakStartTime: '12:00',
//     breakEndTime: '13:00',
//     haveInterview: false,
//     endedAt: new Date('2025-05-01')
//   },

//   // Jobs for Зоригтбаатар
//   {
//     employerId: '680351c992a2f1cf7f3c7507',
//     title: 'Зөөвөрлөх ажилтан авна',
//     description: ['Физик хүч чадал сайн', 'Ачаа зөөх туршлагатай'],
//     location: 'Улаанбаатар, Баяназүрх дүүрэг',
//     salary: { amount: 120000, type: 'daily' },
//     benefits: { transportIncluded: true },
//     seeker: 'individual',
//     capacity: 4,
//     branch: 'Зөөвөр',
//     jobType: 'full_time',
//     level: 'high',
//     status: 'open',
//     startDate: new Date('2025-05-05'),
//     endDate: new Date('2025-05-12'),
//     workStartTime: '08:00',
//     workEndTime: '18:00',
//     breakStartTime: '12:00',
//     breakEndTime: '13:00',
//     haveInterview: false,
//     endedAt: new Date('2025-05-01')
//   },
//   {
//     employerId: '680351c992a2f1cf7f3c7507',
//     title: 'Тавилгын агуулах ажилтан авна',
//     description: ['Агуулахад ажиллах туршлагатай', 'Хурдан хөдөлгөөнтэй'],
//     location: 'Улаанбаатар, Сонгинохайрхан дүүрэг',
//     salary: { amount: 90000, type: 'daily' },
//     benefits: { mealIncluded: true },
//     seeker: 'individual',
//     capacity: 5,
//     branch: 'Агуулах',
//     jobType: 'hourly',
//     level: 'mid',
//     status: 'open',
//     startDate: new Date('2025-06-05'),
//     endDate: new Date('2025-06-15'),
//     workStartTime: '09:00',
//     workEndTime: '17:00',
//     breakStartTime: '12:00',
//     breakEndTime: '13:00',
//     haveInterview: false,
//     endedAt: new Date('2025-05-01')
//   }
// ];

// const connectDB = async () => {
//   try {
//     await mongoose.connect('mongodb://localhost:27017/jobmatching', {
//       useNewUrlParser: true,
//       useUnifiedTopology: true
//     });
//     console.log('Connected to MongoDB');
//   } catch (error) {
//     console.error('Database connection failed:', error.message);
//     process.exit(1);
//   }
// };

// const seedJobs = async () => {
//   await connectDB();
//   try {
//     const res = await Job.insertMany(jobs);
//     console.log('Jobs inserted successfully:', res);
//   } catch (error) {
//     console.error('Error inserting jobs:', error);
//   } finally {
//     mongoose.disconnect();
//   }
// };

// seedJobs();
