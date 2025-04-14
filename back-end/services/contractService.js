const contractDB = require('../dataAccess/contractDB');
const jobDB = require('../dataAccess/jobDB');
const userDB = require('../dataAccess/userDB');
const parser = require('../utils/contractParser');
const fs = require('fs');
const path = require('path');
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


const sendToWorkers = async (contractTemplateId, employerId) => {
  const { template, job } = await contractDB.getTemplateAndJob(contractTemplateId, employerId);
  const employer = await userDB.getUserById(employerId);
  const contracts = [];

  for (const workerId of job.employees) {
    const worker = await userDB.getUserById(workerId);
    const filled = parser.generateFilledContractFromTemplate(job, employer, worker);

    const contract = await contractDB.createContract({
      ...filled,
      jobId: job._id,
      employerId,
      workerId,
      contractTemplateId,
      contractType: 'standard',
      contractCategory: template.templateName || 'wage-based'
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

const signByWorker = async (id, workerId) => {
  return await contractDB.updateContractStatus(id, workerId, { workerSigned: true });
};

const rejectByWorker = async (id, workerId) => {
  return await contractDB.updateStatus(id, workerId, { rejected: true });
};

const getContractHistory = async (userId) => {
  return await contractDB.getHistory(userId);
};


module.exports = { 
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
  };