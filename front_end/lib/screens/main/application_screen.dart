import 'package:flutter/material.dart';
import '../../constant/styles.dart';
import '../../widgets/job_application_card.dart';

class ApplicationScreen extends StatefulWidget {
  const ApplicationScreen({super.key});

  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> jobs = [
    {
      'title': 'Барилгын туслах',
      'employer': 'О.Эрдэнэцогт',
      'location': 'БЗД, Жуков, Сэнгүр горхи хотхон',
      'salary': '120000₮/өдөр',
      'date': '7/4',
      'time': '1 цагийн өмнө',
      'status': 'Accepted',
      'tags': ['Гэрээ', 'Ажлын явц', 'Цалин', 'Үнэлгээ'],
    },
    {
      'title': 'Барилгын туслах',
      'employer': 'О.Эрдэнэцогт',
      'location': 'БЗД, Жуков, Сэнгүр горхи хотхон',
      'salary': '120000₮/өдөр',
      'date': '7/4',
      'time': '1 цагийн өмнө',
      'status': 'Waiting',
    },
    {
      'title': 'Барилгын туслах',
      'employer': 'О.Эрдэнэцогт',
      'location': 'БЗД, Жуков, Сэнгүр горхи хотхон',
      'salary': '120000₮/өдөр',
      'date': '7/4',
      'time': '1 цагийн өмнө',
      'status': 'Rejected',
    },
  ];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  List<Map<String, dynamic>> getJobsByStatus(String status) {
    return jobs.where((job) => job['status'] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        toolbarHeight: 80,
        // title: const Text(
        //   'Сайн уу Зоригоо',
        //   style: TextStyle(color: AppColors.text, fontSize: 20),
        // ),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.subtitle,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "Waiting"),
            Tab(text: "Accepted"),
            Tab(text: "Rejected"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent("Waiting"),
          _buildTabContent("Accepted"),
          _buildTabContent("Rejected"),
        ],
      ),
    );
  }

  Widget _buildTabContent(String status) {
    final filtered = getJobsByStatus(status);
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final job = filtered[index];
        return JobApplicationCard(job: job); // 👈 call widget here
      },
    );
  }
}
