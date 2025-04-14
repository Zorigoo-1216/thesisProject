const Contract = require('../models/Contracts');
const ContractTemplate = require('../models/contractTemplate');
const Job = require('../models/Job');
const createContractTemplate = async (data) => {
    return await ContractTemplate.create(data);
};
const generateSummary = async (contractId) => {
  const contract = await Contract.findById(contractId);
  // generate summary
  const summary = 'Generated summary';
  contract.summary = summary;
  await contract.save();
  return summary;
};
const getById = async (id) => {
  return await Contract.findById(id);
};
const getTemplateById = async (id) => {
  return await ContractTemplate.findById(id);
}
const updateContractTemplate = async (id, employerId, updates) => {
  return await ContractTemplate.findOneAndUpdate({ _id: id, employerId }, updates, { new: true });
};

const updateStatus = async (id, userId, updates) => {
  return await ContractTemplate.findOneAndUpdate(
    { _id: id, $or: [{ employerId: userId }] },
    updates,
    { new: true }
  );
};

const getHistory = async (userId) => {
  return await Contract.find({
    $or: [{ employerId: userId }, { workerId: userId }],
    $or: [{ workerSigned: true }, { rejected: true }]
  });
};
const getTemplateAndJob = async (templateId, employerId) => {
    const template = await ContractTemplate.findOne({ _id: templateId, employerId });
    if (!template) throw new Error('Template not found');
  
    const job = await Job.findById(template.jobId);
    return { template, job };
  };

const updateContractStatus  = async (id, updates) => {
    const contract = await Contract.findById(id);
    if (!contract) throw new Error('Contract not found');
    return await Contract.findOneAndUpdate({ _id: id }, updates, { new: true });
}
module.exports = {
  createContractTemplate,
  getById,
  updateContractTemplate,
  updateStatus,
  getHistory,
  getTemplateById,
  getTemplateAndJob,
  updateContractStatus,
 generateSummary,

};