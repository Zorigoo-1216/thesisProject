// 📁 employer_rate_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/api.dart';
import '../../constant/styles.dart';
import '../../widgets/custom_sliver_app_bar.dart';
import '../../models/user_model.dart';

class EmployerRateScreen extends StatefulWidget {
  final String jobId;
  const EmployerRateScreen({super.key, required this.jobId});

  @override
  State<EmployerRateScreen> createState() => _EmployerRateScreenState();
}

class _EmployerRateScreenState extends State<EmployerRateScreen> {
  bool loading = true;
  bool isRated = false;
  UserModel? employer;
  final Map<String, int> ratings = {};
  final TextEditingController commentController = TextEditingController();

  final criteriaLabels = {
    'employee_relationship': 'Ажилтантай харилцах байдал',
    'salary_fairness': 'Цалингийн шударга байдал',
    'work_environment': 'Ажлын орчин',
    'growth_opportunities': 'Хувь хүний өсөлт',
    'workload_management': 'Ажлын ачааллын зохион байгуулалт',
    'leadership_style': 'Удирдлагын хэв маяг',
    'decision_making': 'Шийдвэр гаргах байдал',
    'legal_compliance': 'Хууль зөрчөөгүй эсэх',
  };

  @override
  void initState() {
    super.initState();
    fetchEmployer().then((_) async {
      if (employer != null) {
        await checkIfRated(); // ⬅️ wait хийж дуусгах
      }
      setState(() => loading = false); // ⬅️ loading-г энд false болго
    });
  }

  Future<void> checkIfRated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final res = await http.get(
        Uri.parse('${baseUrl}ratings/job/${widget.jobId}/check-employer-rated'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        setState(() {
          isRated = data['isRated'] == true;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to check if rated: $e');
    }
  }

  Future<void> fetchEmployer() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final res = await http.get(
        Uri.parse('${baseUrl}jobs/${widget.jobId}/employer'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 &&
          data['success'] == true &&
          data['employer'] != null) {
        setState(() {
          employer = UserModel.fromJson(data['employer']);
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
      'employerId': employer!.id,
      'criteria': ratings,
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
        setState(() => isRated = true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Алдаа: ${data['message']}")));
      }
    } catch (e) {
      debugPrint('❌ Submit rating error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Сүлжээний алдаа гарлаа")));
    }
  }

  Widget buildStarRow(String key, String label) {
    final currentRating = ratings[key] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Wrap(
              spacing: 4,
              children: List.generate(5, (index) {
                return SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      index < currentRating ? Icons.star : Icons.star_border,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    onPressed:
                        isRated
                            ? null
                            : () => setState(() => ratings[key] = index + 1),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMainTab = ModalRoute.of(context)?.isFirst ?? false;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(showTabs: false, showBack: !isMainTab, tabs: []),
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
                          Text(employer!.name, style: AppTextStyles.heading),
                          Text(employer!.role, style: AppTextStyles.subtitle),
                          const SizedBox(height: 4),
                          Text(
                            employer!.phone ?? '',
                            style: const TextStyle(color: AppColors.subtitle),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Дундаж үнэлгээ: ${employer!.averageRatingForEmployer.overall.toStringAsFixed(1)}",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          isRated
                              ? const Text(
                                "Та энэ ажил олгогчийг үнэлсэн байна",
                                style: TextStyle(color: AppColors.subtitle),
                              )
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...criteriaLabels.entries.map(
                                    (e) => buildStarRow(e.key, e.value),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: commentController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: "Тайлбар бичих...",
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
                                          ratings.isNotEmpty
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
}
