const mongoose = require('mongoose');
const { faker } = require('@faker-js/faker');
const Job = require('../models/Job');

mongoose.connect('mongodb://localhost:27017/jobmatching');

const BRANCHES = ["Цэвэрлэгээ", "Барилга", "Нүүлгэлт", "Ресторан", "Тээвэр"];
const LOCATIONS = ["БЗД", "СБД", "ХУД", "ЧД", "СХД"];
const JOB_TYPES = ["hourly", "part_time", "full_time"];

const createFakeJob = () => {
  const branch = faker.helpers.arrayElement(BRANCHES);
  const location = faker.helpers.arrayElement(LOCATIONS);
  const jobType = faker.helpers.arrayElement(JOB_TYPES);
  const startDate = faker.date.future();
  const endDate = new Date(startDate.getTime() + 2 * 24 * 60 * 60 * 1000);

  return {
    employerId: new mongoose.Types.ObjectId(), // Тест ID
    title: `${branch} ажилтан`,
    description: [faker.lorem.sentence(), faker.lorem.sentence()],
    requirements: [faker.lorem.word(), faker.lorem.word()],
    location,
    salary: {
      amount: faker.number.int({ min: 5000, max: 12000 }),
      type: "hourly"
    },
    benefits: {
      transportIncluded: faker.datatype.boolean(),
      mealIncluded: faker.datatype.boolean(),
      bonusIncluded: faker.datatype.boolean()
    },
    jobType,
    branchType: branch,
    level: "none",
    possibleForDisabled: faker.datatype.boolean(),
    status: "open",
    seeker: "individual",
    capacity: faker.number.int({ min: 1, max: 5 }),
    startDate,
    endDate,
    createdAt: new Date()
  };
};

const seedJobs = async (count = 20) => {
  const jobs = Array.from({ length: count }, () => createFakeJob());
  await Job.insertMany(jobs);
  console.log(`${count} ажлын зар нэмэгдлээ.`);
  mongoose.disconnect();
};

seedJobs(20);
