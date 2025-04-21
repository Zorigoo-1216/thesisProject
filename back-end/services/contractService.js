const contractDB = require('../dataAccess/contractDB');
const jobDB = require('../dataAccess/jobDB');
const userDB = require('../dataAccess/userDB');
const parser = require('../utils/contractParser');
const fs = require('fs');
const path = require('path');
const Mustache = require('mustache');
const mongoose = require('mongoose');
const { ObjectId } = mongoose.Types;
const ContractTemplate = require('../models/contractTemplate');

const Contract = require('../models/Contracts');

const getTemplateByJobId = async (jobId) => {
  return await contractDB.findTemplateByJobId(jobId);
}
const findByJobAndWorker = async (jobId, workerId) => {
  return await Contract.findOne({jobId: new mongoose.Types.ObjectId(jobId),
    workerId: new mongoose.Types.ObjectId(workerId) });
};

const createContractTemplate = async (employerId, { jobId, templateName }) => {
  const job = await jobDB.getJobById(jobId);
  if (!job || job.employerId.toString() !== employerId) throw new Error('Not authorized');

  const templatePath = path.join(__dirname, '../templates', `${templateName}.json`);
  const templateContent = JSON.parse(fs.readFileSync(templatePath, 'utf-8'));

  const parsed = parser.parseTemplate(templateContent, {
    employer: await userDB.getUserById(employerId),
    job
});
  return await contractDB.createContractTemplate({
    jobId,
    employerId,
    templateName,
    summary: parsed.summary,
    contentText: parsed.contentText,
    contentHTML: parsed.contentHTML,
    contentJSON: parsed.contentJSON
  });

};


const generateContractHTML = async (employerId, { jobId, templateName }) => {
  const isTemplateExists = await ContractTemplate.exists({ jobId });
  if(isTemplateExists) return "Template already exists";
  const job = await jobDB.getJobById(jobId);
  if (!job || job.employerId.toString() !== employerId.toString()) {
    throw new Error("Job not found or not authorized");
  }

  const employer = await userDB.getUserById(employerId);
  const templatePath = path.join(__dirname, '../templates', `${templateName}.json`);
  const templateContent = JSON.parse(fs.readFileSync(templatePath, 'utf-8'));

  const parsed = parser.parseTemplate(templateContent, { job, employer });

  const html = Mustache.render(parsed.contentText, {
    job,
    employer,
    today: {
      year: new Date().getFullYear(),
      month: new Date().getMonth() + 1,
      day: new Date().getDate(),
    },
  });

  const savedTemplate = await contractDB.createContractTemplate({
    jobId,
    employerId,
    templateName,
    title: job.title,
    summary: parsed.summary,
    contentText: parsed.contentText,
    contentHTML: html,
    contentJSON: parsed.contentJSON,
  });

  return { html, savedTemplate };
};


const getSummary = async (contractId, userId) => {
  const contractTemplate = await contractDB.getTemplateById(contractId);
  const job = await jobDB.getJobById(contractTemplate.jobId);

  if (![contractTemplate.employerId].includes(userId) || job.employees.includes(userId) ) throw new Error('Forbidden');
  return contractTemplate.summary;
};
const getContractSummary = async (contractId) => {
  const contract = await contractDB.getById(contractId);
  return contract.summary;
}
const editContract = async (id, employerId, updates) => {
  return await contractDB.updateContractTemplate(id, employerId, updates);
};

const signByEmployer = async (id, employerId) => {
  return await contractDB.updateStatus(id, employerId, { employerSigned: true });

};


const sendToWorkers = async (contractTemplateId, employerId, employeeIds) => {
  const { template, job } = await contractDB.getTemplateAndJob(contractTemplateId, employerId);

  if (!template) throw new Error('Template not found');
  if (!job) throw new Error('Job not found');

  if (job.employerId.toString() !== employerId.toString()) {
    throw new Error('Unauthorized access to this job');
  }

  const employer = await userDB.getUserById(employerId);
  if (!employer) throw new Error('Employer not found');

  const contracts = [];

  for (const workerId of employeeIds) {
    const worker = await userDB.getUserById(workerId);
    if (!worker) continue;

    // ❗ Template-ийг заавал дамжуулж байгаа нь хамгийн чухал
    const filled = parser.generateFilledContractFromTemplate(template, job, employer, worker);

    const contract = await contractDB.createContract({
      jobId: job._id,
      employerId,
      workerId,
      contractTemplateId,
      contractType: 'standard',
      contractCategory: template.templateName || 'wage-based',
      summary: filled.summary,
      contentText: filled.contentText,
      contentHTML: filled.contentHTML,
      contentJSON: filled.contentJSON,
      status: 'pending',
      isSignedByEmployer: true,
      isSignedByWorker: false,
      
    });

    contracts.push(contract);
  }

  return contracts;
};



const getById = async (id, userId) => {
  const contract = await contractDB.getById(id);
  if (![contract.employerId, contract.workerId].includes(userId)) throw new Error('Forbidden');
  return contract;
};

const signByWorker = async (workerId, contractId) => {
  const contract = await contractDB.getById(contractId);

  if (!contract) throw new Error('Contract not found');

  if (contract.workerId.toString() !== workerId.toString()) {
    throw new Error('Forbidden');
  }

  return await contractDB.updateContractStatus(contractId, {
    isSignedByWorker: true,
    status: 'completed',
  });
};


const rejectByWorker = async (id, workerId) => {
  return await contractDB.updateStatus(id, {
    status: 'rejected',
  });
};

const getContractHistory = async (userId) => {
  return await contractDB.getHistory(userId);
};


module.exports = { 
  generateContractHTML,
    createContractTemplate, 
    getSummary, 
    editContract, 
    signByEmployer, 
    sendToWorkers, 
    getById, 
    signByWorker, 
    rejectByWorker, 
    getContractHistory,
    getContractSummary,
    getTemplateByJobId,
    findByJobAndWorker
  };