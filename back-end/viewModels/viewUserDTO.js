// 📁 viewModels/viewUserDTO.js
class ViewUserDTO {
  constructor(user) {
    this.id = user._id;
    this.name = `${user.firstName} ${user.lastName}`;
    this.email = user.email;
    this.phone = user.phone;
    this.avatar = user.avatar;
    this.role = user.role;
    this.gender = user.gender;
    this.isVerified = user.isVerified;
    this.lastActiveAt = user.lastActiveAt;
    this.createdAt = user.createdAt;
    this.updatedAt = user.updatedAt;
    this.state = user.state;

    this.profile = user.profile ? {
      birthDate: user.profile.birthDate,
      identityNumber: user.profile.identityNumber,
      location: user.profile.location,
      mainBranch: user.profile.mainBranch,
      waitingSalaryPerHour: user.profile.waitingSalaryPerHour,
      driverLicense: Array.isArray(user.profile.driverLicense) ? user.profile.driverLicense : [],
      skills: Array.isArray(user.profile.skills) ? user.profile.skills : [],
      additionalSkills: Array.isArray(user.profile.additionalSkills) ? user.profile.additionalSkills : [],
      experienceLevel: user.profile.experienceLevel,
      languageSkills: Array.isArray(user.profile.languageSkills) ? user.profile.languageSkills : [],
      isDisabledPerson: !!user.profile.isDisabledPerson
    } : null;

    this.averageRating = {
      overall: user.averageRating?.overall || 0,
      byBranch: Array.isArray(user.averageRating?.byBranch)
        ? user.averageRating.byBranch.map(rating => ({
            branchType: rating.brachType,
            score: rating.score || 0
          }))
        : []
    };
  }
}

module.exports = ViewUserDTO;
