import 'package:flutter/material.dart';
import '../../constant/styles.dart';
import '../../widgets/job_application_card.dart';
import '../../widgets/custom_sliver_app_bar.dart';

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
      body: DefaultTabController(
        length: 3,
        child: CustomScrollView(
          slivers: [
            CustomSliverAppBar(
              showTabs: true,
              showBack: true,
              tabController: _tabController,
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent("Waiting"),
                  _buildTabContent("Accepted"),
                  _buildTabContent("Rejected"),
                ],
              ),
            ),
          ],
        ),
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
