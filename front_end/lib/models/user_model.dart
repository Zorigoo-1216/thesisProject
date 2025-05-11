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
  final AverageRatingForEmployer averageRatingForEmployer;
  final List<Review> reviews;
  final List<EmployerRating> ratingCriteriaForEmployer;

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
    required this.averageRatingForEmployer,
    this.reviews = const [],
    this.ratingCriteriaForEmployer = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
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
      averageRatingForEmployer: AverageRatingForEmployer.fromJson(
        json['averageRatingForEmployer'] ?? {},
      ),
      reviews:
          (json['reviews'] as List? ?? [])
              .map((e) => Review.fromJson(e))
              .toList(),
      ratingCriteriaForEmployer:
          (json['ratingCriteriaForEmployer'] as List? ?? [])
              .map((e) => EmployerRating.fromJson(e))
              .toList(),
    );
  }
}

class Profile {
  final String? birthDate;
  final String? identityNumber;
  final String? location;
  final String? mainBranch;
  final double waitingSalaryPerHour;
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
    required this.waitingSalaryPerHour,
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
  final Map<String, num> criteria;

  AverageRating({
    required this.overall,
    required this.byBranch,
    required this.criteria,
  });

  factory AverageRating.fromJson(Map<String, dynamic> json) {
    return AverageRating(
      overall: (json['overall'] ?? 0).toDouble(),
      byBranch:
          (json['byBranch'] as List? ?? [])
              .map((e) => BranchRating.fromJson(e))
              .toList(),
      criteria: Map<String, num>.from(json['criteria'] ?? {}),
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

class AverageRatingForEmployer {
  final double overall;
  final int totalRatings;
  final Map<String, num> criteria;

  AverageRatingForEmployer({
    required this.overall,
    required this.totalRatings,
    required this.criteria,
  });

  factory AverageRatingForEmployer.fromJson(Map<String, dynamic> json) {
    return AverageRatingForEmployer(
      overall: (json['overall'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      criteria: Map<String, num>.from(json['criteria'] ?? {}),
    );
  }
}

class Review {
  final String reviewerId;
  final String reviewerRole;
  final String comment;
  final String createdAt;
  final Map<String, num> criteria;

  Review({
    required this.reviewerId,
    required this.reviewerRole,
    required this.comment,
    required this.createdAt,
    required this.criteria,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewerId: json['reviewerId'] ?? '',
      reviewerRole: json['reviewerRole'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
      criteria: Map<String, num>.from(json['criteria'] ?? {}),
    );
  }
}

class EmployerRating {
  final String reviewerId;
  final String comment;
  final String createdAt;
  final Map<String, num> criteria;

  EmployerRating({
    required this.reviewerId,
    required this.comment,
    required this.createdAt,
    required this.criteria,
  });

  factory EmployerRating.fromJson(Map<String, dynamic> json) {
    return EmployerRating(
      reviewerId: json['reviewerId'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
      criteria: Map<String, num>.from(json['criteria'] ?? {}),
    );
  }
}
