import 'package:flutter/material.dart';
import '../../constant/styles.dart';
import '../../widgets/job_request_card.dart';

class JobRequestScreen extends StatefulWidget {
  final int initialTabIndex;

  const JobRequestScreen({super.key, required this.initialTabIndex});

  @override
  State<JobRequestScreen> createState() => _JobRequestScreenState();
}

class _JobRequestScreenState extends State<JobRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isSelecting = false;

  final Map<String, List<String>> tabData = {
    "Боломжит ажилтан": ["Worker A", "Worker B"],
    "Хүсэлтүүд": ["Anna", "John", "Sara"],
    "Ярилцлага": ["Interviewee A", "Interviewee B"],
    "Хүлээж буй": ["Pending A"],
  };

  final Set<String> selectedUsers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  List<String> getCurrentTabData() {
    final tabName = getCurrentTabName();
    return tabData[tabName] ?? [];
  }

  String getCurrentTabName() {
    return [
      "Боломжит ажилтан",
      "Хүсэлтүүд",
      "Ярилцлага",
      "Хүлээж буй",
    ][_tabController.index];
  }

  void confirmSelection() {
    final current = getCurrentTabName();
    final nextTab =
        _tabController.index + 1 < 4
            ? [
              "Боломжит ажилтан",
              "Хүсэлтүүд",
              "Ярилцлага",
              "Хүлээж буй",
            ][_tabController.index + 1]
            : null;

    if (nextTab != null) {
      setState(() {
        tabData[current]?.removeWhere((name) => selectedUsers.contains(name));
        tabData[nextTab]?.addAll(selectedUsers);
        selectedUsers.clear();
        isSelecting = false;
      });
    }
  }

  Widget buildUserCard(String name) {
    return JobRequestCard(
      name: name,
      showCheckbox: isSelecting,
      checked: selectedUsers.contains(name),
      onChanged: (val) {
        setState(() {
          if (val) {
            selectedUsers.add(name);
          } else {
            selectedUsers.remove(name);
          }
        });
      },
    );
  }

  Widget buildTabContent() {
    final tabName = getCurrentTabName();
    final items = getCurrentTabData();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: items.map(buildUserCard).toList(),
          ),
        ),
        if (tabName == "Хүсэлтүүд" || tabName == "Ярилцлага")
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child:
                isSelecting
                    ? Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: confirmSelection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
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
                            ),
                            child: const Text("Буцах"),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Боломжит ажилтан"),
            Tab(text: "Хүсэлтүүд"),
            Tab(text: "Ярилцлага"),
            Tab(text: "Хүлээж буй"),
          ],
          onTap: (_) {
            setState(() {
              isSelecting = false;
              selectedUsers.clear();
            });
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(4, (_) => buildTabContent()),
      ),
    );
  }
}
