import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:front_end/constant/styles.dart';
import 'package:front_end/widgets/create_job_tab.dart';
import 'package:front_end/widgets/custom_sliver_app_bar.dart';
import 'package:front_end/models/job_model.dart';
import '../../constant/api.dart';

class EmployerScreen extends StatefulWidget {
  const EmployerScreen({super.key});

  @override
  State<EmployerScreen> createState() => _EmployerScreenState();
}

class _EmployerScreenState extends State<EmployerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Using Future<List<Job>> to fetch asynchronously
  late Future<List<Job>> _jobs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _jobs =
        fetchMyPostedJobs(); // Fetch the jobs when the screen is initialized
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Хуудас руу орох бүрт шинэчлэх
    setState(() {
      _jobs = fetchMyPostedJobs();
    });
  }

  // Fetch jobs asynchronously from API
  Future<List<Job>> fetchMyPostedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('${baseUrl}jobs/postedJobs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      //print('API Response: ${response.body}');
      final data = jsonDecode(response.body);
      final jobsData = data['jobs'];
      //print(jobsData);
      //print(data);
      // Шалгаж байна: jobs нь List эсэхийг
      if (jobsData is List) {
        return jobsData.map((job) => Job.fromJson(job)).toList();
      } else {
        throw Exception("Invalid jobs data format: ${jobsData.runtimeType}");
      }
    } else {
      throw Exception(
        'Failed to load jobs: ${response.statusCode} - ${response.body}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //final bool isMainTab = ModalRoute.of(context)?.isFirst ?? false;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(showTabs: false, showBack: false, tabs: []),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(_tabController),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CreatedJobsTab(
                  futureJobs: _jobs,
                ), // Pass Future to _CreatedJobsTab
                const CreateJobTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController controller;

  _TabBarDelegate(this.controller);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: controller,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: "Үүсгэсэн ажлууд"),
          Tab(text: "Ажлын зар үүсгэх"),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;
  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _CreatedJobsTab extends StatelessWidget {
  final Future<List<Job>> futureJobs;

  const _CreatedJobsTab({required this.futureJobs});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Job>>(
      future: futureJobs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Одоогоор зарлагдсан ажил байхгүй'));
        } else {
          final jobs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return CreatedJobCard(
                job: job,
              ); // Pass the Job object to CreatedJobCard widget
            },
          );
        }
      },
    );
  }
}

class CreatedJobCard extends StatelessWidget {
  final Job job;

  const CreatedJobCard({super.key, required this.job});

  final List<Map<String, dynamic>> tagActions = const [
    {'label': 'Боломжит ажилчид', 'route': '/suitable-workers'},
    {'label': 'Гэрээ', 'route': '/job-contract'},
    {'label': 'Ажиллах хүсэлт', 'route': '/job-request'},
    {'label': 'Ярилцлага', 'route': '/interview'},
    {'label': 'Ажилчид', 'route': '/job-employees'},
    {'label': 'Ажлын явц', 'route': '/job-progress'},
    {'label': 'Төлбөр', 'route': '/job-payment'},
    {'label': 'Үнэлгээ', 'route': '/rate-employee'},
    {'label': 'Гэрээ байгуулах ажилчид', 'route': '/contract-candidates'},
    {'label': 'Гэрээний явц', 'route': '/contract-employees'},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.cardElevation,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.iconColor),
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit-job', arguments: job);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.iconColor),
                  onPressed: () {
                    // TODO: show confirmation dialog
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            _iconRow(
              Icons.calendar_month_outlined,
              '${job.startDate} - ${job.endDate}',
            ),
            _iconRow(Icons.location_on_outlined, job.location),
            _iconRow(Icons.attach_money, job.salary.getSalaryFormatted()),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tagActions.map((tag) => _tag(context, tag)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.iconColor),
          const SizedBox(width: AppSpacing.xs),
          Text(text, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, Map<String, dynamic> tag) {
    return GestureDetector(
      onTap: () {
        debugPrint('📦 Navigating to ${tag['route']} with jobId: ${job.jobId}');
        Navigator.pushNamed(
          context,
          tag['route'], // ✅ Dynamic route
          arguments: {
            'jobId': job.jobId,
            'hasInterview': job.hasInterview,
          }, // ✅ Required for target screens
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.tagColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tag['label'],
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
