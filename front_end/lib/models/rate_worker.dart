class RateWorker {
  final String id;
  final String name;
  final String phone;
  final String role;
  final bool alreadyRated;

  RateWorker({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.alreadyRated,
  });

  factory RateWorker.fromJson(Map<String, dynamic> json) {
    return RateWorker(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
      alreadyRated: json['alreadyRated'] ?? false,
    );
  }
}
