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

    _buildTabContent("Pending");
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          // Trigger a rebuild to fetch data for the selected tab
          _buildTabContent(_getStatusFromTabIndex(_tabController.index));
        });
      }
    });
  }

  @override
  void dispose() {
    // Dispose of the TabController to avoid memory leaks
    _tabController.dispose();
    super.dispose();
  }

  String _getStatusFromTabIndex(int index) {
    switch (index) {
      case 0:
        return "Pending";
      case 1:
        return "Accepted";
      case 2:
        return "Rejected";
      default:
        return "Pending";
    }
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
      final result = jsonDecode(response.body);

      // Шалгалт: data['jobs'] нь null эсвэл хоосон эсэх
      if (result['data'] == null || result['data'] is! List) {
        return [];
      }
      print("Fetched jobs: ${result['data']}");
      return List<Map<String, dynamic>>.from(result['data']);
    } else {
      // Алдаа гарсан тохиолдолд энд хариу өгнө
      print("Error fetching applications: ${response.statusCode}");
      return [];
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
    //final bool isMainTab = ModalRoute.of(context)?.isFirst ?? false;

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: CustomScrollView(
          slivers: [
            CustomSliverAppBar(
              showTabs: true,
              showBack: false, // ✅ back arrow зөвхөн stack navigation-д
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
