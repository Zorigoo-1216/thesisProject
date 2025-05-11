const contractService = require('../services/contractService');



/**
 * Fetches the contract template associated with a given job ID.
 * 
 * @param {Object} req - The request object containing job ID in params.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @returns {Object} Returns a JSON response with the contract ID, HTML content, and summary if found.
 * 
 * @throws {Error} Returns a 404 status with a message if no contract is found, 
 * or a 500 status with 'Internal Server Error' if an unexpected error occurs.
 */

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


/**
 * Fetches a contract associated with a specific job ID and worker ID.
 * 
 * @param {Object} req - The request object containing the job ID and worker ID in params.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @returns {Object} Returns a JSON response with the contract data if found, or a 404 status with a message if no contract is found.
 * 
 * @throws {Error} Returns a 500 status with 'Internal Server Error' if an unexpected error occurs.
 */

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






/**
 * Generates a contract HTML based on the template name and job ID from the request body,
 * and returns it to the client along with the contract summary.
 *
 * @param {Object} req - The request object containing the job ID and template name.
 * @param {Object} res - The response object used to send back the HTTP response.
 *
 * @returns {Object} Returns a JSON response with the generated HTML and summary if successful, or a 400 status with an error message if the input is invalid.
 *
 * @throws {Error} Returns a 500 status with a 'Server error' message if an unexpected error occurs.
 */
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



/**
 * Creates a contract template for a given job ID and template name.
 * 
 * @param {Object} req - The request object containing job ID, template name, content HTML, and summary in body.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @returns {Object} Returns a JSON response with the created template's ID if successful, or a 400 status with an error message if the input is invalid.
 * 
 * @throws {Error} Returns a 500 status with a 'Server error' message if an unexpected error occurs.
 */
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




/**
 * Retrieves the summary of a contract template for a given contract ID and user ID.
 * 
 * @param {Object} req - The request object containing the contract ID in the params.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @returns {Object} Returns a JSON response with the contract template's summary if the user is authorized to view it, or a 500 status with an 'Internal Server Error' message if an unexpected error occurs.
 * 
 * @throws {Error} Returns a 500 status with a 'Server error' message if an unexpected error occurs.
 */
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


/**
 * Edits a contract template with the provided data for a given contract template ID and user ID.
 *
 * @param {Object} req - The request object containing user ID in user, contract template ID in params, and update data in body.
 * @param {Object} res - The response object used to send back the HTTP response.
 *
 * @returns {Object} Returns a JSON response with the updated contract template if successful, or a 500 status with an 'Internal Server Error' message if an unexpected error occurs.
 *
 * @throws {Error} Returns a 500 status with 'Internal Server Error' if an unexpected error occurs during the update process.
 */

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



/**
 * Sends the contract template to the specified workers by their IDs.
 *
 * @param {Object} req - The request object containing employer ID in user, contract template ID in params, and employee IDs in body.
 * @param {Object} res - The response object used to send back the HTTP response.
 *
 * @returns {Object} Returns a JSON response with a success message and the created contract objects if successful, or a 400 status with an error message if an unexpected error occurs.
 *
 * @throws {Error} Returns a 400 status with an error message if an unexpected error occurs during the sending process.
 */
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

/**
 * Signs a contract template by the employer.
 * 
 * @param {Object} req - The request object containing the employer's user ID and the contract template ID in params.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @returns {Object} Returns a JSON response with the result of the signing operation if successful, or a 500 status with an 'Internal Server Error' message if an unexpected error occurs.
 * 
 * @throws {Error} Returns a 500 status with 'Internal Server Error' if an unexpected error occurs during the signing process.
 */

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


/**
 * Retrieves the summary of a contract with the given contract ID.
 * 
 * @param {Object} req - The request object containing the contract ID in the params.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @returns {Object} Returns a JSON response with the contract summary if successful, or a 500 status with an 'Internal Server Error' message if an unexpected error occurs.
 * 
 * @throws {Error} Returns a 500 status with 'Internal Server Error' if an unexpected error occurs during the retrieval process.
 */
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

/**
 * Signs a contract by the worker.
 * 
 * @param {Object} req - The request object containing the worker's user ID and the contract ID in params.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @returns {Object} Returns a JSON response with the result of the signing operation if successful, or a 500 status with an 'Internal Server Error' message if an unexpected error occurs.
 * 
 * @throws {Error} Returns a 500 status with 'Internal Server Error' if an unexpected error occurs during the signing process.
 */

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

/**
 * Rejects a contract by the worker.
 * 
 * @param {Object} req - The request object containing the worker's user ID and the contract ID in params.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @returns {Object} Returns a JSON response with the result of the rejection operation if successful, or a 500 status with an 'Internal Server Error' message if an unexpected error occurs.
 * 
 * @throws {Error} Returns a 500 status with 'Internal Server Error' if an unexpected error occurs during the rejection process.
 */

const workerRejectContract = async (req, res) => {
  try {
    const result = await contractService.rejectByWorker(req.params.id, req.user.id);

    return res.status(200).json(result);
  } catch (error) {
    console.error('❌ Error in workerRejectContract:', error.message);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

/**
 * Retrieves the contract history of a given user ID.
 * 
 * @param {Object} req - The request object containing the user ID in user.
 * @param {Object} res - The response object used to send back the HTTP response.
 * 
 * @returns {Object} Returns a JSON response with the contract history if successful, or a 500 status with an 'Internal Server Error' message if an unexpected error occurs.
 * 
 * @throws {Error} Returns a 500 status with 'Internal Server Error' if an unexpected error occurs during the retrieval process.
 */
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