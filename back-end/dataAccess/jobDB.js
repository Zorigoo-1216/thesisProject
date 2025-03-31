const Job = require("../models/Job");

//------------------------Create jobs------------------------

// Ажлын зар үүсгэх

const createJob = async (jobData) => {
    const newJob = new Job(jobData);
    return await newJob.save();
}


module.exports = {createJob};