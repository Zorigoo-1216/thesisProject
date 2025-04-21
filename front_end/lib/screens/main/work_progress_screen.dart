import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/api.dart';
import '../../constant/styles.dart';
import '../../models/worker_model.dart';
import '../../widgets/worker_card.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class WorkProgressScreen extends StatefulWidget {
  final String jobId;
  final int initialTabIndex;

  const WorkProgressScreen({
    super.key,
    required this.jobId,
    this.initialTabIndex = 0,
  });

  @override
  State<WorkProgressScreen> createState() => _WorkProgressScreenState();
}

class _WorkProgressScreenState extends State<WorkProgressScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool selecting = false;
  List<Worker> allWorkers = [];

  @override
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = widget.initialTabIndex;

    // ✅ Tab солигдох үед UI шинэчлэх
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        fetchStartRequests();
        setState(() {
          selecting = false;
        });
      }
    });

    fetchStartRequests();
  }

  Future<void> fetchStartRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('${baseUrl}jobprogress/${widget.jobId}/start-requests'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        allWorkers = List<Worker>.from(data.map((e) => Worker.fromJson(e)));
      });
    } else {
      debugPrint('❌ Error fetching start requests: ${response.body}');
    }
  }

  Future<void> confirmAction() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final jobId = widget.jobId;

    final selectedIds =
        allWorkers
            .where((worker) => worker.selected)
            .map((worker) => worker.jobprogressId)
            .toList();

    if (selectedIds.isEmpty) return;

    // ✅ Ажил эхлэх хугацааг (одоо цаг) ISO string болгож илгээе
    final now = DateTime.now().toIso8601String();

    final response = await http.post(
      Uri.parse('${baseUrl}jobprogress/$jobId/approve-start'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'jobprogressIds': selectedIds,
        'startTime': now, // ✅ ажил эхлэх цаг
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ажил эхлүүлэх хүсэлтүүдийг баталлаа")),
      );
      await fetchStartRequests(); // Дахин шинэчилнэ
      setState(() => selecting = false);
    } else {
      debugPrint('❌ Батлах алдаа: ${response.body}');
    }
  }

  Future<void> confirmCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final jobId = widget.jobId;

    final selectedIds =
        allWorkers
            .where((worker) => worker.selected)
            .map((worker) => worker.jobprogressId)
            .toList();

    if (selectedIds.isEmpty) return;

    final response = await http.post(
      Uri.parse('${baseUrl}jobprogress/$jobId/approve-completion'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'jobprogressIds': selectedIds}),
    );
    debugPrint("📤 Илгээж байна: $selectedIds");
    debugPrint("➡️ Endpoint: ${baseUrl}jobprogress/$jobId/approve-completion");

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Цалинг баталгаажууллаа")));
      debugPrint('🔄 Шинэчилж байна');
      await fetchStartRequests();
      debugPrint('✅ Дахин ачааллаа');
      // дахин ачааллах
      setState(() => selecting = false);
    } else {
      debugPrint('❌ Цалинг батлах алдаа: ${response.body}');
    }
  }

  void resetSelection() {
    setState(() {
      selecting = false;
      for (var worker in allWorkers) {
        worker.selected = false;
      }
    });
  }

  List<Worker> get filtered {
    final tab = _tabController.index;

    if (tab == 0) {
      return allWorkers.where((w) => w.status == 'pendingStart').toList();
    } else if (tab == 1) {
      return allWorkers
          .where((w) => ['in_progress', 'verified'].contains(w.status))
          .toList();
    } else {
      return allWorkers
          .where((w) => ['completed', 'paiding'].contains(w.status))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = filtered;

    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder:
              (context, _) => [
                CustomSliverAppBar(
                  tabController: _tabController,
                  showBack: true,
                  showTabs: true,
                  tabs: const [
                    Tab(text: "Хүсэлтүүд"),
                    Tab(text: "Ажлын явц"),
                    Tab(text: "Төлбөр"),
                  ],
                ),
              ],
          body: TabBarView(
            controller: _tabController,
            children: [_buildList(), _buildList(), _buildList()],
          ),
        ),
        bottomNavigationBar:
            list.isEmpty
                ? null
                : Padding(
                  padding: const EdgeInsets.all(16),
                  child:
                      selecting
                          ? Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    final tab = _tabController.index;

                                    final selected =
                                        filtered
                                            .where((w) => w.selected)
                                            .toList();
                                    debugPrint("✅ Батлах дарлаа");
                                    debugPrint(
                                      "🎯 Сонгогдсон ажилчид: ${selected.map((w) => w.name).toList()}",
                                    );
                                    debugPrint(
                                      "🆔 jobprogressIds: ${selected.map((w) => w.jobprogressId).toList()}",
                                    );

                                    if (selected.isEmpty) return;

                                    if (tab == 0) {
                                      // ❗ зөвхөн pendingStart төлөвтэй ажилтнуудыг батална
                                      final valid = selected.every(
                                        (w) => w.status == 'pendingStart',
                                      );
                                      if (valid) {
                                        confirmAction();
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Зөвхөн хүсэлт илгээсэн ажилчдыг сонгоно уу",
                                            ),
                                          ),
                                        );
                                      }
                                    } else if (tab == 2) {
                                      // ❗ зөвхөн verified ажилтнуудыг completed болгоно
                                      final valid = selected.every(
                                        (w) => w.status == 'verified',
                                      );
                                      if (valid) {
                                        confirmCompletion();
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Зөвхөн шалгагдсан ажилчдыг сонгоно уу",
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                  child: const Text(
                                    "Батлах",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: resetSelection,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  child: const Text("Цуцлах"),
                                ),
                              ),
                            ],
                          )
                          : ElevatedButton(
                            onPressed: () => setState(() => selecting = true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text(
                              "Сонгох",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                ),
      ),
    );
  }

  Widget _buildList() {
    final list = filtered;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final worker = list[index];
        return WorkerCard(
          worker: worker,
          showCheckbox: selecting,
          onChanged: (val) => setState(() => worker.selected = val ?? false),
        );
      },
    );
  }
}
