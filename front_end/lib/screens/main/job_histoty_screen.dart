import 'package:flutter/material.dart';
import '../../constant/styles.dart';
import '../../widgets/custom_sliver_app_bar.dart'; // ← CustomSliverAppBar-ийн замаа зөв заана уу

class JobHistoryScreen extends StatelessWidget {
  const JobHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMainTab = ModalRoute.of(context)?.isFirst ?? false;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(showTabs: false, showBack: !isMainTab),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text("О.Эрдэнэцогт", style: AppTextStyles.heading),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _infoBox("RATING", "4.5", Icons.star),
                      const SizedBox(width: 12),
                      _infoBox("PROJECTS", "50", Icons.work_outline),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text("erdenetsogt@email.com"),
                  const Text("Утас: 8888-8888"),
                  const SizedBox(height: AppSpacing.lg),

                  // ✅ Job History Cards
                  _jobCard(
                    title: "Барилгын туслах",
                    startDate: "2025.12.16",
                    endDate: "2025.12.20",
                    employerName: "Г.Цолмон",
                    salary: "120000₮ / өдөр",
                  ),
                  _jobCard(
                    title: "Зөөврийн ажилтан",
                    startDate: "2025.10.05",
                    endDate: "2025.10.08",
                    employerName: "С.Батмөнх",
                    salary: "100000₮ / өдөр",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.stateBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.subtitle),
              Text(value, style: AppTextStyles.body),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _jobCard({
    required String title,
    required String startDate,
    required String endDate,
    required String employerName,
    required String salary,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.heading.copyWith(fontSize: 16)),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 16,
                  color: AppColors.iconColor,
                ),
                const SizedBox(width: 6),
                Text(
                  "$startDate - $endDate",
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.iconColor,
                ),
                const SizedBox(width: 6),
                Text(employerName),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 16,
                  color: AppColors.iconColor,
                ),
                const SizedBox(width: 6),
                Text(salary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
