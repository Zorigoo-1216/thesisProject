class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String role;
  final String? gender;
  final bool isVerified;
  final String? lastActiveAt;
  final String? createdAt;
  final String? updatedAt;
  final String? state;
  final Profile? profile;
  final AverageRating averageRating;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatar,
    required this.role,
    this.gender,
    required this.isVerified,
    this.lastActiveAt,
    this.createdAt,
    this.updatedAt,
    this.state,
    this.profile,
    required this.averageRating,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("🧪 UserModel JSON: $json");
    final rawId = json['id'] ?? json['_id'];
    final id = rawId != null ? rawId.toString() : '';

    return UserModel(
      id: id,
      name:
          json['name'] ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      role: json['role'] ?? '',
      gender: json['gender'],
      isVerified: json['isVerified'] ?? false,
      lastActiveAt: json['lastActiveAt'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      state: json['state'],
      profile:
          json['profile'] != null ? Profile.fromJson(json['profile']) : null,
      averageRating: AverageRating.fromJson(json['averageRating'] ?? {}),
    );
  }
}

class Profile {
  final String? birthDate;
  final String? identityNumber;
  final String? location;
  final String? mainBranch;
  final double? waitingSalaryPerHour;
  final List<String> driverLicense;
  final List<String> skills;
  final List<String> additionalSkills;
  final String? experienceLevel;
  final List<String> languageSkills;
  final bool isDisabledPerson;

  Profile({
    this.birthDate,
    this.identityNumber,
    this.location,
    this.mainBranch,
    this.waitingSalaryPerHour,
    this.driverLicense = const [],
    this.skills = const [],
    this.additionalSkills = const [],
    this.experienceLevel,
    this.languageSkills = const [],
    this.isDisabledPerson = false,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      birthDate: json['birthDate'],
      identityNumber: json['identityNumber'],
      location: json['location'],
      mainBranch: json['mainBranch'],
      waitingSalaryPerHour: (json['waitingSalaryPerHour'] ?? 0).toDouble(),
      driverLicense: List<String>.from(json['driverLicense'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      additionalSkills: List<String>.from(json['additionalSkills'] ?? []),
      experienceLevel: json['experienceLevel'],
      languageSkills: List<String>.from(json['languageSkills'] ?? []),
      isDisabledPerson: json['isDisabledPerson'] ?? false,
    );
  }
}

class AverageRating {
  final double overall;
  final List<BranchRating> byBranch;

  AverageRating({required this.overall, required this.byBranch});

  factory AverageRating.fromJson(Map<String, dynamic> json) {
    return AverageRating(
      overall:
          (json['overall'] is int)
              ? (json['overall'] as int).toDouble()
              : (json['overall'] ?? 0).toDouble(),
      byBranch:
          (json['byBranch'] as List? ?? [])
              .map((e) => BranchRating.fromJson(e))
              .toList(),
    );
  }
}

class BranchRating {
  final String branchType;
  final double score;

  BranchRating({required this.branchType, required this.score});

  factory BranchRating.fromJson(Map<String, dynamic> json) {
    return BranchRating(
      branchType: json['branchType'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
    );
  }
}
