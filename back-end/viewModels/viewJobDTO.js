class ViewJobDTO {
  constructor(job, applications = [], employees = []) {
    this.jobId = job._id;
    this.title = job.title;
    this.description = job.description;
    this.category = job.branchType;
    this.location = job.location;
    this.salary = job.salary?.amount || 0;
    this.salaryType = job.salary?.type || 'daily';
    this.currency = job.salary?.currency || 'MNT';
    this.jobType = job.jobType;
    this.requirements = job.requirements || [];
    this.experienceLevel = job.level || 'none';
    this.employerId = job.employerId;
    this.status = job.status;
    this.haveInterview = job.haveInterview || false;
    this.createdAt = job.createdAt;
    this.updatedAt = job.updatedAt;

    this.capacity = job.capacity;
    this.possibleForDisabled = job.possibleForDisabled;
    this.startDate = job.startDate;
    this.endDate = job.endDate;
    this.benefits = job.benefits || {};

    // Extra views
    this.applicationCount = (applications || []).length;
    this.employeeCount = (employees || []).length;

    this.applications = (applications || []).map(app => ({
      userId: app.userId,
      status: app.status,
      appliedAt: app.appliedAt,
    }));

    this.employees = (employees || []).map(emp => ({
      userId: emp._id,
      name: [emp.firstName, emp.lastName].filter(Boolean).join(' '),
      phone: emp.phone,
      rating: emp.rating || 0,
    }));
  }
}

module.exports = ViewJobDTO;
