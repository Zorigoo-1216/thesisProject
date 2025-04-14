const fs = require('fs');
const path = require('path');

function fillTemplate(template, variables) {
  let contentText = template.contentText;
  let contentJSON = template.contentJSON.map(section => ({
    title: section.title,
    body: section.body
  }));

  Object.keys(variables).forEach(key => {
    const value = variables[key];
    const regex = new RegExp(`{{${key}}}`, 'g');
    contentText = contentText.replace(regex, value);

    contentJSON = contentJSON.map(section => ({
      ...section,
      body: section.body.replace(regex, value)
    }));
  });

  return {
    summary: template.summary,
    contentText,
    contentJSON,
    contentHTML: contentText.replace(/\n/g, '<br>')
  };
}

function generateFilledContractFromTemplate(job, employer, worker = {}) {
  const templatePath = path.join(__dirname, '..', 'templates', 'wage-based.json');
  const rawTemplate = JSON.parse(fs.readFileSync(templatePath, 'utf-8'));

  const variables = {
    'employer.firstName': employer.firstName,
    'employer.lastName': employer.lastName,
    'employer.companyName': employer.companyName || '',
    'employer.identityNumber': employer.identityNumber || '',
    'worker.firstName': worker.firstName || '',
    'worker.lastName': worker.lastName || '',
    'job.title': job.title,
    'job.salary.amount': job.salary.amount,
    'job.salary.type': job.salary.type,
    'job.location': job.location
  };

  return fillTemplate(rawTemplate, variables);
}

module.exports = { generateFilledContractFromTemplate };
