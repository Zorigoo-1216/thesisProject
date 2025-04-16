import 'package:flutter/material.dart';
import '../../constant/styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: const Text(
          'Сайн уу Зоригоо',
          style: TextStyle(color: AppColors.text, fontSize: 20),
        ),
        actions: const [
          Icon(Icons.notifications_none, color: AppColors.primary),
          SizedBox(width: AppSpacing.sm),
          Icon(Icons.settings, color: AppColors.primary),
          SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/profile.png'),
          ),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const Text('Эрэлттэй салбарууд', style: AppTextStyles.heading),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _CategoryItem(icon: Icons.apartment, label: 'Барилга'),
              _CategoryItem(icon: Icons.restaurant, label: 'Зоогийн газар'),
              _CategoryItem(icon: Icons.factory, label: 'Үйлдвэр'),
              _CategoryItem(icon: Icons.local_shipping, label: 'Худалдаа'),
              _CategoryItem(icon: Icons.directions_car, label: 'Засвар'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Өндөр үнэлгээтэй ажилчид', style: AppTextStyles.heading),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder:
                  (_, __) => Column(
                    children: const [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/avatar.png'),
                      ),
                      SizedBox(height: 4),
                      Text("Б. Батзориг"),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.orange),
                          Text("4.8"),
                          SizedBox(width: 6),
                          Icon(Icons.favorite, size: 14, color: Colors.red),
                          Text("12"),
                        ],
                      ),
                      SizedBox(width: AppSpacing.xs),
                    ],
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Ажлын зарууд', style: AppTextStyles.heading),
          const SizedBox(height: AppSpacing.sm),

          /// ✅ Job Card
          const _JobCard(),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xs),
        CircleAvatar(
          backgroundColor: AppColors.stateBackground,
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.subtitle.copyWith(fontSize: 12)),
      ],
    );
  }
}

class _JobCard extends StatefulWidget {
  const _JobCard({super.key});

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool applied = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.cardElevation,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Avatar + Info
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
                    children: const [
                      Text("О.Даваанжаргал", style: AppTextStyles.body),
                      Text(
                        "Барилгын туслах ажилтан авна",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text("3 цагийн өмнө", style: AppTextStyles.subtitle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            /// Location
            const Row(
              children: [
                Icon(Icons.location_on, size: 18, color: AppColors.primary),
                SizedBox(width: 6),
                Text("БЗД, Сансар, Жуков, Гүркий хотхон"),
              ],
            ),
            const SizedBox(height: 4),

            /// Salary
            const Row(
              children: [
                Icon(Icons.attach_money, size: 18, color: AppColors.primary),
                SizedBox(width: 6),
                Text("120000₮ / өдөр"),
              ],
            ),
            const SizedBox(height: 4),

            /// Capacity
            const Row(
              children: [
                Icon(Icons.group, size: 18, color: AppColors.primary),
                SizedBox(width: 6),
                Text("Ажиллах хүн: 3"),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            /// Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("7/4", style: AppTextStyles.subtitle),
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
                  child: Text(applied ? "Applied" : "Apply Now"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
