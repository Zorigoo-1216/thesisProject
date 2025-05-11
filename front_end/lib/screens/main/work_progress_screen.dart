import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/api.dart';
import '../../constant/styles.dart';
import '../../models/worker_model.dart';
import '../../models/payment_model.dart';
import '../../widgets/worker_card.dart';
import '../../widgets/custom_sliver_app_bar.dart';
import '../../widgets/payment_card.dart';

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
  List<Payment> allPayments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = widget.initialTabIndex;

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index == 2) {
          fetchPayments();
        } else {
          fetchStartRequests();
        }
        setState(() => selecting = false);
      }
    });

    checkContractExists();
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

  Future<void> fetchPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('${baseUrl}payments/job/${widget.jobId}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final payments = List<Payment>.from(
          data['data'].map((e) => Payment.fromJson(e)),
        );

        setState(() {
          allPayments = payments;
        });

        // ✅ Бүх төлбөрийн статус 'paid' эсэхийг шалгана
        final allPaid =
            payments.isNotEmpty && payments.every((p) => p.status == 'paid');
        if (allPaid) {
          Future.delayed(Duration.zero, () {
            showDialog(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: const Text("Санал хүсэлт"),
                    content: const Text("Та ажилчдад үнэлгээ өгнө үү."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Дараа"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(
                            context,
                            '/rate-employee',
                            arguments: {
                              'jobId':
                                  widget
                                      .jobId, // 🔄 String утгыг map дотор оруулж байна
                            },
                          );
                        },
                        child: const Text(
                          "Үнэлгээ өгөх",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
            );
          });
        }
      }
    } else {
      debugPrint('❌ Error fetching payments: ${response.body}');
    }
  }

  Future<void> checkContractExists() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      debugPrint("⛔ No token found");
      return;
    }

    final res = await http.get(
      Uri.parse('${baseUrl}contracts/by-job/${widget.jobId}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 404) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Анхааруулга"),
                content: const Text(
                  "Энэ ажилд гэрээ үүсээгүй байна.\nГэрээ үүсгэх үү?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Болих"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(
                        context,
                        '/job-contract',
                        arguments: {
                          'jobId': widget.jobId,
                          'initialTabIndex': 0,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      "Гэрээ үүсгэх",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        );
      });
    }
  }

  Future<void> _confirmPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final selectedIds =
        allPayments.where((p) => p.selected).map((p) => p.id).toList();

    if (selectedIds.isEmpty) return;

    final response = await http.post(
      Uri.parse('${baseUrl}payments/transfer'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'paymentIds': selectedIds}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ажлын гүйцэтгэлийг баталгаажууллаа")),
      );
      await fetchPayments();
      setState(() => selecting = false);
    } else {
      debugPrint('❌ Transfer failed: ${response.body}');
    }
  }

  Future<void> confirmAction() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final selectedIds =
        allWorkers
            .where((w) => w.selected)
            .map((w) => w.jobprogressId)
            .toList();

    if (selectedIds.isEmpty) return;

    final now = DateTime.now().toIso8601String();

    final response = await http.post(
      Uri.parse('${baseUrl}jobprogress/${widget.jobId}/approve-start'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'jobprogressIds': selectedIds, 'startTime': now}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ажил эхлүүлэх хүсэлтүүдийг баталлаа")),
      );
      await fetchStartRequests();
      setState(() => selecting = false);
    } else {
      debugPrint('❌ Батлах алдаа: ${response.body}');
    }
  }

  Future<void> confirmCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final selectedIds =
        allWorkers
            .where((w) => w.selected)
            .map((w) => w.jobprogressId)
            .toList();

    if (selectedIds.isEmpty) return;

    final response = await http.post(
      Uri.parse('${baseUrl}jobprogress/${widget.jobId}/approve-completion'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'jobprogressIds': selectedIds}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Цалинг баталгаажууллаа")));
      await fetchPayments();
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
            children: [_buildList(), _buildList(), _buildPaymentTab()],
          ),
        ),
        // ❌ bottomNavigationBar хэсгийг бүрэн устгав
      ),
    );
  }

  void _confirmSelected() {
    final tab = _tabController.index;
    if (tab == 0) {
      confirmAction();
    } else if (tab == 1) {
      confirmCompletion();
    }
  }

  Widget _buildList() {
    final list = filtered;

    if (list.isEmpty) {
      return const Center(child: Text("Одоогоор мэдээлэл алга"));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final worker = list[index];
              return WorkerCard(
                worker: worker,
                showCheckbox: selecting,
                onChanged:
                    (val) => setState(() => worker.selected = val ?? false),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child:
              selecting
                  ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: _confirmSelected,
                          child: const Text(
                            "Батлах",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: resetSelection,
                          child: const Text("Цуцлах"),
                        ),
                      ),
                    ],
                  )
                  : ElevatedButton(
                    onPressed: () => setState(() => selecting = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(48), // өндөр
                    ),
                    child: const SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          "Сонгох",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildPaymentTab() {
    if (allPayments.isEmpty) {
      return const Center(child: Text("Одоогоор төлбөрийн мэдээлэл байхгүй"));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allPayments.length,
            itemBuilder: (context, index) {
              final payment = allPayments[index];

              return PaymentCard(
                payment: payment,
                showCheckbox: selecting,
                selected: payment.selected,

                onChanged: (val) {
                  setState(() => payment.selected = val ?? false);
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child:
              selecting
                  ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: _confirmPayments,
                          child: const Text(
                            "Батлах",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selecting = false;
                              for (var p in allPayments) {
                                p.selected = false;
                              }
                            });
                          },
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
                    child: const SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          "Сонгох",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
        ),
      ],
    );
  }
}
