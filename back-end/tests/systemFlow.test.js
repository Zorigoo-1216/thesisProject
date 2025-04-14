
const dotenv = require('dotenv');
dotenv.config({ path: '.env.test' });

const request = require('supertest');
const app = require('../app');
const mongoose = require('mongoose');

const users = require('../seed/seed_users');
const jobs = require('../seed/seed_jobs.json');
let tokens = [];

let allPassed = true;

afterAll(async () => {
  if (mongoose.connection.readyState === 1) {
    if (!allPassed) {
      console.log('🧨 Test failed! Dropping database...');
      await mongoose.connection.dropDatabase();
    } else {
      await mongoose.connection.dropDatabase();
      console.log('✅ All tests passed. Keeping the data.');
    }
    await mongoose.disconnect();
  }
});
afterEach(() => {
  // Jest-ээс pass/fail статус шүүх
  const currentTest = expect.getState().currentTestName;
  const failed = expect.getState().testPathResults?.numFailingTests > 0;
  if (failed) {
    console.warn(`❌ Test failed: ${currentTest}`);
    allPassed = false;
  }
});
describe('👥 User Registration, Login, and Profile Update Flow', () => {
  test('✅ Register 10 users', async () => {
    for (let user of users) {
      const res = await request(app).post('/api/auth/register').send({
        firstName: user.firstName,
        lastName: user.lastName,
        phone: user.phone,
        password: user.password,
        role: user.role,
        gender: user.gender,
        companyName: user.companyName,
        companyType: user.companyType,
      });

      expect([200, 201]).toContain(res.statusCode);
    }
  }, 20000);

  test('✅ Login all users', async () => {
    for (let user of users) {
      const res = await request(app).post('/api/auth/login').send({
        phone: user.phone,
        password: user.password
      });

      expect(res.statusCode).toBe(200);
      const token = res.body.token || res.body.user?.token;
      expect(token).toBeDefined();
      tokens.push(token);
    }
  }, 20000);

  test('✅ Update profile for all users', async () => {
    for (let i = 0; i < users.length; i++) {
      const profile = users[i].profile;
      const res = await request(app)
        .put('/api/auth/profile/update')
        .set('Authorization', `Bearer ${tokens[i]}`)
        .send({ profile });

      expect(res.statusCode).toBe(200);
    }
  }, 20000);
  
});

describe('🧱 Create jobs for employers', () => {
  test('✅ Each of the 3 employers should create 2 jobs', async () => {
    let createdCount = 0;

    for (let job of jobs) {
      const userIndex = users.findIndex(u => u.phone === job.employerPhone); // 🛠️ FIX HERE

      if (userIndex === -1 || !tokens[userIndex]) {
        throw new Error(`❌ Token not found for employerPhone: ${job.employerPhone}`);
      }

      const token = tokens[userIndex];

      const res = await request(app)
        .post('/api/jobs/create')
        .set('Authorization', `Bearer ${token}`)
        .send({
          title: job.title,
          description: ["Цэвэрлэгээ хийх", "Ачаа зөөх"],
          requirements: ["хурдан шаламгай", "хариуцлагатай"],
          location: job.location,
          salary: job.salary,
          benefits: {
            transportIncluded: true,
            mealIncluded: false,
            bonusIncluded: true
          },
          seeker: "individual",
          capacity: job.capacity,
          branch: job.branch,
          jobType: job.jobType,
          level: "none",
          possibleForDisabled: false,
          haveInterview: job.haveInterview,
          startDate: new Date(Date.now() + 86400000),
          endDate: new Date(Date.now() + 7 * 86400000),
          workStartTime: "09:00",
          workEndTime: "18:00",
          breakStartTime: "12:00",
          breakEndTime: "13:00"
        });

      expect(res.statusCode).toBe(201);
      createdCount++;
    }

    expect(createdCount).toBe(6); // 3 хэрэглэгч * 2 ажил
  }, 20000);
});
