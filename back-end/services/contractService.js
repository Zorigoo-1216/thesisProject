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
  try {
    const template = await contractDB.findTemplateByJobId(jobId);
    return { success: true, data: template };
  } catch (error) {
    console.error('Error getting template by job ID:', error.message);
    return { success: false, message: error.message };
  }
};
const findByJobAndWorker = async (jobId, workerId) => {
  try {
    const contract = await Contract.findOne({
      jobId: new mongoose.Types.ObjectId(jobId),
      workerId: new mongoose.Types.ObjectId(workerId),
    });
    return { success: true, data: contract };
  } catch (error) {
    console.error('Error finding contract by job and worker:', error.message);
    return { success: false, message: error.message };
  }
};

const createContractTemplate = async (employerId, { jobId, templateName, contentHTML, summary }) => {
  try {
    //console.log('📥 Creating contract template with data:', { employerId, jobId, templateName });

    const job = await jobDB.getJobById(jobId);
    if (!job) {
      return { success: false, message: 'Job not found' };
    }

    const employer = await userDB.getUserById(employerId);
    if (!employer) {
      return { success: false, message: 'Employer not found' };
    }

    // 🔥 Mustache render хийх
    const today = new Date();
    const renderedHTML = Mustache.render(contentHTML, {
      job,
      employer,
      today: {
        year: today.getFullYear(),
        month: today.getMonth() + 1,
        day: today.getDate()
      },
      isEmployerCompany: employer.companyName ? true : false,
      isWorkerCompany: false, // Энэ одоогоор false (Worker талын мэдээлэлгүй байгаа тул)
    });

    const savedTemplate = await contractDB.createContractTemplate({
      employerId,
      jobId,
      templateName,
      title: job.title,
      contentText: contentHTML,  // ➡️ Mustache эх хувилбарыг хадгална
      contentHTML: renderedHTML, // ➡️ HTML хөрвүүлсэн хувилбарыг хадгална
      contentJSON: [],
      summary,
      status: 'draft'
    });

    //console.log('✅ Contract template saved successfully:', savedTemplate);

    return { success: true, data: savedTemplate };
  } catch (error) {
    console.error('❌ Error saving contract template:', error.message);
    return { success: false, message: error.message };
  }
};



const generateContractHTML = async (employerId, { jobId, templateName }) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job) return { success: false, message: 'Job not found' };

    if (String(job.employerId) !== String(employerId)) {
      console.error('🚨 Employer mismatch:', job.employerId, employerId);
      return { success: false, message: 'Unauthorized' };
    }

    const employer = await userDB.getUserById(employerId);
    const templatePath = path.join(__dirname, '../templates', `${templateName}.json`);
    const templateContent = JSON.parse(fs.readFileSync(templatePath, 'utf-8'));

    const context = {
      today: {
        year: new Date().getFullYear(),
        month: new Date().getMonth() + 1,
        day: new Date().getDate(),
      },
      job: {
        ...job.toObject(),
        location: job.location || '',
        title: job.title || '',
        description: job.description || '',
        requirements: (job.requirements || []).map(req => req), // Массив бүрдүүлээд тус бүрийг гаргана
        startDate: {
          year: job.startDate.getFullYear(),
          month: job.startDate.getMonth() + 1,
          day: job.startDate.getDate(),
        },
        endDate: {
          year: job.endDate.getFullYear(),
          month: job.endDate.getMonth() + 1,
          day: job.endDate.getDate(),
        },
        workStartTime: job.workStartTime || '',
        workEndTime: job.workEndTime || '',
        breakStartTime: job.breakStartTime || '',
        breakEndTime: job.breakEndTime || '',
        durationDays: Math.ceil((job.endDate - job.startDate) / (1000 * 60 * 60 * 24)),
        salary: {
          amount: job.salary.amount || 0,
          type: job.salary.type || '',
        },
        benefits: {
          transportIncluded: job.benefits?.transportIncluded || false,
          mealIncluded: job.benefits?.mealIncluded || false,
          bonusIncluded: job.benefits?.bonusIncluded || false,
        }
      },
      employer: {
        firstName: employer.firstName,
        lastName: employer.lastName,
        companyName: employer.companyName || '',
        identityNumber: employer.profile?.identityNumber || ''
      },
      worker: {
        firstName: '',
        lastName: '',
        companyName: '',
        identityNumber: ''
      },
      isEmployerCompany: !!employer.companyName, // true эсвэл false
      isWorkerCompany: false
    };
    

    const parsed = parser.parseTemplate(templateContent, { job, employer });
    const html = Mustache.render(parsed.contentText, context);

    return { success: true, data: { html, summary: parsed.summary } };
  } catch (error) {
    console.error('❌ Error generating contract HTML:', error.message);
    return { success: false, message: error.message };
  }
};






