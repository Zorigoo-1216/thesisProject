class ViewJobProgressDTO {
    constructor(job, progress, salary) {
      this.jobTitle = job.title;
      this.jobId = job._id;
      this.workerId = progress.workerId;
      this.status = progress.status;
      this.startedAt = progress.startedAt;
      this.endedAt = progress.endedAt;
      this.salary = salary;
    }
  }
  
  module.exports = ViewJobProgressDTO;
  