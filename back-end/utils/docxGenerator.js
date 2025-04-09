const fs = require('fs');
const path = require('path');
const PizZip = require('pizzip');
const Docxtemplater = require('docxtemplater');
const { format } = require('date-fns');

const templateDir = path.join(__dirname, '../templates');
const outputDir = path.join(__dirname, '../generated');

// 1. Placeholder өгөгдлүүдийг бүрэн бэлдэнэ
function getTemplateData(job) {
  const employer = job.employerId || {};
  const worker = job.selectedWorker || {};
  const today = new Date();
  const durationDays = Math.ceil((job.endDate - job.startDate) / (1000 * 60 * 60 * 24)) + 1;

  const isEmployerCompany = employer.role === 'company';
  const isWorkerCompany = worker.role === 'company';

  return {
    today: {
      year: today.getFullYear(),
      month: today.getMonth() + 1,
      day: today.getDate(),
    },
    employer: {
      firstName: employer.firstName || '',
      lastName: employer.lastName || '',
      identityNumber: employer.profile?.identityNumber || '',
      companyName: employer.companyName || '',
      role: employer.role || ''
    },
    worker: {
      firstName: worker.firstName || '{{worker.firstName}}',
      lastName: worker.lastName || '{{worker.lastName}}',
      identityNumber: worker.identityNumber || '{{worker.identityNumber}}',
      companyName: worker.companyName || '{{worker.companyName}}',
      role: worker.role || '{{worker.role}}'
    },
    isEmployerCompany,
    isWorkerCompany,
    job: {
      title: job.title,
      description: job.description?.join(', '),
      location: job.location,
      startDate: {
        year: job.startDate?.getFullYear(),
        month: job.startDate?.getMonth() + 1,
        day: job.startDate?.getDate(),
      },
      endDate: {
        year: job.endDate?.getFullYear(),
        month: job.endDate?.getMonth() + 1,
        day: job.endDate?.getDate(),
      },
      durationDays,
      workStartTime: job.workStartTime ? format(job.workStartTime, 'HH:mm') : '',
      workEndTime: job.workEndTime ? format(job.workEndTime, 'HH:mm') : '',
      breakStartTime: job.breakTime ? format(job.breakTime, 'HH:mm') : '',
      breakEndTime: job.breakEndTime ? format(job.breakEndTime, 'HH:mm') : '',
      salary: {
        amount: job.salary?.amount,
        type: job.salary?.type,
      }
    }
  };
}

// 2. Гэрээний текстийг уншиж plain string болгож буцаана
const readTemplateAndInjectData = async (templateId, job) => {
  const templatePath = path.join(templateDir, `${templateId}.docx`);
  const content = fs.readFileSync(templatePath, 'binary');

  const zip = new PizZip(content);
  const doc = new Docxtemplater(zip, { paragraphLoop: true, linebreaks: true });

  const data = getTemplateData(job);
  doc.setData(data);

  try {
    doc.render();
  } catch (error) {
    console.error('Render error:', error);
    throw new Error('Template rendering failed');
  }

  const buffer = doc.getZip().generate({ type: 'nodebuffer' });
  return buffer.toString();
};

// 3. Гэрээний .docx файл үүсгэн хадгална
const generateDocxFile = async (templateId, job, fileNameWithoutExt) => {
  const templatePath = path.join(templateDir, `${templateId}.docx`);
  const content = fs.readFileSync(templatePath, 'binary');

  const zip = new PizZip(content);
  const doc = new Docxtemplater(zip, { paragraphLoop: true, linebreaks: true });

  const data = getTemplateData(job);
  doc.setData(data);

  try {
    doc.render();
  } catch (error) {
    console.error('Render error:', error);
    throw new Error('Template rendering failed');
  }

  const buffer = doc.getZip().generate({ type: 'nodebuffer' });
  const filePath = path.join(outputDir, `${fileNameWithoutExt}.docx`);
  fs.writeFileSync(filePath, buffer);
};

module.exports = {
  readTemplateAndInjectData,
  generateDocxFile
};
