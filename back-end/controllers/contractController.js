const contractService = require('../services/contractService');

const createContractTemplate = async (req, res) => {
  const employerId = req.user.id;
  const { jobId, templateName } = req.body;
  const result = await contractService.createContractTemplate(employerId, { jobId, templateName });
  res.status(201).json(result);
};


const getContractTemplateSummary = async (req, res) => {
  const userId  = req.user.id;
  const contractId = req.params.id;
  const summary = await contractService.getSummary(contractId, userId);
  res.json(summary);
};

const editContract = async (req, res) => {
  const userId = req.user.id;
  const contractTemplateId = req.params.id;
  const data = req.body;
  const updated = await contractService.editContract(contractTemplateId, userId, data);
  res.json(updated);
};


const sendContractToWorkers = async (req, res) => {
  const employerId = req.user.id;
  const { id: contractTemplateId } = req.params;
  const result = await contractService.sendToWorkers(employerId, contractTemplateId);
  res.json(result);
};
const employerSignContract = async (req, res) => {
  const employerId = req.user.id;
  const { id: contractTemplateId } = req.params;
  const result = await contractService.signByEmployer(contractTemplateId, employerId);
  res.json(result);
};

const getContractSummary = async (req, res) => {
  const contractId = req.params.id;
  const result = await contractService.getContractSummary(contractId);
  res.json(result);
};


const getContractById = async (req, res) => {
  const contract = await contractService.getById(req.params.id, req.user.id);
  res.json(contract);
};

const workerSignContract = async (req, res) => {
  const workerId = req.user.id;
  const { id: contractId } = req.params;
  const result = await contractService.signByWorker(workerId, contractId);
  res.json(result);
};

const workerRejectContract = async (req, res) => {
  const result = await contractService.rejectByWorker(req.params.id, req.user.id);
  res.json(result);
};

const getContractHistory = async (req, res) => {
  const result = await contractService.getContractHistory(req.user.id);
  res.json(result);
};


module.exports = {
    createContractTemplate,
  getContractSummary,
  editContract,
  employerSignContract,
  sendContractToWorkers,
  getContractById,
  workerSignContract,
  workerRejectContract,
  getContractHistory,
  getContractTemplateSummary
};