class ViewJobDTO {
  constructor(job, applications = [], employer = {}, applied = false) {
    this.jobId = job._id;
    this.title = job.title;
    this.description = job.description;
    this.category = job.branch;
    this.location = job.location;
   
    this.salaryType = job.salary?.type || 'daily';
    this.currency = job.salary?.currency || 'MNT';
    this.jobType = job.jobType;
    this.requirements = job.requirements || [];
    this.experienceLevel = job.level || 'none';
    this.employerId = job.employerId;
    this.applicationStatus = job.status;
    this.hasInterview = job.hasInterview || false;
    this.createdAt = job.createdAt;
    this.updatedAt = job.updatedAt;
    
    this.capacity = job.capacity;
    this.possibleForDisabled = job.possibleForDisabled;
    this.startDate = job.startDate;
    this.endDate = job.endDate;
    this.benefits = job.benefits || {};
    this.status = job.status || null; 
    // ✅ ШИНЭЭР нэмсэн талбарууд
    this.employerName = employer?.name || 'Нэргүй';
    this.postedAgo = getTimeAgo(job.createdAt);
    this.isApplied = applied; 
    // ✨ Extra views
    this.applicationCount = (applications || []).length;
    this.employeeCount = 0;
    this.salary = {
      amount: job.salary?.amount || 0,
      type: job.salary?.type || 'daily',
      currency: job.salary?.currency || 'MNT'
    };
    this.applications = (applications || []).map(app => ({
      userId: app.userId,
      status: app.status,
      appliedAt: app.appliedAt,
    }));

    this.employees = []; // Хэрвээ employee мэдээлэл ирж байвал мөн ашиглаж болно
  }
}

function getTimeAgo(date) {
  const now = new Date();
  const created = new Date(date);
  const diffMs = now - created;
  const diffMins = Math.floor(diffMs / 60000);

  if (diffMins < 1) return 'Дөнгөж сая';
  if (diffMins < 60) return `${diffMins} минутын өмнө`;
  const diffHours = Math.floor(diffMins / 60);
  if (diffHours < 24) return `${diffHours} цагийн өмнө`;
  const diffDays = Math.floor(diffHours / 24);
  return `${diffDays} хоногийн өмнө`;
}

module.exports = ViewJobDTO;