const getSummary = async (contractId, userId) => {
  try {
    const contractTemplate = await contractDB.getTemplateById(contractId);
    const job = await jobDB.getJobById(contractTemplate.jobId);

    if (
      ![contractTemplate.employerId].includes(userId) ||
      job.employees.includes(userId)
    ) {
      return { success: false, message: 'Forbidden' };
    }

    return { success: true, data: contractTemplate.summary };
  } catch (error) {
    console.error('Error getting summary:', error.message);
    return { success: false, message: error.message };
  }
};

const getContractSummary = async (contractId) => {
  const contract = await contractDB.getById(contractId);
  return contract.summary;
}
const editContract = async (id, employerId, updates) => {
  try {
    const updatedContract = await contractDB.updateContractTemplate(id, employerId, updates);
    return { success: true, data: updatedContract };
  } catch (error) {
    console.error('Error editing contract:', error.message);
    return { success: false, message: error.message };
  }
};


const signByEmployer = async (id, employerId) => {
  try {
    const updatedStatus = await contractDB.updateStatus(id, employerId, { employerSigned: true });
    return { success: true, data: updatedStatus };
  } catch (error) {
    console.error('Error signing contract by employer:', error.message);
    return { success: false, message: error.message };
  }
};


const sendToWorkers = async (contractTemplateId, employerId, employeeIds) => {
  try {
    const { template, job } = await contractDB.getTemplateAndJob(contractTemplateId, employerId);

    if (!template) return { success: false, message: 'Template not found' };
    if (!job) return { success: false, message: 'Job not found' };

    if (job.employerId.toString() !== employerId.toString()) {
      return { success: false, message: 'Unauthorized access to this job' };
    }

    const employer = await userDB.getUserById(employerId);
    if (!employer) return { success: false, message: 'Employer not found' };

    const contracts = [];

    for (const workerId of employeeIds) {
      const worker = await userDB.getUserById(workerId);
      if (!worker) continue;

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
      const notificationData = {
        title: 'New Contract',
        message: `${employer.firstName} танд ${job.title} ажилд гэрээ илгээлээ`,
        type : 'contract',
    }
  }
    return { success: true, data: contracts };
  } catch (error) {
    console.error('Error sending contracts to workers:', error.message);
    return { success: false, message: error.message };
  }
};



const getById = async (id, userId) => {
  try {
    const contract = await contractDB.getById(id);
    if (![contract.employerId, contract.workerId].includes(userId)) {
      return { success: false, message: 'Forbidden' };
    }
    return { success: true, data: contract };
  } catch (error) {
    console.error('Error getting contract by ID:', error.message);
    return { success: false, message: error.message };
  }
};

const signByWorker = async (workerId, contractId) => {
  try {
    const contract = await contractDB.getById(contractId);

    if (!contract) return { success: false, message: 'Contract not found' };

    if (contract.workerId.toString() !== workerId.toString()) {
      return { success: false, message: 'Forbidden' };
    }

    const updatedStatus = await contractDB.updateContractStatus(contractId, {
      isSignedByWorker: true,
      status: 'completed',
    });

    return { success: true, data: updatedStatus };
  } catch (error) {
    console.error('Error signing contract by worker:', error.message);
    return { success: false, message: error.message };
  }
};

const rejectByWorker = async (id, workerId) => {
  try {
    const updatedStatus = await contractDB.updateStatus(id, {
      status: 'rejected',
    });
    return { success: true, data: updatedStatus };
  } catch (error) {
    console.error('Error rejecting contract by worker:', error.message);
    return { success: false, message: error.message };
  }
};




const getContractHistory = async (userId) => {
  try {
    const history = await contractDB.getHistory(userId);
    return { success: true, data: history };
  } catch (error) {
    console.error('Error getting contract history:', error.message);
    return { success: false, message: error.message };
  }
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