const dotenv = require('dotenv');
dotenv.config({ path: '.env.test' });

const request = require('supertest');
const app = require('../app'); // now clean and DB-agnostic
const mongoose = require('mongoose');
const Application = require('../models/Application');
let testToken;
let testJobId;

afterAll(async () => {
  if (mongoose.connection.readyState === 1) {
    await mongoose.connection.dropDatabase(); // cleanup test DB
    await mongoose.disconnect();
  }
});

describe('📌 Full System Flow Test', () => {
  const userData = {
    firstName: 'Test',
    lastName: 'User',
    phone: '89997777',
    password: 'test123',
    role: 'individual',
    gender: 'male'
  };

  test('✅ Register', async () => {
    const res = await request(app).post('/api/auth/register').send(userData);
    console.log('🧪 REGISTER RESPONSE:', res.body);
    expect(res.statusCode).toBe(201);
    expect(res.body.token || res.body.user?.token).toBeDefined(); // defensive check
    testToken = res.body.token || res.body.user?.token || res.body.user?.accessToken;


  }, 15000);

  test('✅ Login', async () => {
    const res = await request(app).post('/api/auth/login').send({
      phone: userData.phone,
      password: userData.password
    });
    expect(res.statusCode).toBe(200);
    expect(res.body.token || res.body.user?.token).toBeDefined();
    testToken = res.body.token || res.body.user?.token || res.body.user?.accessToken;


  }, 15000);

  test('✅ Get Profile', async () => {
    const res = await request(app).get('/api/auth/profile')
      .set('Authorization', `Bearer ${testToken}`);
      console.log('🧪 TOKEN:', testToken); // add log
    expect(res.statusCode).toBe(200);
    expect(res.body.phone).toBe(userData.phone);
  }, 15000);

  test('✅ Update User Profile with Skills', async () => {
    const update = {
      profile: {
        skills: ['lifting', 'basic work'],
        mainBranch: 'Transport',
        waitingSalaryPerHour: 30000
      }
    };
  
    const res = await request(app)
      .put('/api/auth/profile/update')
      .set('Authorization', `Bearer ${testToken}`)
      .send(update);
  
    expect(res.statusCode).toBe(200);
    expect(res.body.message).toMatch(/success/i);
  }, 15000);
  
  const jobData = {
    title: 'Test Job',
    description: ['Lifting boxes', 'Packing'],
    requirements: ['lifting', 'basic work'],
    location: 'Ulaanbaatar',
    salary: { amount: 20000, type: 'daily' },
    benefits: { transportIncluded: true },
    seeker: 'individual',
    capacity: 2,
    branch: 'Transport',
    jobType: 'hourly',
    level: 'none',
    workStartTime: '09:00', // or whatever format your schema expects
    workEndTime: '18:00',
    breakStartTime: '12:00',
    breakEndTime: '13:00',
    possibleForDisabled: true,
    haveInterview: true, // 🟢 Interview field added here
    startDate: new Date(),
    endDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000)
  };
  

  test('✅ Create Job', async () => {
    const res = await request(app)
      .post('/api/jobs/create')
      .set('Authorization', `Bearer ${testToken}`)
      .send(jobData);
      console.log('🚨 CREATE JOB RESPONSE:', res.body);
    expect(res.statusCode).toBe(201);
    testJobId = res.body.job._id;
  }, 15000);

  test('✅ Search Jobs', async () => {
    const res = await request(app).get('/api/jobs/search?branch=Transport');
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.jobs)).toBe(true);
  }, 15000);
  test('✅ Get Suitable Jobs for User', async () => {
    const res = await request(app)
      .get('/api/jobs/suitable')
      .set('Authorization', `Bearer ${testToken}`);
  
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.jobs)).toBe(true); // assuming your controller returns { jobs: [...] }
  }, 15000);
  
  test('✅ Apply to Job', async () => {
    const res = await request(app)
      .post('/api/applications/apply')
      .set('Authorization', `Bearer ${testToken}`)
      .send({ jobId: testJobId });
      console.log("📨 APPLY RESPONSE BODY", res.body); 
    expect(res.statusCode).toBe(200);
  }, 15000);

  test('✅ Get My Applications', async () => {
    const res = await request(app)
      .get('/api/applications/myapplications')
      .set('Authorization', `Bearer ${testToken}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.jobs)).toBe(true);
  }, 15000);

  test('✅ Cancel Application', async () => {
    const res = await request(app)
      .delete(`/api/applications/apply/cancel/${testJobId}`)
      .set('Authorization', `Bearer ${testToken}`);
    expect(res.statusCode).toBe(200);
  }, 15000);

  test('✅ Get My All Applications', async () => {
    const res = await request(app)
      .get('/api/applications/myallapplications')
      .set('Authorization', `Bearer ${testToken}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.jobs)).toBe(true);
  }, 15000);

  test('✅ Get Applications for a Job', async () => {
    const res = await request(app)
      .get(`/api/applications/job/${testJobId}/applications`)
      .set('Authorization', `Bearer ${testToken}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.employers)).toBe(true); 
  }, 15000);

  test('✅ Re-Apply for Selection Test', async () => {
    const res = await request(app)
      .post('/api/applications/apply')
      .set('Authorization', `Bearer ${testToken}`)
      .send({ jobId: testJobId });
    expect(res.statusCode).toBe(200);
  }, 15000);

  test('✅ Select Candidates', async () => {
    await new Promise(resolve => setTimeout(resolve, 1000)); // test logic wait
    const userProfile = await request(app)
      .get('/api/auth/profile')
      .set('Authorization', `Bearer ${testToken}`);
    const userId = userProfile.body.id || userProfile.body._id;

    const res = await request(app)
      .post(`/api/applications/job/${testJobId}/select`)
      .set('Authorization', `Bearer ${testToken}`)
      .send({ selectedUserIds: [userId] });
    expect(res.statusCode).toBe(200);
  }, 15000);

  test('✅ Get Interviews by Job', async () => {
    await new Promise(resolve => setTimeout(resolve, 1000)); 
    const res = await request(app)
      .get(`/api/jobs/${testJobId}/interviews`)
      .set('Authorization', `Bearer ${testToken}`);
    expect(res.statusCode).toBe(200);
  }, 15000);

  test('✅ Select Candidates from Interview', async () => {
    // → 1. Хэрэглэгчийн ID-г авна
    const userProfile = await request(app)
      .get('/api/auth/profile')
      .set('Authorization', `Bearer ${testToken}`);
    const userId = String(userProfile.body.id || userProfile.body._id);
  
    // → 2. APPLICATION-ИЙН STATUS-ЫГ INTERVIEW БОЛГОНО
    await Application.updateMany({ jobId: testJobId }, { status: 'interview' });
  
    // → 3. INTERVIEW-Д СОНГОГДСОН ГЭСЭН ШИЙДВЭР ГАРГАНА
    const res = await request(app)
      .post(`/api/applications/job/${testJobId}/interview`)
      .set('Authorization', `Bearer ${testToken}`)
      .send({ selectedUserIds: [userId] });
  
    expect(res.statusCode).toBe(200);
  }, 15000);
  


  test('✅ Get Candidates by Job', async () => {
    await new Promise(resolve => setTimeout(resolve, 1000)); 
    const res = await request(app)
      .get(`/api/jobs/${testJobId}/candidates`)
      .set('Authorization', `Bearer ${testToken}`);
    expect(res.statusCode).toBe(200);
  }, 15000);

  test('✅ Get Employees by Job', async () => {
    await new Promise(resolve => setTimeout(resolve, 1000)); 
    const res = await request(app)
      .get(`/api/jobs/${testJobId}/employers`)
      .set('Authorization', `Bearer ${testToken}`);
    expect(res.statusCode).toBe(200);
  }, 15000);
  test('✅ Get Suitable Jobs for User', async () => {
  const res = await request(app)
    .get('/api/jobs/suitable')
    .set('Authorization', `Bearer ${testToken}`);

  expect(res.statusCode).toBe(200);
  expect(Array.isArray(res.body.jobs)).toBe(true); // assuming your controller returns { jobs: [...] }
}, 15000);

});
// test('placeholder', () => {
//     expect(true).toBe(true);
//   });