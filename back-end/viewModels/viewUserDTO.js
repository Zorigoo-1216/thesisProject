class ViewUserDTO {
  constructor(user) {
    this.id = user._id?.toString();
    this.name = `${user.firstName} ${user.lastName}`;
    this.email = user.email || '';
    this.phone = user.phone;
    this.avatar = user.avatar || '';
    this.role = user.role;
    this.gender = user.gender;
    this.isVerified = !!user.isVerified;
    this.lastActiveAt = user.lastActiveAt || null;
    this.createdAt = user.createdAt;
    this.updatedAt = user.updatedAt || null;
    this.state = user.state || 'Active';

    this.profile = user.profile ? {
      birthDate: user.profile.birthDate || null,
      identityNumber: user.profile.identityNumber || '',
      location: user.profile.location || '',
      mainBranch: user.profile.mainBranch || '',
      waitingSalaryPerHour: user.profile.waitingSalaryPerHour || 0,
      driverLicense: Array.isArray(user.profile.driverLicense) ? user.profile.driverLicense : [],
      skills: Array.isArray(user.profile.skills) ? user.profile.skills : [],
      additionalSkills: Array.isArray(user.profile.additionalSkills) ? user.profile.additionalSkills : [],
      experienceLevel: user.profile.experienceLevel || 'beginner',
      languageSkills: Array.isArray(user.profile.languageSkills) ? user.profile.languageSkills : [],
      isDisabledPerson: !!user.profile.isDisabledPerson
    } : {
      birthDate: null,
      identityNumber: '',
      location: '',
      mainBranch: '',
      waitingSalaryPerHour: 0,
      driverLicense: [],
      skills: [],
      additionalSkills: [],
      experienceLevel: 'beginner',
      languageSkills: [],
      isDisabledPerson: false
    };

    this.averageRating = {
      overall: user.averageRating?.overall || 0,
      byBranch: Array.isArray(user.averageRating?.byBranch)
        ? user.averageRating.byBranch.map(rating => ({
            branchType: rating.branchType || '',
            score: rating.score || 0
          }))
        : [],
      criteria: {
        speed: user.averageRating?.criteria?.speed || 0,
        performance: user.averageRating?.criteria?.performance || 0,
        quality: user.averageRating?.criteria?.quality || 0,
        time_management: user.averageRating?.criteria?.time_management || 0,
        stress_management: user.averageRating?.criteria?.stress_management || 0,
        learning_ability: user.averageRating?.criteria?.learning_ability || 0,
        ethics: user.averageRating?.criteria?.ethics || 0,
        communication: user.averageRating?.criteria?.communication || 0,
        punctuality: user.averageRating?.criteria?.punctuality || 0,
        job_completion: user.averageRating?.criteria?.job_completion || 0,
        no_show: user.averageRating?.criteria?.no_show || 0,
        absenteeism: user.averageRating?.criteria?.absenteeism || 0
      }
    };

    this.averageRatingForEmployer = {
      overall: user.averageRatingForEmployer?.overall || 0,
      totalRatings: user.averageRatingForEmployer?.totalRatings || 0,
      criteria: {
        employee_relationship: user.averageRatingForEmployer?.criteria?.employee_relationship || 0,
        salary_fairness: user.averageRatingForEmployer?.criteria?.salary_fairness || 0,
        work_environment: user.averageRatingForEmployer?.criteria?.work_environment || 0,
        growth_opportunities: user.averageRatingForEmployer?.criteria?.growth_opportunities || 0,
        workload_management: user.averageRatingForEmployer?.criteria?.workload_management || 0,
        leadership_style: user.averageRatingForEmployer?.criteria?.leadership_style || 0,
        decision_making: user.averageRatingForEmployer?.criteria?.decision_making || 0,
        legal_compliance: user.averageRatingForEmployer?.criteria?.legal_compliance || 0
      }
    };

    this.reviews = Array.isArray(user.reviews)
      ? user.reviews.map(review => ({
          reviewerId: review.reviewerId?.toString() || '',
          reviewerRole: review.reviewerRole || '',
          criteria: {
            speed: review.criteria?.speed || 0,
            performance: review.criteria?.performance || 0,
            quality: review.criteria?.quality || 0,
            time_management: review.criteria?.time_management || 0,
            stress_management: review.criteria?.stress_management || 0,
            learning_ability: review.criteria?.learning_ability || 0,
            ethics: review.criteria?.ethics || 0,
            communication: review.criteria?.communication || 0,
            punctuality: review.criteria?.punctuality || 0,
            job_completion: review.criteria?.job_completion || 0,
            no_show: review.criteria?.no_show || 0,
            absenteeism: review.criteria?.absenteeism || 0
          },
          comment: review.comment || '',
          createdAt: review.createdAt || null
        }))
      : [];

    this.ratingCriteriaForEmployer = Array.isArray(user.ratingCriteriaForEmployer)
      ? user.ratingCriteriaForEmployer.map(rate => ({
          reviewerId: rate.reviewerId?.toString() || '',
          criteria: {
            employee_relationship: rate.criteria?.employee_relationship || 0,
            salary_fairness: rate.criteria?.salary_fairness || 0,
            work_environment: rate.criteria?.work_environment || 0,
            growth_opportunities: rate.criteria?.growth_opportunities || 0,
            workload_management: rate.criteria?.workload_management || 0,
            leadership_style: rate.criteria?.leadership_style || 0,
            decision_making: rate.criteria?.decision_making || 0,
            legal_compliance: rate.criteria?.legal_compliance || 0
          },
          comment: rate.comment || '',
          createdAt: rate.createdAt || null
        }))
      : [];
  }
}

module.exports = ViewUserDTO;