import 'package:flutter/material.dart';
import '../../constant/styles.dart';
import '../../widgets/category_item.dart';
import '../../widgets/job_card.dart';
import '../../data/testdata/dummy_jobs.dart';

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
              CategoryItem(icon: Icons.apartment, label: 'Барилга'),
              CategoryItem(icon: Icons.restaurant, label: 'Зоогийн газар'),
              CategoryItem(icon: Icons.factory, label: 'Үйлдвэр'),
              CategoryItem(icon: Icons.local_shipping, label: 'Худалдаа'),
              CategoryItem(icon: Icons.directions_car, label: 'Засвар'),
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
                    ],
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Ажлын зарууд', style: AppTextStyles.heading),
          const SizedBox(height: AppSpacing.sm),
          ...dummyJobs.map((job) => JobCard(job: job)).toList(),
        ],
      ),
    );
  }
}
