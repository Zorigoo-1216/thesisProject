import 'package:flutter/material.dart';
import '../constant/styles.dart';

class JobApplicationCard extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobApplicationCard({super.key, required this.job});

  Color _statusColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.blue;
      case "Waiting":
        return Colors.orange;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = job['status'] ?? 'Waiting';
    final tags = job['tags'] as List<String>?;

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
            // 👤 Header
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
                          text: '${job['employer']}\n',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: job['title']),
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
                    status,
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

            // 🕒 Time
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(job['time'] ?? '', style: AppTextStyles.subtitle),
              ],
            ),
            const SizedBox(height: 8),

            // 📍 Location
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job['location'] ?? '',
                    style: AppTextStyles.subtitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // 💰 Salary
            Row(
              children: [
                const Icon(Icons.attach_money, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(job['salary'] ?? '', style: AppTextStyles.subtitle),
              ],
            ),
            const SizedBox(height: 4),

            // 📅 Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(job['date'] ?? '', style: AppTextStyles.subtitle),
              ],
            ),
            const SizedBox(height: 10),

            // 🏷 Tags
            if (status == 'Accepted' && tags != null)
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
            Navigator.pushNamed(context, '/employee-contract');
            break;
          case "Ажлын явц":
            Navigator.pushNamed(context, '/employee-progress');
            break;
          case "Цалин":
            Navigator.pushNamed(context, '/employee-payment');
            break;
          case "Үнэлгээ":
            Navigator.pushNamed(context, '/employer-rate');
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
}
