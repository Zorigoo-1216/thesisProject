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

  final int? workedHours; // ✅ ажилласан цаг
  final int? workedMinutes; // ✅ ажилласан минут
  final int? salary; // ✅ бодогдсон цалин

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
    this.workedHours,
    this.workedMinutes,
    this.salary,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    int? hours;
    int? minutes;
    int? salaryAmount;

    if (json['startedAt'] != null) {
      final start = DateTime.parse(json['startedAt']);
      final end =
          json['endedAt'] != null
              ? DateTime.parse(json['endedAt'])
              : DateTime.now();
      final diff = end.difference(start);
      hours = diff.inHours;
      minutes = diff.inMinutes.remainder(60);
    }

    if (json['salary'] != null) {
      salaryAmount = (json['salary']['total'] ?? 0).toInt();
    }

    return Worker(
      id: json['workerId']['_id'] ?? 'N/A',
      name:
          "${json['workerId']['lastName'] ?? ''} ${json['workerId']['firstName'] ?? ''}",
      phone: json['workerId']['phone'] ?? 'N/A',
      jobprogressId: json['_id'].toString(),
      rating: (json['workerId']['rating'] ?? 4.0).toDouble(),
      projects: json['workerId']['projects'] ?? 0,
      requestTime: json['createdAt'] ?? '',
      workStartTime: json['startedAt'] ?? '',
      status: json['status'],
      workedHours: hours,
      workedMinutes: minutes,
      salary: salaryAmount,
      selected: false,
    );
  }
}
