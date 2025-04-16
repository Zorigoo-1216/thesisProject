import 'package:flutter/material.dart';
import '../../constant/styles.dart';

class JobContractScreen extends StatefulWidget {
  final int initialTabIndex;
  const JobContractScreen({super.key, this.initialTabIndex = 0});

  @override
  State<JobContractScreen> createState() => _JobContractScreenState();
}

class _JobContractScreenState extends State<JobContractScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedContractIndex = -1;

  final List<String> names = [
    "Brandon Taylor",
    "Anna Hunt",
    "Caleb Jones",
    "Nathan Wood",
    "John Clark",
  ];

  final List<String> summaries = [
    "Хөдөлмөрийн гэрээ",
    "Хөлсөөр ажиллуулах гэрээ",
    "",
    "",
    "",
  ];

  final List<String> phones = ["", "98451216", "", "", ""];

  final List<String> subtitles = [
    "",
    "Гэрээний хураангуй: Lorem ipsum...",
    "Elit ut qui duis conse",
    "Molilt fugiat nostrud",
    "Et ipsum cillum amet",
  ];

  late List<String> statuses;

  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    statuses = List.generate(names.length, (_) => 'Send');
    super.initState();
  }

  void _showContractDetailSheet(String contractTitle, String summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DefaultTabController(
          length: 2,
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SizedBox(
              height: 500,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    tabs: [Tab(text: "Гэрээ"), Tab(text: "Гэрээний хураангуй")],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(summary, style: AppTextStyles.body),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(summary * 2, style: AppTextStyles.body),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Татгалзах"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Батлах"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContractTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _contractItem(
                0,
                "Хөдөлмөрийн гэрээ",
                "Brief description of contract template 1.",
              ),
              const SizedBox(width: 12),
              _contractItem(
                1,
                "Хөлсөөр ажиллуулах гэрээ",
                "Brief description of contract template 2.",
              ),
            ],
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload),
            label: const Text("Өөрийн гэрээг оруулах"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contractItem(int index, String title, String desc) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              onPressed: () {
                setState(() => selectedContractIndex = index);
                _showContractDetailSheet(title, desc);
              },
              child: const Text("Select"),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      case "Pending":
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildEmployeesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: names.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          child: ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
            title: Text(
              names[index],
              style: AppTextStyles.heading.copyWith(fontSize: 16),
            ),
            subtitle: Text(summaries[index], style: AppTextStyles.subtitle),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Send contract action
                setState(() {
                  statuses[index] = "Sent"; // You can modify if needed
                });
              },
              child: const Text("Send"),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Гэрээний удирдлага"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "Гэрээний загвар"),
            Tab(text: "Ажилчдын гэрээ"),
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
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildContractTab(), _buildEmployeesTab()],
      ),
    );
  }
}
