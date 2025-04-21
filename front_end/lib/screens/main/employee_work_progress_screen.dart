import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:front_end/constant/api.dart';
import 'package:front_end/constant/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Map<String, dynamic>? progress;
  String status = '';
  int? salary;
  String workedTime = '-';
  String displayStatus = "Хүлээж байна";

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('${baseUrl}jobprogress/${widget.jobId}/my-progress'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final currentStatus = data['status'];
      final totalSalary = data['salary']?['total'];
      final startedAt = data['startedAt'];
      final endedAt = data['endedAt'];

      String duration = "-";
      if (startedAt != null) {
        final start = DateTime.parse(startedAt);
        final end = endedAt != null ? DateTime.parse(endedAt) : DateTime.now();
        final hours = end.difference(start).inMinutes / 60;
        duration = "${hours.toStringAsFixed(1)} цаг";
      }

      setState(() {
        progress = {
          ...data,
          'jobprogressId': data['_id'], // 👈 нэмэх
        };
        status = currentStatus;
        salary = totalSalary;
        workedTime = duration;

        if (currentStatus == 'in_progress')
          displayStatus = 'Ажиллаж байна';
        else if (currentStatus == 'verified' || currentStatus == 'completed')
          displayStatus = 'Шалгаж байна';
        else if (currentStatus == 'pendingStart')
          displayStatus = 'Хүлээгдэж байна';
        else
          displayStatus = 'Эхлээгүй';
      });
    }
    setState(() => isLoading = false);
  }

  Future<void> startRequest() async {
    setState(() => isLoading = true);
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ажил эхэллээ')));
    } else {
      debugPrint('❌ Error: ${response.body}');
    }
    setState(() => isLoading = false);
  }

  Future<void> finishRequest() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      /*************  ✨ Windsurf Command ⭐  *************/
      /// Start job progress request
      ///
      /// Set the job progress status to 'started' and save the worker's ID
      /// in the job progress record.
      ///
      /// If the request is successful, load the progress data again and show
      /// a snackbar with the message "Ажил эхэллээ". Otherwise, log the error
      /// with the message "❌ Error: <error message>".
      ///
      /// This function is called when the user clicks the "Start" button on the
      /// job progress screen.
      ///
      /// [isLoading] is set to true while the request is being processed, and
      /// back to false when the request is finished.
      /*******  f2577045-9cd8-46f7-b1c7-27ac1c32afc7  *******/
      final token = prefs.getString('token') ?? '';
      final jobProgressId = progress?['jobprogressId'];

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
        await loadProgress();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Дуусгах хүсэлт амжилттай илгээгдлээ")),
        );
      } else {
        debugPrint('❌ Finish request error: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Exception during finish request: $e');
    } finally {
      setState(() => isLoading = false);
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/images/avatar.png',
                            ),
                            radius: 20,
                          ),
                          SizedBox(width: 8),
                          Text("Ажилтан", style: AppTextStyles.heading),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _statusBadge(displayStatus),
                      const SizedBox(height: 12),
                      Text("Ажилласан цаг: $workedTime"),
                      Text("Цалин: ${salary != null ? "$salary₮" : '-'}"),
                      const SizedBox(height: 16),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _buildActionButtons(),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    if (progress == null || status == 'closed' || status == 'not_started') {
      return [_actionButton("Эхлүүлэх", startRequest)];
    }

    if (status == 'in_progress') {
      return [
        _actionButton("Дуусгах", finishRequest),
        _outlinedButton("Завсарлах", () {
          // TODO: Pause feature
        }),
      ];
    }

    if (status == 'verified' || status == 'completed') {
      return [
        _actionButton("Цалин харах", () {
          Navigator.pushNamed(
            context,
            '/employee-payment',
            arguments: {"jobId": widget.jobId},
          );
        }),
        _outlinedButton("Буцах", () {
          setState(() {
            progress = null;
            status = '';
            salary = null;
            workedTime = '-';
            displayStatus = "Хүлээж байна";
          });
        }),
      ];
    }

    return [];
  }

  Widget _statusBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.stateBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(color: AppColors.primary)),
    );
  }

  Widget _actionButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }

  Widget _outlinedButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}
