const fs = require('fs');
const path = require('path');
const Mustache = require('mustache');
// parser.js
function fillTemplate(template, variables) {
  let contentText = template.contentText;
  let contentJSON = template.contentJSON.map(section => ({
    title: section.title,
    body: section.body
  }));

  // Орлуулах хувьсагч бүрийг contentText болон JSON-д ашиглана
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

// Энэ функц нь гаднаас дуудагдаж байгаа функц юм
function parseTemplate(template, variables) {
  return fillTemplate(template, variables);
}
const generateFilledContractFromTemplate = (template, job, employer, worker) => {
  if (!template || !template.contentText) throw new Error('Template or contentText is missing');

  const view = {
    employerName: employer.name,
    workerName: worker.name,
    jobTitle: job.title,
    jobDate: job.date ? new Date(job.date).toLocaleDateString() : '',
    salary: job.salary,
    phone: worker.phone || '',
    email: worker.email || '',
    address: worker.address || '',
    jobDescription: job.description || '',
    jobLocation: job.location || '',
    jobDuration: job.duration || '',
    jobType: job.type || '',
    jobRequirements: job.requirements || [],
    jobBenefits: job.benefits || [],
    jobResponsibilities: job.responsibilities || [],
    jobDate: job.date ? new Date(job.date).toLocaleDateString() : '',
    today: {
      year: new Date().getFullYear(),
      month: new Date().getMonth() + 1,
      day: new Date().getDate(),
    },
    // … бусад талбарууд
  };

  const renderedHTML = Mustache.render(template.contentText, view);
  const renderedSummary = Mustache.render(template.summary || '', view);

  return {
    contentText: template.contentText,
    contentHTML: Mustache.render(template.contentText, view),
    contentJSON: template.contentJSON || [],
    summary: Mustache.render(template.summary || '', view),
  };
};

// ✅ Энд экспорт хийж байна
module.exports = {
  parseTemplate,
  fillTemplate, // (хэрэгтэй бол)
  generateFilledContractFromTemplate
};
