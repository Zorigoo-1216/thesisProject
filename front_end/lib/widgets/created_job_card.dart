import 'package:flutter/material.dart';
import '../../../models/job_model.dart';
import '../../../constant/styles.dart';

class CreatedJobCard extends StatelessWidget {
  final Job job;

  const CreatedJobCard({super.key, required this.job});

  String getSalaryFormatted(Salary salary) {
    final typeLabel = {'daily': '/ өдөр', 'hourly': '/ цаг'}[salary.type] ?? '';
    return '${salary.amount}₮ $typeLabel';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.cardElevation,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title + actions
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.iconColor),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.iconColor),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            _iconRow(
              Icons.calendar_month_outlined,
              '${job.startDate} - ${job.endDate}',
            ),
            _iconRow(Icons.location_on_outlined, job.location),
            _iconRow(Icons.attach_money, getSalaryFormatted(job.salary)),
            const SizedBox(height: AppSpacing.sm),

            /// Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: job.tags.map((tag) => _tag(context, tag)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.iconColor),
          const SizedBox(width: AppSpacing.xs),
          Text(text, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, String label) {
    return GestureDetector(
      onTap: () {
        // navigation switch-case...
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.tagColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
