import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/styles.dart';
import '../../constant/api.dart';
import '../../models/job_model.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class JobDetailScreen extends StatefulWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  UserModel? employerUser;
  bool isLoading = true;
  bool applied = false;
  bool applying = false;

  @override
  void initState() {
    super.initState();
    applied = widget.job.isApplied;
    fetchEmployerInfo();
  }

  Future<void> fetchEmployerInfo() async {
    final uri = Uri.parse('${baseUrl}jobs/${widget.job.jobId}/employer');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          employerUser = UserModel.fromJson(data['employer']);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleApplication() async {
    setState(() => applying = true);

    final jobId = widget.job.jobId;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Нэвтрэх шаардлагатай')));
      setState(() => applying = false);
      return;
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final uri =
          applied
              ? Uri.parse('$baseUrl/applications/apply/cancel/$jobId')
              : Uri.parse('$baseUrl/applications/apply');

      final response =
          applied
              ? await http.delete(uri, headers: headers)
              : await http.post(
                uri,
                headers: headers,
                body: jsonEncode({'jobId': jobId}),
              );

      if (response.statusCode == 200) {
        setState(() => applied = !applied);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(applied ? 'Илгээсэн' : 'Цуцлагдлаа')),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Алдаа гарлаа';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Сүлжээний алдаа')));
    }

    setState(() => applying = false);
  }

  @override
  @override
  Widget build(BuildContext context) {
    //final bool isMainTab = ModalRoute.of(context)?.isFirst ?? false;
    final job = widget.job;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                CustomSliverAppBar(
                  showTabs: true,
                  showBack: true,
                  tabs: [Tab(text: 'Ажлын мэдээлэл'), Tab(text: 'Ажил олгогч')],
                ),
              ],
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage(
                            'assets/images/avatar.png',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.employerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(job.title),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    job.location,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Text(
                                job.salary.getSalaryFormatted(),
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _jobInfoTab(job),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _employerInfoTabFromUserModel(employerUser),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: applying ? null : _toggleApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          applied ? Colors.grey.shade300 : AppColors.primary,
                      foregroundColor: applied ? AppColors.text : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        applying
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(applied ? 'Илгээсэн' : 'Илгээх'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _jobInfoTab(Job job) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text("Ажлын тухай", style: AppTextStyles.heading),
          const SizedBox(height: 8),
          Text(
            job.description.isNotEmpty ? job.description : "Тайлбар оруулаагүй",
          ),
          const SizedBox(height: 16),
          const Text("Ажлын шаардлага", style: AppTextStyles.heading),
          Text("Цалин: ${job.salary.getSalaryFormatted()}"),
          Text("Эхлэх: ${job.startDate}"),
          Text("Дуусах: ${job.endDate}"),
          const SizedBox(height: 16),
          const Text("Шаардлагууд", style: AppTextStyles.heading),
          const SizedBox(height: 8),
          ...job.requirements.map((r) => Text("- $r")),
        ],
      ),
    );
  }

  static Widget _employerInfoTabFromUserModel(UserModel? user) {
    if (user == null) return const Text("Мэдээлэл олдсонгүй");

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage:
                    user.avatar != null && user.avatar!.isNotEmpty
                        ? NetworkImage(user.avatar!) as ImageProvider
                        : const AssetImage('assets/images/avatar.png'),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text("Төрөл: ${user.role}"),
                  if (user.phone != null && user.phone!.isNotEmpty)
                    Text("Утас: ${user.phone}"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (user.profile != null) ...[
            const Text("Байршил ба туршлага", style: AppTextStyles.heading),
            const SizedBox(height: 8),
            if (user.profile!.location != null &&
                user.profile!.location!.isNotEmpty)
              Text("Байршил: ${user.profile!.location}"),
            if (user.profile!.mainBranch != null &&
                user.profile!.mainBranch!.isNotEmpty)
              Text("Үндсэн салбар: ${user.profile!.mainBranch}"),
            if (user.profile!.experienceLevel != null &&
                user.profile!.experienceLevel!.isNotEmpty)
              Text("Туршлагын түвшин: ${user.profile!.experienceLevel}"),
            const SizedBox(height: 16),
          ],

          Text(
            "Нийт үнэлгээ: ⭐ ${user.averageRatingForEmployer.overall} (${user.averageRatingForEmployer.totalRatings} үнэлгээ)",
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: 8),

          const Text("Үнэлгээний дэлгэрэнгүй", style: AppTextStyles.heading),
          const SizedBox(height: 8),
          ...user.averageRatingForEmployer.criteria.entries.map((entry) {
            return Row(
              children: [
                Expanded(
                  child: Text("• ${_localizedEmployerLabel(entry.key)}"),
                ),
                Text("${entry.value} ⭐"),
              ],
            );
          }),

          const SizedBox(height: 16),
          if (user.ratingCriteriaForEmployer.isNotEmpty) ...[
            const Text("Ажилчдын сэтгэгдэл", style: AppTextStyles.heading),
            const SizedBox(height: 8),
            ...user.ratingCriteriaForEmployer.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...e.criteria.entries.map((entry) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              "• ${_localizedEmployerLabel(entry.key)}",
                            ),
                          ),
                          Text("${entry.value} ⭐"),
                        ],
                      );
                    }),
                    if (e.comment.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text("💬 ${e.comment}"),
                    ],
                    const Divider(),
                  ],
                ),
              );
            }),
          ] else
            const Text("Ажилчдаас үнэлгээ хараахан ирээгүй байна"),
        ],
      ),
    );
  }

  static String _localizedEmployerLabel(String key) {
    const labels = {
      'employee_relationship': 'Ажилчдын харилцаа',
      'salary_fairness': 'Цалингийн шударга байдал',
      'work_environment': 'Ажлын орчин',
      'growth_opportunities': 'Өсөлтийн боломж',
      'workload_management': 'Ачааллын зохицуулалт',
      'leadership_style': 'Удирдлагын арга барил',
      'decision_making': 'Шийдвэр гаргалт',
      'legal_compliance': 'Хуулийн дагаж мөрдөлт',
    };
    return labels[key] ?? key;
  }
}
