//import 'dart:math' as console;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constant/styles.dart';
import '../../constant/api.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? user;
  bool isLoading = true;

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
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("Token not found");
      return;
    }

    final response = await http.get(
      Uri.parse('${baseUrl}auth/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("Status code: ${response.statusCode}");
    print("Raw body: ${response.body}");

    try {
      final data = jsonDecode(response.body); // This must be a Map
      print("Decoded type: ${data.runtimeType}"); // <-- must be Map

      setState(() {
        user = UserModel.fromJson(
          data,
        ); // <- only works if data is Map<String, dynamic>
        isLoading = false;
      });
    } catch (e) {
      print("Error parsing response: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                CustomSliverAppBar(
                  tabController: _tabController,
                  showTabs: true,
                  showBack: true,
                ),
                SliverToBoxAdapter(
                  child:
                      isLoading
                          ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : user == null
                          ? const Center(child: Text("Алдаа гарлаа"))
                          : Column(
                            children: [
                              ProfileInfo(user: user!),
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
    return const Center(
      child: Text("\ud83d\uddd3\ufe0f Ажлын хуваарь энд гарна."),
    );
  }

  Widget _ratingTab() {
    return Center(
      child:
          user == null
              ? const Text(
                "\u04ae\u043d\u044d\u043b\u0433\u044d\u044d \u043e\u043b\u0434\u0441\u043e\u043d\u0433\u04af\u0439",
              )
              : Text(
                "\u2b50 \u04ae\u043d\u044d\u043b\u0433\u044d\u044d: ${user!.averageRating.overall}",
              ),
    );
  }
}

class ProfileInfo extends StatelessWidget {
  final UserModel user;
  const ProfileInfo({super.key, required this.user});

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
          Text(user.name, style: AppTextStyles.heading),
          Text(
            user.profile?.mainBranch ?? 'Салбар тодорхойгүй',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _infoCard("RATING", "${user.averageRating.overall}", Icons.star),
              const SizedBox(width: 12),
              _infoCard("ROLE", user.role, Icons.person),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Email", style: AppTextStyles.subtitle),
          Text(user.email ?? "-"),
          const SizedBox(height: 6),
          const Text("Phone", style: AppTextStyles.subtitle),
          Text(user.phone ?? "-", textAlign: TextAlign.center),
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
