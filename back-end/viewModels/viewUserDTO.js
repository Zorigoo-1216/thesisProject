class ViewProfileDTO {
  constructor(user) {
    this.id = user._id;
    this.name = `${user.firstName} ${user.lastName}`;
    this.email = user.email;
    this.phone = user.phone;
    this.role = user.role;
    this.gender = user.gender;
    this.isVerified = user.isVerified;
    this.lastActiveAt = user.lastActiveAt;
    this.createdAt = user.createdAt;

    // profile details
    this.profile = user.profile ? {
      birthDate: user.profile.birthDate,
      identityNumber: user.profile.identityNumber,
      location: user.profile.location,
      mainBranch: user.profile.mainBranch,
      waitingSalaryPerHour: user.profile.waitingSalaryPerHour,
      driverLicense: user.profile.driverLicense,
      skills: user.profile.skills,
      additionalSkills: user.profile.additionalSkills,
      experienceLevel: user.profile.experienceLevel,
      languageSkills: user.profile.languageSkills,
      isDisabledPerson: user.profile.isDisabledPerson
    } : null;

    // rating details
    this.averageRating = user.averageRating || { overall: 0, byBranch: {} };
  }
}

module.exports = ViewProfileDTO;
