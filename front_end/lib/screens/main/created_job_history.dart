import 'package:flutter/material.dart';
import '../../constant/styles.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class CreatedJobHistoryScreen extends StatelessWidget {
  const CreatedJobHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMainTab = ModalRoute.of(context)?.isFirst ?? false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            showTabs: false,
            showBack: !isMainTab, // ✅ зөвхөн stack navigation үед харагдана
            tabs: const [],
          ),
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
                  const Text("Full name", style: AppTextStyles.heading),
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
                  const Text("mike.williams@gmail.com"),
                  const Text("Call: (+1) 202-555-0151"),
                  const SizedBox(height: AppSpacing.lg),
                  _jobCard(
                    title: "Барилгын туслах",
                    salary: "85000₮",
                    dateRange: "2025:12:16 - 2025:12:20",
                    location: "БЗД, Жуков, Сэнгүр горхи хотхон",
                    pay: "120000₮/өдөр",
                    applicants: "7/4",
                  ),
                  _jobCard(
                    title: "Барилгын туслах",
                    salary: "85000₮",
                    dateRange: "2025:12:16 - 2025:12:20",
                    location: "БЗД, Жуков, Сэнгүр горхи хотхон",
                    pay: "120000₮/өдөр",
                    applicants: "7/4",
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    required String salary,
    required String dateRange,
    required String location,
    required String pay,
    required String applicants,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateRange,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  salary,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.iconColor,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(location, style: AppTextStyles.body)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: AppColors.iconColor,
                ),
                const SizedBox(width: 6),
                Text(pay, style: AppTextStyles.body),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 18,
                  color: AppColors.iconColor,
                ),
                const SizedBox(width: 6),
                Text(applicants, style: AppTextStyles.body),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
