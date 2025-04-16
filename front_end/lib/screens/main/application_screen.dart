import 'package:flutter/material.dart';
import '../../constant/styles.dart';

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
        return _JobApplicationCard(job: job);
      },
    );
  }
}

class _JobApplicationCard extends StatelessWidget {
  final Map<String, dynamic> job;

  const _JobApplicationCard({required this.job});

  Color _statusColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.blue;
      case "Waiting":
        return Colors.orange;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      elevation: AppSpacing.cardElevation,
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
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.body,
                      children: [
                        TextSpan(
                          text: '${job['employer']}\n',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: job['title']),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(job['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job['status'],
                    style: TextStyle(
                      color: _statusColor(job['status']),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more),
              ],
            ),
            const SizedBox(height: 8),

            // Time & Info
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(job['time'], style: AppTextStyles.subtitle),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(job['location'], style: AppTextStyles.subtitle),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(job['salary'], style: AppTextStyles.subtitle),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(job['date'], style: AppTextStyles.subtitle),
              ],
            ),
            const SizedBox(height: 10),

            // Tags (if accepted)
            if (job['status'] == 'Accepted' && job['tags'] != null)
              Wrap(
                spacing: 8,
                children:
                    (job['tags'] as List<String>).map((tag) {
                      return GestureDetector(
                        onTap: () {
                          switch (tag) {
                            case "Гэрээ":
                              Navigator.pushNamed(
                                context,
                                '/employee-contract',
                              );
                              break;
                            case "Ажлын явц":
                              Navigator.pushNamed(
                                context,
                                '/employee-progress',
                              );
                              break;
                            case "Цалин":
                              Navigator.pushNamed(context, '/employee-payment');
                              break;
                            case "Үнэлгээ":
                              Navigator.pushNamed(context, '/employer-rate');
                              break;
                            default:
                              break;
                          }
                        },
                        child: Chip(
                          label: Text(tag),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          labelStyle: const TextStyle(color: Colors.white),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
