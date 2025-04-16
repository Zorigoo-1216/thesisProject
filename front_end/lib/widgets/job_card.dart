import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../constant/styles.dart';

class JobCard extends StatefulWidget {
  final Job job;
  const JobCard({super.key, required this.job});

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool applied = false;

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final salaryLabel = job.salary.type == 'daily' ? '/ өдөр' : '/ цаг';

    return Card(
      elevation: AppSpacing.cardElevation,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 Employer Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.employerName, style: AppTextStyles.body),
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(job.postedAgo, style: AppTextStyles.subtitle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // 📍 Location
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(job.location),
              ],
            ),
            const SizedBox(height: 4),

            // 💰 Salary
            Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text('${job.salary.amount}₮ $salaryLabel'),
              ],
            ),
            const SizedBox(height: 4),

            // 👥 Capacity
            Row(
              children: [
                const Icon(Icons.group, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Ажиллах хүн: ${job.capacity}'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ✅ Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${job.startDate} - ${job.endDate}',
                  style: AppTextStyles.subtitle,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      applied = !applied;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        applied ? Colors.grey.shade300 : AppColors.primary,
                    foregroundColor: applied ? AppColors.text : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                    ),
                  ),
                  child: Text(applied ? 'Applied' : 'Apply Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
