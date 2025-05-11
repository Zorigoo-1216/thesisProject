import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/api.dart';
import '../../constant/styles.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class EmployerRateScreen extends StatefulWidget {
  final String jobId;
  const EmployerRateScreen({super.key, required this.jobId});

  @override
  State<EmployerRateScreen> createState() => _EmployerRateScreenState();
}

class _EmployerRateScreenState extends State<EmployerRateScreen> {
  int selectedRating = 0;
  final TextEditingController commentController = TextEditingController();
  bool loading = true;
  bool isRated = false;
  Map<String, dynamic>? employer;

  @override
  void initState() {
    super.initState();
    fetchEmployer();
  }

  Future<void> fetchEmployer() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final res = await http.get(
        Uri.parse('${baseUrl}ratings/job/${widget.jobId}/employer'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        setState(() {
          employer = data['data'];
          loading = false;
        });
      } else {
        debugPrint("⚠️ Employer fetch failed: ${data['message']}");
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint('❌ Exception loading employer: $e');
      setState(() => loading = false);
    }
  }

  Future<void> submitRating() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final comment = commentController.text.trim();

    final body = jsonEncode({
      'employerId': employer!['id'],
      'criteria': {'employee_relationship': selectedRating},
      'comment': comment,
    });

    try {
      final res = await http.post(
        Uri.parse('${baseUrl}ratings/job/${widget.jobId}/employer'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 201 && data['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Үнэлгээ илгээгдлээ")));
        setState(() {
          isRated = true;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Алдаа: ${data['message']}")));
      }
    } catch (e) {
      debugPrint('❌ Submit rating error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Алдаа гарлаа.")));
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(showTabs: false, showBack: true, tabs: []),
          SliverToBoxAdapter(
            child:
                loading
                    ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : employer == null
                    ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text("Ажил олгогч олдсонгүй")),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 36,
                            backgroundImage: AssetImage(
                              'assets/images/avatar.png',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            employer!['name'] ?? '',
                            style: AppTextStyles.heading,
                          ),
                          Text(
                            employer!['role'] ?? '',
                            style: AppTextStyles.subtitle,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _statBox(
                                employer!['averageRating']?.toStringAsFixed(
                                      1,
                                    ) ??
                                    '0.0',
                                "ҮНЭЛГЭЭ",
                                Icons.star,
                                Colors.amber,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          isRated
                              ? const Text(
                                "Та энэ ажил олгогчийг үнэлсэн байна",
                                style: TextStyle(color: AppColors.subtitle),
                              )
                              : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      return IconButton(
                                        icon: Icon(
                                          index < selectedRating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: AppColors.primary,
                                          size: 32,
                                        ),
                                        onPressed: () {
                                          setState(
                                            () => selectedRating = index + 1,
                                          );
                                        },
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  TextField(
                                    controller: commentController,
                                    enabled: !isRated,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: "Тайлбар бичих...",
                                      prefixIcon: const Icon(
                                        Icons.comment_outlined,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          selectedRating > 0
                                              ? submitRating
                                              : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text("Үнэлгээ илгээх"),
                                    ),
                                  ),
                                ],
                              ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
