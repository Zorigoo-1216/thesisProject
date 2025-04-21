class Worker {
  final String id;
  final String name;
  final String phone;
  final double rating;
  final int projects;
  final String requestTime;
  final String workStartTime;
  final String jobprogressId;
  String status;
  bool selected;

  Worker({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.projects,
    required this.requestTime,
    required this.jobprogressId,
    required this.workStartTime,
    required this.status,
    this.selected = false,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['workerId']['_id'] ?? 'N/A',
      name:
          "${json['workerId']['lastName'] ?? ''} ${json['workerId']['firstName'] ?? ''}", // ✅ овог, нэр нэгтгэсэн
      phone: json['workerId']['phone'] ?? 'N/A',
      jobprogressId: json['_id'].toString(),
      rating: (json['workerId']['rating'] ?? 4.0).toDouble(),
      projects: json['workerId']['projects'] ?? 0,
      requestTime: json['createdAt'] ?? '',
      workStartTime: json['startedAt'] ?? '',
      status: json['status'],
      selected: false,
    );
  }
}
