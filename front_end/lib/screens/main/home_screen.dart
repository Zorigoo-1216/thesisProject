import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/styles.dart';
import '../../widgets/category_item.dart';
//import '../../widgets/job_card.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    print('🔥 Ачаалсан нэр: $name');

    // ✂️ Нэрийг задалж, эхний үгийг авах
    final firstName = (name ?? 'Хэрэглэгч').split(RegExp(r'\s+')).first;

    setState(() {
      userName = firstName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(showTabs: true, showBack: false),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Сайн уу $userName 👋', style: AppTextStyles.heading),
                  const SizedBox(height: AppSpacing.lg),

                  // 💼 Эрэлттэй салбарууд
                  const Text(
                    'Эрэлттэй салбарууд',
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: const [
                        CategoryItem(icon: Icons.apartment, label: 'Барилга'),
                        SizedBox(width: 8),
                        CategoryItem(
                          icon: Icons.restaurant,
                          label: 'Зоогийн газар',
                        ),
                        SizedBox(width: 8),
                        CategoryItem(icon: Icons.factory, label: 'Үйлдвэр'),
                        SizedBox(width: 8),
                        CategoryItem(
                          icon: Icons.local_shipping,
                          label: 'Худалдаа',
                        ),
                        SizedBox(width: 8),
                        CategoryItem(
                          icon: Icons.directions_car,
                          label: 'Засвар',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 👷 Өндөр үнэлгээтэй ажилчид
                  const Text(
                    'Өндөр үнэлгээтэй ажилчид',
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      separatorBuilder:
                          (_, __) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder:
                          (_, __) => Column(
                            children: const [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(
                                  'assets/images/avatar.png',
                                ),
                              ),
                              SizedBox(height: 4),
                              Text("Б. Батзориг"),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.orange,
                                  ),
                                  Text("4.8"),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.favorite,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  Text("12"),
                                ],
                              ),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 📋 Ажлын зарууд
                  const Text('Ажлын зарууд', style: AppTextStyles.heading),
                  const SizedBox(height: AppSpacing.sm),
                  //...dummyJobs.map((job) => JobCard(job: job)).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
