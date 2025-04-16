import 'package:flutter/material.dart';
import '../../constant/styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Хувийн мэдээлэл", "route": "/profile-detail"},
    {"title": "Хийсэн ажлын түүх", "route": "/job-history"},
    {"title": "Үүсгэсэн ажлын түүх", "route": "/created-job-history"},
    {"title": "Илгээсэн хүсэлтийн түүх", "route": "/sent-application-history"},
    {"title": "Гэрээний түүх", "route": "/contract-history"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: AppColors.background,
                  leading: const BackButton(color: AppColors.text),
                  actions: const [
                    Icon(Icons.notifications_none, color: AppColors.iconColor),
                    SizedBox(width: 12),
                    Icon(Icons.settings, color: AppColors.text),
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: AssetImage('assets/images/avatar.png'),
                    ),
                    SizedBox(width: 12),
                  ],
                  bottom: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: "Үндсэн"),
                      Tab(text: "Хуваарь"),
                      Tab(text: "Үнэлгээ"),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const ProfileInfo(),
                      const Divider(thickness: 1, color: Colors.grey),
                    ],
                  ),
                ),
              ],
          body: TabBarView(
            controller: _tabController,
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return MainTabListItem(
                    title: item['title'],
                    route: item['route'],
                  );
                },
              ),
              _scheduleTab(),
              _ratingTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scheduleTab() {
    return const Center(child: Text("📆 Ажлын хуваарь энд гарна."));
  }

  Widget _ratingTab() {
    return const Center(child: Text("⭐ Үнэлгээний дэлгэрэнгүй энд гарна."));
  }
}

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/avatar.png'),
          ),
          const SizedBox(height: 8),
          const Text("Full name", style: AppTextStyles.heading),
          const Text("Барилгын инженер", style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _infoCard("RATING", "4.5", Icons.star),
              const SizedBox(width: 12),
              _infoCard("PROJECTS", "50", Icons.work),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Email", style: AppTextStyles.subtitle),
          const Text("mike.williams@gmail.com"),
          const SizedBox(height: 6),
          const Text("Phone", style: AppTextStyles.subtitle),
          const Text("Call: (+1)\n202-555-0151", textAlign: TextAlign.center),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  static Widget _infoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.stateBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.subtitle),
          Row(
            children: [
              Text(value, style: AppTextStyles.body),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}

class MainTabListItem extends StatelessWidget {
  final String title;
  final String route;

  const MainTabListItem({super.key, required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: const CircleAvatar(
        backgroundColor: AppColors.stateBackground,
        child: Icon(Icons.account_circle, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyles.body),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
