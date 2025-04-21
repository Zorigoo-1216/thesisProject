import 'package:flutter/material.dart';
import 'package:front_end/constant/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constant/styles.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class EmployeeWorkProgressScreen extends StatefulWidget {
  const EmployeeWorkProgressScreen({super.key});

  @override
  State<EmployeeWorkProgressScreen> createState() =>
      _EmployeeWorkProgressScreenState();
}

class _EmployeeWorkProgressScreenState
    extends State<EmployeeWorkProgressScreen> {
  bool isStarted = false;
  bool isFinished = false;
  bool isLoading = false;
  String jobId = ''; // will get from prefs or passed args

  @override
  void initState() {
    super.initState();
    loadJobId();
  }

  Future<void> loadJobId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      jobId = prefs.getString('currentJobId') ?? '';
    });
  }

  Future<void> startRequest() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getString('userId') ?? '';

      final response = await http.post(
        Uri.parse('${baseUrl}job/$jobId/start'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"workerId": userId}), // ⬅️ илгээж байна
      );

      if (response.statusCode == 200) {
        setState(() {
          isStarted = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ажил эхэллээ')));
      } else {
        debugPrint('❌ Error starting job: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String status =
        isStarted
            ? (isFinished ? "Шалгаж байна" : "Ажиллаж байна")
            : "Хүлээж байна";

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
                          Text("О.Эрдэнэцогт", style: AppTextStyles.heading),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _statusBadge(status),
                      const SizedBox(height: 12),
                      const Text("Ажилласан цаг: -"),
                      const SizedBox(height: 4),
                      const Text("Цалин: -"),
                      const SizedBox(height: 16),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:
                                isStarted
                                    ? isFinished
                                        ? [
                                          _actionButton("Цалин харах", () {
                                            Navigator.pushNamed(
                                              context,
                                              '/employee-payment',
                                            );
                                          }),
                                          _outlinedButton("Цуцлах", () {
                                            setState(() {
                                              isStarted = false;
                                              isFinished = false;
                                            });
                                          }),
                                        ]
                                        : [
                                          _actionButton("Дуусгах", () {
                                            setState(() {
                                              isFinished = true;
                                            });
                                          }),
                                          _outlinedButton("Засварлах", () {}),
                                        ]
                                    : [_actionButton("Эхлүүлэх", startRequest)],
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
