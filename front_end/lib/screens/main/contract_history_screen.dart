import 'package:flutter/material.dart';
import '../../constant/styles.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class ContractHistoryScreen extends StatelessWidget {
  const ContractHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(showTabs: false, showBack: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  const _ProfileHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  _contractCard(
                    jobTitle: "Барилгын туслах",
                    employerName: "О.Эрдэнэцогт",
                    location: "БЗД, Жуков, Сэнгүр хотхон",
                    salary: "120000₮/өдөр",
                    date: "2025:12:16 - 2025:12:20",
                  ),
                  _contractCard(
                    jobTitle: "Барилгын туслах",
                    employerName: "О.Эрдэнэцогт",
                    location: "СХД, 6-р хороо, Драгон",
                    salary: "100000₮/өдөр",
                    date: "2025:11:10 - 2025:11:15",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contractCard({
    required String jobTitle,
    required String employerName,
    required String location,
    required String salary,
    required String date,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(jobTitle, style: AppTextStyles.heading),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.iconColor),
                const SizedBox(width: 6),
                Text(employerName),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 16,
                  color: AppColors.iconColor,
                ),
                const SizedBox(width: 6),
                Text(date, style: const TextStyle(color: Colors.green)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.iconColor,
                ),
                const SizedBox(width: 6),
                Text(location),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.attach_money,
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
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
      ],
    );
  }

  Widget _infoBox(String label, String value, IconData icon) {
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
}
