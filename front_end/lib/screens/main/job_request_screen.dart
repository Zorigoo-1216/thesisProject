import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_end/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/styles.dart';
import '../../widgets/job_request_card.dart';
import '../../constant/api.dart';
import '../../models/rated_user_model.dart';

class JobRequestScreen extends StatefulWidget {
  final int initialTabIndex;
  final String jobId;

  const JobRequestScreen({
    super.key,
    required this.initialTabIndex,
    required this.jobId,
  });

  @override
  State<JobRequestScreen> createState() => _JobRequestScreenState();
}

class _JobRequestScreenState extends State<JobRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isSelecting = false;
  bool isLoading = false;

  final Set<String> selectedUsers = {};

  final List<String> tabTitles = [
    "Боломжит ажилтан",
    "Хүсэлтүүд",
    "Ярилцлага",
    "Хүлээж буй",
  ];

  Map<String, List<UserModel>> tabData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: tabTitles.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    debugPrint("📥 JobRequestScreen opened with jobId: ${widget.jobId}");
    fetchAllTabData();
  }

  @override
  void didUpdateWidget(covariant JobRequestScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.jobId != oldWidget.jobId ||
        widget.initialTabIndex != oldWidget.initialTabIndex) {
      fetchAllTabData();
    }
  }

  Future<void> fetchAllTabData() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      final suitable = await fetchTabData('suitable-workers');
      final applications = await fetchTabData('applications');
      final interviews = await fetchTabData('interviews');
      final candidates = await fetchTabData('candidates');

      setState(() {
        tabData["Боломжит ажилтан"] = suitable ?? [];
        tabData["Хүсэлтүүд"] = applications ?? [];
        tabData["Ярилцлага"] = interviews ?? [];
        tabData["Хүлээж буй"] = candidates ?? [];
      });
    } catch (e) {
      debugPrint("Error fetching tab data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<List<UserModel>> fetchTabData(String endpoint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint("[$endpoint] No authentication token found");
        return [];
      }

      final url = Uri.parse('${baseUrl}jobs/${widget.jobId}/$endpoint');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        debugPrint("[$endpoint] Request failed: ${response.statusCode}");
        return [];
      }

      final rawBody = response.body.trim();
      debugPrint("[$endpoint] RAW BODY: $rawBody");

      if (rawBody.isEmpty || rawBody == 'null') return [];

      dynamic decoded;
      try {
        decoded = jsonDecode(rawBody);
      } catch (e) {
        debugPrint("[$endpoint] JSON decode error: $e");
        return [];
      }

      debugPrint("[$endpoint] Decoded Type: ${decoded.runtimeType}");

      if (decoded is! Map<String, dynamic>) {
        debugPrint("[$endpoint] Unexpected JSON root (not Map): $decoded");
        return [];
      }

      debugPrint("[$endpoint] RESPONSE BODY >>>>>>>>>>");
      debugPrint(response.body);
      debugPrint(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

      const keys = {
        'suitable-workers': 'workers',
        'applications': 'employees',
        'interviews': 'interviews',
        'candidates': 'candidates',
      };

      final key = keys[endpoint];
      final data = decoded[key];
      if (data is! List) return [];
      debugPrint("[$endpoint] Raw list: $data");
      for (final item in data) {
        debugPrint("Item type: ${item.runtimeType}, value: $item");
      }
      //print(response.body);
      return data
          .whereType<Map<String, dynamic>>()
          .map((item) {
            try {
              if (endpoint == 'applications') {
                // rated user (user + rating)
                return item.containsKey('user')
                    ? RatedUserModel.fromJson(item).user
                    : null;
              } else {
                // direct user model (interviews, candidates)
                return UserModel.fromJson(item);
              }
            } catch (e) {
              debugPrint("[$endpoint] Failed to parse item: $e");
              return null;
            }
          })
          .whereType<UserModel>()
          .toList();
    } catch (e) {
      debugPrint("[$endpoint] Unexpected error: $e");
      return [];
    }
  }

  String getCurrentTabName() {
    final index = _tabController.index;
    if (index < 0 || index >= tabTitles.length) {
      debugPrint("Invalid tab index: $index");
      return tabTitles.first;
    }
    return tabTitles[index];
  }

  List<UserModel> getCurrentTabData() {
    final tabName = getCurrentTabName();
    return tabData[tabName] ?? [];
  }

  void confirmSelection() {
    final current = getCurrentTabName();
    final nextIndex = _tabController.index + 1;

    if (nextIndex < tabTitles.length) {
      final nextTab = tabTitles[nextIndex];

      setState(() {
        tabData[current] = List.from(tabData[current] ?? [])
          ..removeWhere((user) => selectedUsers.contains(user.id));
        tabData[nextTab] = List.from(tabData[nextTab] ?? [])..addAll(
          tabData[current]!.where((user) => selectedUsers.contains(user.id)),
        );

        selectedUsers.clear();
        isSelecting = false;
      });
    }
  }

  Widget buildUserCard(UserModel? user) {
    if (user == null) {
      return SizedBox(); // Or handle null cases here
    }

    return JobRequestCard(
      user: user, // Pass non-null UserModel
      showCheckbox: isSelecting,
      checked: selectedUsers.contains(user.id),
      onChanged: (val) {
        setState(() {
          if (val) {
            selectedUsers.add(user.id);
          } else {
            selectedUsers.remove(user.id);
          }
        });
      },
    );
  }

  Widget buildTabContent(int index) {
    final tabName = tabTitles[index];
    final items = tabData[tabName] ?? [];

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            switch (tabName) {
              "Боломжит ажилтан" => "Тохирох ажилтан олдсонгүй",
              "Хүсэлтүүд" => "Ажиллах хүсэлт ирээгүй байна",
              "Ярилцлага" => "Ярилцлагад уригдсан ажилтан байхгүй",
              "Хүлээж буй" => "Батлагдсан ажилтан алга байна",
              _ => "Мэдээлэл олдсонгүй",
            },
            style: const TextStyle(color: AppColors.text, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: items.map((user) => buildUserCard(user)).toList(),
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
                              foregroundColor:
                                  AppColors.white, // 👈 цагаан текст
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
                              backgroundColor: Colors.white, // арын фон
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
                        foregroundColor: AppColors.white, // 👈 цагаан текст
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
        leading: const BackButton(color: AppColors.text),
        backgroundColor: AppColors.white,
        actions: const [
          Icon(Icons.notifications_none, color: AppColors.primary),
          SizedBox(width: 12),
          Icon(Icons.settings, color: AppColors.primary),
          SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: tabTitles.map((t) => Tab(text: t)).toList(),
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
        children: List.generate(
          tabTitles.length,
          (index) => buildTabContent(index),
        ),
      ),
    );
  }
}
