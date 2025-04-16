class Worker {
  final String name;
  final String phone;
  final double rating;
  final int projects;
  final String requestTime;
  final String workStartTime;
  String status;
  bool selected;

  Worker({
    required this.name,
    required this.phone,
    required this.rating,
    required this.projects,
    required this.requestTime,
    required this.workStartTime,
    required this.status,
    this.selected = false,
  });
}
