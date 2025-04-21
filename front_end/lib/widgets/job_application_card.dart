import 'package:flutter/material.dart';
import '../constant/styles.dart';

class JobApplicationCard extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobApplicationCard({super.key, required this.job});

  Color _statusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.blue;
      case "waiting":
        return Colors.orange;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatSalary(dynamic salary) {
    try {
      if (salary is String) return salary;
      if (salary is Map<String, dynamic>) {
        final int amount = salary['amount'] ?? 0;
        final String type = salary['type'] ?? 'өдөр';
        return "$amount₮/${type == 'hourly' ? 'цаг' : 'өдөр'}";
      }
    } catch (_) {}
    return 'Цалингүй';
  }

  @override
  Widget build(BuildContext context) {
    final String status =
        job['applicationStatus']?.toString().toLowerCase() ?? 'pending';

    final List<String> tags =
        job['tags'] is List && (job['tags'] as List).isNotEmpty
            ? (job['tags'] as List<dynamic>).map((e) => e.toString()).toList()
            : (status == 'accepted'
                ? ['Гэрээ', 'Ажлын явц', 'Цалин', 'Үнэлгээ']
                : []);
    final String employer =
        job['employer']?.toString() ??
        job['employerName']?.toString() ??
        'Ажил олгогч';

    final String title = job['title']?.toString() ?? 'Ажлын нэр';
    final String time = job['time']?.toString() ?? '';
    final String location = job['location']?.toString() ?? 'Байршилгүй';
    final String date = job['date']?.toString() ?? '';
    final String salary = _formatSalary(job['salary']);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      elevation: AppSpacing.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.body,
                      children: [
                        TextSpan(
                          text: '$employer\n',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: title),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Time
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(time, style: AppTextStyles.subtitle),
              ],
            ),
            const SizedBox(height: 8),

            /// Location
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(child: Text(location, style: AppTextStyles.subtitle)),
              ],
            ),
            const SizedBox(height: 4),

            /// Salary
            Row(
              children: [
                const Icon(Icons.attach_money, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(salary, style: AppTextStyles.subtitle),
              ],
            ),
            const SizedBox(height: 4),

            /// Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(date, style: AppTextStyles.subtitle),
              ],
            ),
            const SizedBox(height: 10),

            /// Tags
            if (status == 'accepted' && tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: -4,
                children: tags.map((tag) => _tagChip(context, tag)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(BuildContext context, String label) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case "Гэрээ":
            Navigator.pushNamed(
              context,
              '/employee-contract',
              arguments: {'jobId': job['jobId']},
            );
            break;
          case "Ажлын явц":
            Navigator.pushNamed(
              context,
              '/employee-progress',
              arguments: job['jobId'],
            );
            break;
          case "Цалин":
            Navigator.pushNamed(
              context,
              '/employee-payment',
              arguments: job['jobId'],
            );
            break;
          case "Үнэлгээ":
            Navigator.pushNamed(
              context,
              '/employer-rate',
              arguments: job['jobId'],
            );
            break;
          default:
            break;
        }
      },
      child: Chip(
        label: Text(label),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: const TextStyle(color: Colors.white),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return "Зөвшөөрсөн";
      case "rejected":
        return "Татгалзсан";
      case "pending":
      case "waiting":
        return "Хүлээгдэж буй";
      default:
        return "Тодорхойгүй";
    }
  }
}
