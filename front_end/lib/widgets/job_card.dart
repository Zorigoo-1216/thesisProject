import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/job_model.dart';
import '../constant/styles.dart';
import '../constant/api.dart';

class JobCard extends StatefulWidget {
  final Job job;
  final VoidCallback? onRefresh;
  const JobCard({super.key, required this.job, this.onRefresh});
  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool applied = false;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    applied = widget.job.isApplied; // Check if the user has already applied
  }

  Future<void> _toggleApplication() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId'); // Store this during login
    // print(token);
    // print(userId);

    if (token == null || userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Нэвтрэх шаардлагатай')));
      setState(() => loading = false);
      return;
    }

    final jobId = widget.job.jobId;

    print("📤 Sending jobId: $jobId");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final uri =
          applied
              ? Uri.parse(
                '${baseUrl}applications/apply/cancel/$jobId',
              ) // DELETE
              : Uri.parse('${baseUrl}applications/apply'); // POST

      final response =
          applied
              ? await http.delete(uri, headers: headers)
              : await http.post(
                uri,
                headers: headers,
                body: jsonEncode({'jobId': jobId}),
              );
      //{'jobId': jobId.toString()}
      if (response.statusCode == 200) {
        setState(() => applied = !applied); // Toggle the applied state

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
      print("❌ Application error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Сүлжээний алдаа')));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final salaryLabel = job.salaryType == 'daily' ? '/ өдөр' : '/ цаг';
    final startDate =
        job.startDate.split('-').sublist(1).join('-').split('T')[0];
    final endDate = job.endDate.split('-').sublist(1).join('-').split('T')[0];

    return Card(
      elevation: AppSpacing.cardElevation,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employer Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.employerName, style: AppTextStyles.body),
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(job.postedAgo, style: AppTextStyles.subtitle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(job.location),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text('${job.salary.amount ?? 0}₮ $salaryLabel'),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.group, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Ажиллах хүн: ${job.capacity}'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$startDate -> $endDate', style: AppTextStyles.subtitle),
                ElevatedButton(
                  onPressed:
                      loading
                          ? null
                          : () async {
                            await _toggleApplication();
                            if (widget.onRefresh != null) {
                              widget.onRefresh!(); // call parent refresh
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        applied ? Colors.grey.shade300 : AppColors.primary,
                    foregroundColor: applied ? AppColors.text : Colors.white,
                  ),
                  child:
                      loading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(applied ? 'Илгээсэн' : 'Илгээх'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
