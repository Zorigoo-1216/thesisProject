import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/styles.dart';
import '../../constant/api.dart';
import '../../models/job_model.dart';

class JobDetailScreen extends StatefulWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Map<String, dynamic>? employerInfo;
  List<Map<String, dynamic>> employerComments = [];

  bool isLoading = true;
  bool applied = false;
  bool applying = false;

  @override
  void initState() {
    super.initState();
    applied = widget.job.isApplied;
    fetchEmployerInfo();
    fetchEmployerComments();
  }

  Future<void> fetchEmployerInfo() async {
    final employerId = widget.job.employerId;
    final uri = Uri.parse('${baseUrl}auth/getuserinfo/$employerId');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          employerInfo = data['employer'] ?? {};
          isLoading = false;
        });
      } else {
        print("❌ Error fetching employer info: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception fetching employer info: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchEmployerComments() async {
    final employerId = widget.job.employerId;
    final uri = Uri.parse('${baseUrl}ratings/$employerId/comments');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          employerComments = List<Map<String, dynamic>>.from(
            data['comments'] ?? [],
          );
        });
      } else {
        print("❌ Error fetching comments: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception while fetching comments: $e");
    }
  }

  Future<void> _toggleApplication() async {
    setState(() => applying = true);

    final jobId = widget.job.jobId;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');

    if (token == null || userId == null) {
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
          SnackBar(content: Text(applied ? 'Хүсэлт илгээгдлээ' : 'Цуцаллаа')),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Алдаа гарлаа';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      print("❌ Error submitting application: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Сүлжээний алдаа')));
    }

    setState(() => applying = false);
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          toolbarHeight: 80,
          leading: const BackButton(color: AppColors.text),
          title: const Text(
            "Ажлын дэлгэрэнгүй",
            style: TextStyle(color: AppColors.text),
          ),
        ),
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
                        backgroundImage: AssetImage('assets/images/user.png'),
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
                            const SizedBox(height: 4),
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
                            const SizedBox(height: 4),
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

            const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.black,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Ажлын мэдээлэл'),
                Tab(text: 'Ажил олгогчийн мэдээлэл'),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  _jobInfoTab(job),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _employerInfoTab(employerInfo ?? {}, employerComments),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          const SizedBox(height: 8),
          Text("Цалин: ${job.salary.getSalaryFormatted()}"),
          Text("Эхлэх: ${job.startDate}"),
          Text("Дуусах: ${job.endDate}"),
          const SizedBox(height: 16),
          const Text("Шаардлагууд", style: AppTextStyles.heading),
          const SizedBox(height: 8),
          ...job.requirements.map((r) => Text("- $r")).toList(),
        ],
      ),
    );
  }

  static Widget _employerInfoTab(
    Map<String, dynamic> data,
    List<Map<String, dynamic>> comments,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (data['type'] != null) Text(data['type']),
                  const SizedBox(height: 4),
                  if (data['rating'] != null || data['jobCount'] != null)
                    Row(
                      children: [
                        if (data['rating'] != null) ...[
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${data['rating']}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                        if (data['jobCount'] != null) ...[
                          const SizedBox(width: 8),
                          Text("Нийт ажил: ${data['jobCount']}"),
                        ],
                      ],
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (data['phone'] != null && data['phone'].toString().isNotEmpty) ...[
            const Text("Холбоо барих", style: AppTextStyles.heading),
            const SizedBox(height: 4),
            Text("Утас: ${data['phone']}"),
          ],
          const SizedBox(height: 16),
          if (comments.isNotEmpty) ...[
            const Text("Сэтгэгдэл", style: AppTextStyles.heading),
            const SizedBox(height: 8),
            ...comments.map((c) {
              final user = c['user'] ?? "Нэргүй";
              final rating = c['rating']?.toString() ?? "0";
              final text = c['text'] ?? "";
              return _commentCard(user, rating, text);
            }).toList(),
          ],
        ],
      ),
    );
  }

  static Widget _commentCard(String name, String rating, String comment) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/avatar.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$rating ⭐",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(comment, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
