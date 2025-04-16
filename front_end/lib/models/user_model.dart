class UserModel {
  final String name;
  final String role;
  final String email;
  final String phone;
  final Map<String, String> personal;
  final Map<String, String> jobInfo;
  final List<String> skills;
  final bool isVerified;

  UserModel({
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.personal,
    required this.jobInfo,
    required this.skills,
    required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      role: json['role'],
      email: json['email'],
      phone: json['phone'],
      personal: Map<String, String>.from(json['personal']),
      jobInfo: Map<String, String>.from(json['jobInfo']),
      skills: List<String>.from(json['skills']),
      isVerified: json['isVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
      'personal': personal,
      'jobInfo': jobInfo,
      'skills': skills,
      'isVerified': isVerified,
    };
  }
}
