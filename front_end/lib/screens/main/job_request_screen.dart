import 'package:flutter/material.dart';
import '../../constant/styles.dart';

class JobRequestScreen extends StatefulWidget {
  final int initialTabIndex;
  const JobRequestScreen({super.key, this.initialTabIndex = 0});

  @override
  State<JobRequestScreen> createState() => _JobRequestScreenState();
}

class _JobRequestScreenState extends State<JobRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isSelecting = false;
  final Set<int> selectedUsers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget buildUserCard(String name, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (isSelecting)
              Checkbox(
                value: selectedUsers.contains(index),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selectedUsers.add(index);
                    } else {
                      selectedUsers.remove(index);
                    }
                  });
                },
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/avatar.png',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.heading),
                  const Text(
                    "Professional title",
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text("4.5", style: TextStyle(fontSize: 14)),
                      Spacer(),
                      Text("PROJECTS", style: AppTextStyles.subtitle),
                      SizedBox(width: 4),
                      Icon(
                        Icons.check_box_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 2),
                      Text("50", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabContent(String tabType) {
    if (tabType != "Боломжит ажилтан") {
      return ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: List.generate(
          3,
          (index) => buildUserCard("Anna Jones", index),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: List.generate(
              5,
              (index) => buildUserCard("Worker $index", index),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child:
              isSelecting
                  ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 🟢 Perform confirmation API logic here
                            setState(() {
                              isSelecting = false;
                              selectedUsers.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radius,
                              ),
                            ),
                          ),
                          child: const Text("Батлах"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              isSelecting = false;
                              selectedUsers.clear();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(AppSpacing.radius),
                              ),
                            ),
                          ),
                          child: const Text("Цуцлах"),
                        ),
                      ),
                    ],
                  )
                  : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSelecting = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                      ),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text("Сонгох"),
                  ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Хүсэлтүүд"),
        actions: const [
          Icon(Icons.notifications_none, color: AppColors.iconColor),
          SizedBox(width: AppSpacing.md),
          Icon(Icons.settings, color: AppColors.iconColor),
          SizedBox(width: AppSpacing.md),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Боломжит ажилтан"),
            Tab(text: "Хүсэлтүүд"),
            Tab(text: "Ярилцлага"),
            Tab(text: "Хүлээж буй"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTabContent("Боломжит ажилтан"),
          buildTabContent("Хүсэлтүүд"),
          buildTabContent("Ярилцлага"),
          buildTabContent("Хүлээж буй"),
        ],
      ),
    );
  }
}
