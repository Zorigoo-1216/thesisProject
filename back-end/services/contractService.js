// // services/contractService.js
// const contractDB = require('../dataAccess/contractDB');
// const jobDB = require('../dataAccess/jobDB');
// const userDB = require('../dataAccess/userDB');
// const applicationDB = require('../dataAccess/applicationDB');
// const { generateContractSummary } = require('../utils/contractUtils');
// const { readTemplateAndInjectData, generateDocxFile } = require('../utils/docxGenerator');

// const createContract = async ({ jobId, employerId, templateId, contractCategory }) => {
//   const job = await jobDB.getJobById(jobId);
//   if (!job) throw new Error('Job not found');

//   const contractText = await readTemplateAndInjectData(templateId, job);
//   const summary = generateContractSummary(contractText);

//   const contract = await contractDB.createContract({
//     jobId,
//     employerId,
//     templateId,
//     contractType: 'standard',
//     contractCategory,
//     contractText,
//     summary
//   });

//   await generateDocxFile(templateId, job, contract._id.toString());

//   return contract;
// };

// const getContractSummary = async (contractId) => {
//   const contract = await contractDB.getContractById(contractId);
//   if (!contract) throw new Error('Contract not found');
//   return contract.summary;
// };

// const editContract = async (contractId, newText) => {
//   const summary = generateContractSummary(newText);
//   return contractDB.updateContractText(contractId, newText, summary);
// };

// const employerSignContract = async (contractId) => {
//   return contractDB.employerSign(contractId);
// };

// const sendContractToWorkers = async (contractId, workerIds) => {
//   const template = await contractDB.getContractById(contractId);
//   if (!template) throw new Error('Base contract not found');

//   const contracts = [];
//   for (const workerId of workerIds) {
//     const newContract = await contractDB.createContract({
//       jobId: template.jobId,
//       employerId: template.employerId,
//       templateId: template.templateId,
//       workerId,
//       contractType: 'custom',
//       contractCategory: template.contractCategory,
//       contractText: template.contractText,
//       summary: template.summary
//     });
//     contracts.push(newContract);
//   }

//   return contracts;
// };

// const getContractById = async (contractId) => {
//   return await contractDB.getContractDetails(contractId);
// };

// const workerSignContract = async (contractId, workerId) => {
//   const contract = await contractDB.workerSign(contractId, workerId);
//   await applicationDB.updateStatus(contract.jobId, contract.workerId, 'selected');
//   await jobDB.addEmployeeToJob(contract.jobId, contract.workerId);
//   return contract;
// };

// const workerRejectContract = async (contractId) => {
//   return contractDB.rejectContract(contractId);
// };

// const getContractHistory = async (userId) => {
//   const user = await userDB.getUserById(userId);
//   if (!user) throw new Error('User not found');
//   return await contractDB.getContractsForUser(userId);
// };

// module.exports = {
//   createContract,
//   getContractSummary,
//   editContract,
//   employerSignContract,
//   sendContractToWorkers,
//   getContractById,
//   workerSignContract,
//   workerRejectContract,
//   getContractHistory
// };
