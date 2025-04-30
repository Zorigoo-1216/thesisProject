import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/api.dart';
import '../../constant/styles.dart';
import '../../models/worker_model.dart'; // ✅ Worker model ашиглана
import '../../widgets/custom_sliver_app_bar.dart';

class EmployeeWorkProgressScreen extends StatefulWidget {
  final String jobId;
  const EmployeeWorkProgressScreen({super.key, required this.jobId});

  @override
  State<EmployeeWorkProgressScreen> createState() =>
      _EmployeeWorkProgressScreenState();
}

class _EmployeeWorkProgressScreenState
    extends State<EmployeeWorkProgressScreen> {
  bool isLoading = false;
  bool hasContract = false;
  Worker? worker;
  Timer? salaryTimer;

  @override
  void initState() {
    super.initState();
    checkContractExistsWorker();
  }

  @override
  void dispose() {
    salaryTimer?.cancel();
    super.dispose();
  }

  Future<void> checkContractExistsWorker() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final workerId = prefs.getString('userId');

    if (token == null || workerId == null) return;

    final res = await http.get(
      Uri.parse('${baseUrl}contracts/by-job/${widget.jobId}/worker/$workerId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 404) {
      setState(() => hasContract = false);
    } else if (res.statusCode == 200) {
      setState(() => hasContract = true);
      await loadProgress();
      startSalaryPolling();
    }
  }

  void startSalaryPolling() {
    salaryTimer?.cancel();
    salaryTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => loadProgress(),
    );
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getString('userId') ?? '';
    final phone = prefs.getString('phone') ?? '';

    final res = await http.get(
      Uri.parse('${baseUrl}jobprogress/${widget.jobId}/my-progress'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      setState(() {
        worker = Worker.fromJson({
          "workerId": {
            "_id": data['workerId'] ?? '',
            "firstName": data['firstName'] ?? '',
            "lastName": data['lastName'] ?? '',
            "phone": data['phone'] ?? '',
            "rating": 4.5,
            "projects": 0,
          },
          "_id": data['_id'],
          "status": data['status'],
          "startedAt": data['startedAt'],
          "endedAt": data['endedAt'],
          "createdAt": data['createdAt'],
          "salary": data['salary'],
        });
      });

      if (worker?.status != 'in_progress') {
        salaryTimer?.cancel();
      }
    } else if (res.statusCode == 404) {
      // ✳️ Get job info to show its title
      final jobRes = await http.get(
        Uri.parse('${baseUrl}jobs/${widget.jobId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      String jobTitle = 'Ажлын нэр оруулаагүй';
      if (jobRes.statusCode == 200) {
        final jobData = jsonDecode(jobRes.body);
        jobTitle = jobData['title'] ?? jobTitle;
      }

      setState(() {
        worker = Worker(
          id: userId,
          name: jobTitle,
          phone: phone,
          rating: 0,
          projects: 0,
          requestTime: '',
          jobprogressId: '',
          workStartTime: '',
          status: 'not_started',
        );
      });
    } else {
      debugPrint('⚠️ Unexpected response loading progress: ${res.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(showTabs: false, showBack: true, tabs: []),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: AppSpacing.cardElevation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (!hasContract) {
      return const Center(
        child: Text(
          "⚠️ Гэрээ байгуулаагүй тул эхлүүлэх боломжгүй",
          textAlign: TextAlign.center,
        ),
      );
    }

    if (worker == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(worker!.name, style: AppTextStyles.heading)),
          ],
        ),
        const SizedBox(height: 8),
        _statusBadge(worker!.status),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.access_time, size: 18),
            const SizedBox(width: 6),
            Text(
              (worker!.workedHours != null && worker!.workedMinutes != null)
                  ? "${worker!.workedHours} цаг ${worker!.workedMinutes} мин"
                  : "0 цаг 0 мин", // 👈 "-" биш
              style: AppTextStyles.body,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.attach_money, size: 18),
            const SizedBox(width: 6),
            Text(
              worker!.salary != null ? "${worker!.salary}₮" : "0₮",
              style: AppTextStyles.body,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (!hasContract) {
      return const SizedBox.shrink(); // гэрээгүй үед юу ч харуулахгүй
    }
    if (worker == null ||
        worker!.status == 'not_started' ||
        worker!.jobprogressId.isEmpty) {
      return ElevatedButton(
        onPressed: _showStartDialog,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
        child: const Text("Ажил эхлүүлэх"),
      );
    }

    if (worker!.status == 'in_progress') {
      return ElevatedButton(
        onPressed: finishRequest,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        child: const Text("Дуусгах"),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _showStartDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Ажил эхлүүлэх үү?"),
            content: const Text("Та ажлаа эхлүүлэхдээ итгэлтэй байна уу?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Үгүй"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Тийм"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _confirmStartRequest();
    }
  }

  Future<void> _confirmStartRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getString('userId') ?? '';

    final response = await http.post(
      Uri.parse('${baseUrl}jobprogress/${widget.jobId}/start'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"workerId": userId}),
    );

    if (response.statusCode == 200) {
      await loadProgress();
      startSalaryPolling();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ажил эхэллээ')));
    } else {
      debugPrint("❌ Start job failed: ${response.body}");
    }
  }

  Future<void> finishRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final jobProgressId = worker?.jobprogressId;

    final response = await http.post(
      Uri.parse(
        '${baseUrl}jobprogress/${widget.jobId}/request-completion/$jobProgressId',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      salaryTimer?.cancel();
      await loadProgress();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Дуусгах хүсэлт илгээгдлээ")),
      );
    } else {
      debugPrint('❌ Finish request error: ${response.body}');
    }
  }

  Widget _statusBadge(String status) {
    final map = {
      'pendingStart': 'Хүлээгдэж байна',
      'in_progress': 'Ажиллаж байна',
      'verified': 'Шалгаж байна',
      'completed': 'Дууссан',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.stateBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        map[status] ?? "Төлөв тодорхойгүй",
        style: const TextStyle(color: AppColors.primary),
      ),
    );
  }
}
