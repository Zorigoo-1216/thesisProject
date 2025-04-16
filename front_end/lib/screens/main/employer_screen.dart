import 'package:flutter/material.dart';
import 'package:front_end/widgets/create_job_tab.dart';
import '../../constant/styles.dart';

class EmployerScreen extends StatefulWidget {
  const EmployerScreen({super.key});

  @override
  State<EmployerScreen> createState() => _EmployerScreenState();
}

class _EmployerScreenState extends State<EmployerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ажлын зар"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepPurple,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Үүсгэсэн ажлууд"),
            Tab(text: "Ажлын зар үүсгэх"),
          ],
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
      body: TabBarView(
        controller: _tabController,
        children: [_CreatedJobsTab(), CreateJobTab()],
      ),
    );
  }
}

class _CreatedJobsTab extends StatelessWidget {
  const _CreatedJobsTab();

  final List<Map<String, dynamic>> jobList = const [
    {
      "title": "Барилгын туслах ажилтан авна",
      "location": "БЗД, Жуков, Сансрын гүүрийн хойно",
      "salary": "120000₮ / өдөр",
      "date": "2025-01-01 to 2025-01-02",
      "tags": [
        "Боломжит ажилтан",
        "Гэрээ",
        "Ажиллах хүсэлт",
        "Ярилцлага",
        "Гэрээ байгуулах ажилчид",
        "Ажлын явц",
        "Ажилчид",
        "Төлбөр",
        "Үнэлгээ",
      ],
    },
    // ... other jobs
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: jobList.length,
      itemBuilder: (context, index) {
        final job = jobList[index];
        return Card(
          elevation: AppSpacing.cardElevation,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.iconColor),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: AppColors.iconColor,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                _iconRow(Icons.calendar_month_outlined, job['date']),
                _iconRow(Icons.location_on_outlined, job['location']),
                _iconRow(Icons.attach_money, job['salary']),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 6,
                  runSpacing: -6,
                  children:
                      job['tags']
                          .map<Widget>((label) => _tag(context, label))
                          .toList(),
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _tag(BuildContext context, String label) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case "Боломжит ажилтан":
            Navigator.pushNamed(context, '/suitable-workers');
            break;
          case "Ажиллах хүсэлт":
            Navigator.pushNamed(context, '/job-request');
            break;
          case "Ярилцлага":
            Navigator.pushNamed(context, '/interview');
            break;
          case "Хүлээж буй":
            Navigator.pushNamed(context, '/contract-candidates');
            break;

          case "Гэрээ":
            Navigator.pushNamed(context, '/job-contract');
            break;
          case "Гэрээ байгуулах ажилчид":
            Navigator.pushNamed(context, '/contract-employees');
            break;

          case "Ажлын явц":
            Navigator.pushNamed(context, '/job-progress');
            break;
          case "Ажилчид":
            Navigator.pushNamed(context, '/job-employees');
            break;
          case "Төлбөр":
            Navigator.pushNamed(context, '/job-payment');
            break;
          case "Үнэлгээ":
            Navigator.pushNamed(context, '/rate-employee');
            break;
          default:
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(top: 6, right: 6),
        decoration: BoxDecoration(
          color: AppColors.tagColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
