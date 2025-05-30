import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_end/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/styles.dart';
import '../../widgets/custom_sliver_app_bar.dart';
import '../../widgets/job_request_card.dart';
import '../../constant/api.dart';
import '../../models/rated_user_model.dart';
import '../../models/job_model.dart';

class JobRequestScreen extends StatefulWidget {
  final int initialTabIndex;
  final String jobId;
  final bool hasInterview;

  const JobRequestScreen({
    super.key,
    required this.initialTabIndex,
    required this.jobId,
    required this.hasInterview,
  });

  @override
  State<JobRequestScreen> createState() => _JobRequestScreenState();
}

class _JobRequestScreenState extends State<JobRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isSelecting = false;
  bool isLoading = false;
  Job? job;
  final Set<String> selectedUsers = {};
  late List<String> tabTitles;
  Map<String, List<UserModel>> tabData = {};

  @override
  void initState() {
    super.initState();

    tabTitles = [
      "Боломжит ажилтан",
      "Хүсэлтүүд",
      if (widget.hasInterview) "Ярилцлага",
      "Хүлээж буй",
    ];

    _tabController = TabController(
      length: tabTitles.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          isSelecting = false;
          selectedUsers.clear();
        });
      }
    });

    debugPrint("📥 JobRequestScreen opened with jobId: ${widget.jobId}");
    fetchAllTabData();
    fetchJobById();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Хуудас руу орох бүрт мэдээллийг шинэчлэх
    setState(() {
      isLoading = true;
    });
    fetchAllTabData();
    fetchJobById();
  }

  Future<void> fetchJobById() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      debugPrint("⛔️ No auth token");
      return;
    }

    final url = Uri.parse('${baseUrl}jobs/${widget.jobId}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final jobData = json['job'] ?? json; // depending on your API structure
        setState(() {
          job = Job.fromJson(jobData);
        });
        fetchAllTabData(); // 🆕 ажлын мэдээлэл авсны дараа хүсэлтүүдээ авна
      } else {
        debugPrint("❌ Failed to load job: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Exception in fetchJobById: $e");
    }
  }

  Future<void> fetchAllTabData() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      final suitable = await fetchTabData('suitable-workers');
      final applications = await fetchTabData('applications');
      final interviews =
          widget.hasInterview
              ? await fetchTabData('interviews')
              : <UserModel>[];

      final candidates = await fetchTabData('candidates');

      setState(() {
        tabData["Боломжит ажилтан"] = suitable;
        tabData["Хүсэлтүүд"] = applications;
        if (widget.hasInterview) {
          tabData["Ярилцлага"] = interviews;
        }
        tabData["Хүлээж буй"] = candidates;
      });
    } catch (e) {
      debugPrint("❌ Error fetching tab data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<List<UserModel>> fetchTabData(String endpoint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint("[$endpoint] No token");
        return [];
      }

      final url = Uri.parse('${baseUrl}jobs/${widget.jobId}/$endpoint');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.body);
      final keyMap = {
        'suitable-workers': 'workers',
        'applications': 'employees',
        'interviews': 'interviews',
        'candidates': 'candidates',
      };

      final data = decoded[keyMap[endpoint]];
      if (data is! List) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map((item) {
            try {
              if (item.containsKey('user')) {
                return RatedUserModel.fromJson(item).user;
              } else if (item.containsKey('viewUserDTO')) {
                return UserModel.fromJson(item['viewUserDTO']);
              } else {
                return UserModel.fromJson(item);
              }
            } catch (e) {
              debugPrint("❌ $endpoint parse failed: $e");
              return null;
            }
          })
          .whereType<UserModel>()
          .toList();
    } catch (e) {
      debugPrint("❌ $endpoint unexpected error: $e");
      return [];
    }
  }

  String getCurrentTabName() => tabTitles[_tabController.index];
  List<UserModel> getCurrentTabData() => tabData[getCurrentTabName()] ?? [];

  Future<void> confirmSelection() async {
    final currentTab = getCurrentTabName(); // Жишээ: "Хүсэлтүүд", "Ярилцлага"
    final nextIndex = _tabController.index + 1;
    final selected =
        tabData[currentTab]!
            .where((user) => selectedUsers.contains(user.id))
            .toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ажилтан сонгоогүй байна")));
      return;
    }
    print("🔥 selectedUserIds: ${selected.map((e) => e.id).toList()}");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception("Authentication token not found");

      // ✅ Endpoint-ийг currentTab нэр дээр үндэслэн сонгоно
      final endpoint =
          currentTab == "Ярилцлага"
              ? 'select-from-interview'
              : 'select-from-application';
      final response = await http.post(
        Uri.parse('${baseUrl}applications/job/${widget.jobId}/$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'selectedUserIds': selected.map((e) => e.id).toList(),
        }),
      );

      if (response.statusCode == 200) {
        if (nextIndex < tabTitles.length) {
          final nextTab = tabTitles[nextIndex];

          setState(() {
            tabData[currentTab]!.removeWhere(
              (u) => selectedUsers.contains(u.id),
            );
            tabData[nextTab] = [...(tabData[nextTab] ?? []), ...selected];
            selectedUsers.clear();
            isSelecting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Сонголт амжилттай бүртгэгдлээ")),
          );
        }
      } else {
        final decoded = jsonDecode(response.body);
        final errorValue = decoded['error'];
        final error = errorValue?.toString() ?? 'Алдаа гарлаа';

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      debugPrint("❌ Confirm selection error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Сүлжээний алдаа")));
    }
  }

  Widget buildUserCard(UserModel user) {
    print("👀 JobRequestCard rendering user: ${user.id}, ${user.name}");
    return JobRequestCard(
      job: job!,
      user: user,
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

    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (items.isEmpty) {
      final message = switch (tabName) {
        "Боломжит ажилтан" => "Тохирох ажилтан олдсонгүй",
        "Хүсэлтүүд" => "Ажиллах хүсэлт ирээгүй байна",
        "Ярилцлага" => "Ярилцлагад уригдсан ажилтан байхгүй",
        "Хүлээж буй" => "Батлагдсан ажилтан алга байна",
        _ => "Мэдээлэл байхгүй",
      };

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      );
    }

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
                            child: const Text(
                              "Батлах",
                              style: TextStyle(color: AppColors.white),
                            ),
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
                        setState(() => isSelecting = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text(
                        "Сонгох",
                        style: TextStyle(color: AppColors.white, fontSize: 16),
                      ),
                    ),
          ),
      ],
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final bool isMainTab = ModalRoute.of(context)?.isFirst ?? false;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              CustomSliverAppBar(
                showBack: true,
                showTabs: !isMainTab,
                tabController: _tabController,
                tabs: tabTitles.map((t) => Tab(text: t)).toList(),
              ),
            ],
        body: TabBarView(
          controller: _tabController,
          children: List.generate(
            tabTitles.length,
            (index) => buildTabContent(index),
          ),
        ),
      ),
    );
  }
}
