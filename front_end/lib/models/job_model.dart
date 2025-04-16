class Job {
  final String id;
  final String title;
  final List<String> description;
  final List<String> requirements;
  final String location;
  final Salary salary;
  final String seeker;
  final int capacity;
  final String branch;
  final String jobType;
  final String level;
  final bool possibleForDisabled;
  final String status;
  final String startDate;
  final String endDate;
  final String workStartTime;
  final String workEndTime;
  final String? breakStartTime;
  final String? breakEndTime;
  final bool haveInterview;
  final String employerName;
  final String postedAgo;
  final List<String> tags;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.requirements,
    required this.location,
    required this.salary,
    required this.seeker,
    required this.capacity,
    required this.branch,
    required this.jobType,
    required this.level,
    required this.possibleForDisabled,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.workStartTime,
    required this.workEndTime,
    this.breakStartTime,
    this.breakEndTime,
    required this.haveInterview,
    required this.employerName,
    required this.postedAgo,
    required this.tags,
  });
}

class Salary {
  final int amount;
  final String currency;
  final String type;

  Salary({required this.amount, required this.currency, required this.type});
}
