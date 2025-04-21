const Mustache = require('mustache');

// ➕ Огнооны утгуудыг "today" болон "job.startDate" гэх мэт хэлбэрээр Mustache-д дамжуулах
function prepareContext(context) {
  const { job } = context;
  const today = new Date();

  const formatDate = (dateStr) => {
    const d = new Date(dateStr);
    return {
      year: d.getFullYear(),
      month: d.getMonth() + 1,
      day: d.getDate()
    };
  };

  return {
    ...context,
    today: formatDate(today),
    job: {
      ...job,
      startDate: formatDate(job.startDate),
      endDate: formatDate(job.endDate),
    },
  };
}

function parseTemplate(templateJson, context) {
  const finalContext = prepareContext(context);

  const summary = Mustache.render(templateJson.summary || '', finalContext);
  const contentText = Mustache.render(templateJson.contentText || '', finalContext);

  const contentJSON = (templateJson.contentJSON || []).map(block => ({
    title: Mustache.render(block.title || '', finalContext),
    body: Mustache.render(block.body || '', finalContext),
  }));

  const contentHTML = `<html><head><meta charset="UTF-8"></head><body style="font-family:sans-serif;line-height:1.6;padding:24px">${contentText.replace(/\n/g, '<br>')}</body></html>`;

  return {
    summary,
    contentText,
    contentHTML,
    contentJSON,
  };
}

module.exports = {
  parseTemplate
};
