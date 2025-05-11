class Job {
  final String jobId;
  final String title;
  final String employerId;
  final String description;
  final String location;
  final Salary salary;
  final String salaryType;
  final String currency;
  final String jobType;
  final List<String> requirements;
  final String experienceLevel;
  final String status;
  final bool hasInterview;
  final String startDate;
  final String endDate;
  final int capacity;
  final bool possibleForDisabled;
  final String employerName;
  final String postedAgo;
  final bool isApplied;
  final String applicationStatus;
  final String category;
  Job({
    required this.jobId,
    required this.title,
    required this.description,
    required this.location,
    required this.salary,
    required this.salaryType,
    required this.currency,
    required this.jobType,
    required this.requirements,
    required this.experienceLevel,
    required this.status,
    required this.hasInterview,
    required this.startDate,
    required this.endDate,
    required this.capacity,
    required this.possibleForDisabled,
    required this.employerName,
    required this.postedAgo,
    required this.employerId,
    required this.category,
    this.isApplied = false,
    this.applicationStatus = 'none',
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    late Salary salaryData;
    try {
      salaryData = Salary.fromJson(json['salary'] ?? {});
    } catch (_) {
      salaryData = Salary(amount: 0, type: 'daily', currency: 'MNT');
    }

    return Job(
      jobId: json['jobId'] ?? json['_id'] ?? '',
      employerId: json['employerId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      salary: salaryData,
      salaryType: json['salaryType'] ?? 'daily',
      currency: json['currency'] ?? 'MNT',
      jobType: json['jobType'] ?? '',
      requirements: List<String>.from(json['requirements'] ?? []),
      experienceLevel: json['experienceLevel'] ?? 'none',
      status: json['status'] ?? '',
      hasInterview: json['hasInterview'] ?? false,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      capacity: json['capacity'] ?? 0,
      possibleForDisabled: json['possibleForDisabled'] ?? false,
      employerName: json['employerName'] ?? '',
      postedAgo: json['postedAgo'] ?? '',
      isApplied: json['isApplied'] ?? false,
      applicationStatus: json['applicationStatus'] ?? 'none',
      category: json['category'] ?? '',
    );
  }
}

class Salary {
  final int amount;
  final String type;
  final String currency;

  Salary({required this.amount, required this.type, required this.currency});

  String getSalaryFormatted() {
    final typeLabel = {'daily': '/ өдөр', 'hourly': '/ цаг'}[type] ?? '';
    return '$amount₮ $typeLabel';
  }

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      amount: json['amount'] ?? 0,
      type: json['type'] ?? 'daily',
      currency: json['currency'] ?? 'MNT',
    );
  }
}
