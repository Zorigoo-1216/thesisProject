const contractService = require('../services/contractService');



const getContractByJobId = async (req, res) => {
  try {
    const jobId = req.params.id;
    const contract = await contractService.getTemplateByJobId(jobId);

    if (!contract) {
      return res.status(404).json({ error: 'No contract found' });
    }

    return res.json({
      contractId: contract._id,
      contractHtml: contract.contentHTML,
      summaryHtml: contract.summary,
    });
  } catch (error) {
    console.error('❌ Error in getContractByJobId:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}


const getContractByJobAndWorker = async (req, res) => {
  const { jobId, workerId } = req.params;

  try {
    console.log("getting contract by job and worker", jobId, workerId);
    const contract = await contractService.findByJobAndWorker(jobId, workerId);
    if (!contract) return res.status(404).json({ error: 'Гэрээ олдсонгүй' });
    console.log("contract found", contract);
    res.json(contract);
  } catch (err) {
    console.error('❌ getContractByJobAndWorker error:', err.message);
    res.status(500).json({ error: 'Серверийн алдаа' });
  }
};



const generateAndReturnHTML = async (req, res) => {
  try {
    const employerId = req.user.id;
    const { jobId, templateName } = req.body;

    const { html, savedTemplate } = await contractService.generateContractHTML(
      employerId,
      { jobId, templateName }
    );

    res.status(200).json({
      html,
      templateId: savedTemplate._id,
    });
  } catch (error) {
    console.error("❌ Error in generateAndReturnHTML:", error);
    res.status(400).json({ error: error.message });
  }
};


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
  try {
    const employerId = req.user.id;
    const contractTemplateId = req.params.id;
    const { employeeIds} = req.body; // Get employee IDs from request body
    const result = await contractService.sendToWorkers(contractTemplateId, employerId, employeeIds);
    res.status(200).json({ message: 'Гэрээнүүд амжилттай илгээгдлээ', contracts: result });
  } catch (error) {
    console.error('❌ Error sending contracts:', error);
    res.status(400).json({ error: error.message });
  }
};

const employerSignContract = async (req, res) => {
  const employerId = req.user.id;
  const { id: contractTemplateId } = req.params;
  console.log("emploter is signing contract");
  console.log("Employer ID:", employerId);
  console.log("Contract Template ID:", contractTemplateId);
  console.log("Request Body:", req.body); // Log the request body for debugging
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

  try {
    console.log("Worker ID:", workerId);
    console.log("Contract ID:", contractId);

    const result = await contractService.signByWorker(workerId, contractId);

    console.log("✅ Signed contract:", result);
    res.json(result);
  } catch (err) {
    console.error("❌ Signing error:", err.message);
    res.status(500).json({ error: err.message });
  }
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
  generateAndReturnHTML,
    createContractTemplate,
  getContractSummary,
  editContract,
  employerSignContract,
  sendContractToWorkers,
  getContractById,
  workerSignContract,
  workerRejectContract,
  getContractHistory,
  getContractTemplateSummary,
 getContractByJobId,
 getContractByJobAndWorker

};