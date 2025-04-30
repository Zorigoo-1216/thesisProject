const contractService = require('../services/contractService');



const getContractByJobId = async (req, res) => {
  try {
    const jobId = req.params.id;
    const result = await contractService.getTemplateByJobId(jobId);

    if (!result.success || !result.data) {
      return res.status(404).json({ success: false, message: 'No contract found' });
    }

    const contract = result.data;

    return res.status(200).json({
      contractId: contract._id,
      contractHtml: contract.contentHTML,
      summaryHtml: contract.summary,
    });
  } catch (error) {
    console.error('❌ Error in getContractByJobId:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};


const getContractByJobAndWorker = async (req, res) => {
  try {
    const { jobId, workerId } = req.params;
    const result = await contractService.findByJobAndWorker(jobId, workerId);

    if (!result.success || !result.data) {
      return res.status(404).json({ success: false, message: 'Гэрээ олдсонгүй' });
    }

    return res.status(200).json(result.data);
  } catch (error) {
    console.error('❌ Error in getContractByJobAndWorker:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};





const generateAndReturnHTML = async (req, res) => {
  try {
    //console.log('🔥 Incoming req.user:', req.user);

    const employerId = req.user._id || req.user.id; // Ажил олгогчийн ID-г авна
    const { jobId, templateName } = req.body;

    const result = await contractService.generateContractHTML(employerId, { jobId, templateName });

    if (result.success) {
      const { html, summary } = result.data; // 🔥 зөвхөн эдгээрийг буцаана
      res.status(200).json({ html, summary });
    } else {
      res.status(400).json({ message: result.message });
    }
  } catch (error) {
    console.error('❌ Error in generateAndReturnHTML:', error.message);
    res.status(500).json({ message: error.message });
  }
};


const createContractTemplate = async (req, res) => {
  try {
    const employerId = req.user.id || req.user._id;

    const { jobId, templateName, contentHTML, summary } = req.body;

    const result = await contractService.createContractTemplate(employerId, { jobId, templateName, contentHTML, summary });

    if (result.success) {
      res.status(201).json({
        message: 'Template created successfully',
        templateId: result.data._id
      });
    } else {
      res.status(400).json({ message: result.message });
    }
  } catch (error) {
    console.error('❌ Error creating template:', error.message);
    res.status(500).json({ message: 'Server error' });
  }
};



const getContractTemplateSummary = async (req, res) => {
  try {
    const userId = req.user.id;
    const contractId = req.params.id;

    const summary = await contractService.getSummary(contractId, userId);

    return res.status(200).json(summary);
  } catch (error) {
    console.error('❌ Error in getContractTemplateSummary:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};
const editContract = async (req, res) => {
  try {
    const userId = req.user.id;
    const contractTemplateId = req.params.id;
    const data = req.body;

    const updated = await contractService.editContract(contractTemplateId, userId, data);

    return res.status(200).json(updated);
  } catch (error) {
    console.error('❌ Error in editContract:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};



const sendContractToWorkers = async (req, res) => {
  try {
    const employerId = req.user.id;
    const contractTemplateId = req.params.id;
    const { employeeIds } = req.body;

    const result = await contractService.sendToWorkers(contractTemplateId, employerId, employeeIds);

    return res.status(200).json({ success: true, message: 'Гэрээнүүд амжилттай илгээгдлээ', contracts: result });
  } catch (error) {
    console.error('❌ Error in sendContractToWorkers:', error.message);
    return res.status(400).json({ success: false, message: error.message });
  }
};

const employerSignContract = async (req, res) => {
  try {
    const employerId = req.user.id;
    const { id: contractTemplateId } = req.params;

    const result = await contractService.signByEmployer(contractTemplateId, employerId);

    return res.status(200).json(result);
  } catch (error) {
    console.error('❌ Error in employerSignContract:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};


const getContractSummary = async (req, res) => {
  try {
    const contractId = req.params.id;

    const result = await contractService.getContractSummary(contractId);

    return res.status(200).json(result);
  } catch (error) {
    console.error('❌ Error in getContractSummary:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

const getContractById = async (req, res) => {
  try {
    const contract = await contractService.getById(req.params.id, req.user.id);

    return res.status(200).json(contract);
  } catch (error) {
    console.error('❌ Error in getContractById:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

const workerSignContract = async (req, res) => {
  try {
    const workerId = req.user.id;
    const { id: contractId } = req.params;

    const result = await contractService.signByWorker(workerId, contractId);

    return res.status(200).json(result);
  } catch (error) {
    console.error('❌ Error in workerSignContract:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

const workerRejectContract = async (req, res) => {
  try {
    const result = await contractService.rejectByWorker(req.params.id, req.user.id);

    return res.status(200).json(result);
  } catch (error) {
    console.error('❌ Error in workerRejectContract:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

const getContractHistory = async (req, res) => {
  try {
    const result = await contractService.getContractHistory(req.user.id);

    return res.status(200).json(result);
  } catch (error) {
    console.error('❌ Error in getContractHistory:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
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