import 'package:flutter/material.dart';
import '../../../models/job_model.dart';
import '../../../constant/styles.dart';

class CreatedJobCard extends StatelessWidget {
  final Job job;

  const CreatedJobCard({super.key, required this.job});

  final List<Map<String, dynamic>> tagActions = const [
    {'label': 'Боломжит ажилчид', 'route': '/suitable-workers'},
    {'label': 'Гэрээ', 'route': '/job-contract'},
    {'label': 'Ажиллах хүсэлт', 'route': '/job-request'},
    {'label': 'Ярилцлага', 'route': '/interview'},
    {'label': 'Ажилчид', 'route': '/job-employees'},
    {'label': 'Ажлын явц', 'route': '/job-progress'},
    {'label': 'Төлбөр', 'route': '/job-payment'},
    {'label': 'Үнэлгээ', 'route': '/rate-employee'},
    {'label': 'Гэрээ байгуулах ажилчид', 'route': '/contract-candidates'},
    {'label': 'Гэрээний явц', 'route': 'contract-employees'},
  ];
  String getSalaryFormatted(int amount, String type) {
    final typeLabel = {'daily': '/ өдөр', 'hourly': '/ цаг'}[type] ?? '';
    return '$amount₮ $typeLabel';
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
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit-job', arguments: job);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.iconColor),
                  onPressed: () {
                    // TODO: show confirmation dialog
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            _iconRow(
              Icons.calendar_month_outlined,
              '${job.startDate} - ${job.endDate}',
            ),
            _iconRow(Icons.location_on_outlined, job.location),
            _iconRow(
              Icons.attach_money,
              getSalaryFormatted(job.salary.amount, job.salaryType),
            ),
            const SizedBox(height: AppSpacing.sm),

            /// Interactive Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tagActions.map((tag) => _tag(context, tag)).toList(),
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

  Widget _tag(BuildContext context, Map<String, dynamic> tag) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, tag['route'], arguments: job.jobId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.tagColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tag['label'],
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
