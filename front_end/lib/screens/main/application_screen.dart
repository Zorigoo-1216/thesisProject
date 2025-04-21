import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/api.dart';
import '../../constant/styles.dart';
import '../../widgets/job_application_card.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class ApplicationScreen extends StatefulWidget {
  const ApplicationScreen({super.key});

  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<List<Map<String, dynamic>>> fetchApplications(String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final realStatus = status.toLowerCase();
    final response = await http.get(
      Uri.parse('${baseUrl}applications/myapplications?status=$realStatus'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['jobs']);
    } else {
      throw Exception("Хүсэлтүүдийг татахад алдаа гарлаа");
    }
  }

  Widget _buildTabContent(String status) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchApplications(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Алдаа гарлаа: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Хүсэлт олдсонгүй"));
        }

        final jobs = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return JobApplicationCard(job: job);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: CustomScrollView(
          slivers: [
            CustomSliverAppBar(
              showTabs: true,
              showBack: true,
              tabController: _tabController,
              tabs: const [
                Tab(text: "Хүлээгдэж буй"),
                Tab(text: "Зөвшөөрсөн"),
                Tab(text: "Татгалзсан"),
              ],
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent("Pending"),
                  _buildTabContent("Accepted"),
                  _buildTabContent("Rejected"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
