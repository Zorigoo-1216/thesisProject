import 'package:flutter/material.dart';
import '../../constant/styles.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class SentApplicationHistoryScreen extends StatelessWidget {
  const SentApplicationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMainTab = ModalRoute.of(context)?.isFirst ?? false;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(showBack: true, showTabs: !isMainTab, tabs: []),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // Profile Info
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

                  // Application Cards
                  _applicationCard(status: "Closed"),
                  _applicationCard(status: "Closed"),
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

  static Widget _applicationCard({required String status}) {
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
            // Header Row
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("О.Эрдэнэцогт", style: AppTextStyles.body),
                      Text("Барилгын туслах", style: AppTextStyles.heading),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
            const SizedBox(height: 12),

            // Job Info
            Row(
              children: const [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.iconColor,
                ),
                SizedBox(width: 6),
                Text("БЗД, Жуков, Сэнгүр горхи хотхон"),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: const [
                Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: AppColors.iconColor,
                ),
                SizedBox(width: 6),
                Text("120000₮/өдөр"),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: const [
                Icon(
                  Icons.people_outline,
                  size: 18,
                  color: AppColors.iconColor,
                ),
                SizedBox(width: 6),
                Text("7/4"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
