import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/job_model.dart';
import '../../constant/api.dart';
import '../../constant/styles.dart';
import '../../widgets/job_card.dart';
import '../../widgets/custom_sliver_app_bar.dart';
import '../../screens/main/job_filter_sheet_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  List<Job> jobList = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchAllJobs(); // Default fetch all
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      _searchJobsByTitle({'title': query});
    });
  }

  Future<void> _fetchAllJobs() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

      if (token == null || userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Нэвтрэх шаардлагатай')));
        return;
      }

      final uri = Uri.parse('${baseUrl}jobs').replace(
        queryParameters: {
          'userId': userId, // ✅ Send userId
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token', // ✅ Send token
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List jobs = data['jobs'] ?? [];
        setState(() {
          jobList = jobs.map((json) => Job.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("Fetch failed: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching jobs: $e");
    }
  }

  Future<void> _searchJobs(Map<String, dynamic> filters) async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    if (token == null || userId == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Нэвтрэх шаардлагатай')));
      return; // ❗ Алдаа байгаа тул энд зогсооно
    }
    final uri = Uri.parse('${baseUrl}jobs/search').replace(
      queryParameters: {
        'userId': userId,
        if (filters['title'] != null && filters['title'].isNotEmpty)
          'title': filters['title'],
        if (filters['category'] != null) 'branchType': filters['category'],
        if (filters['location'] != null) 'location': filters['location'],
        if (filters['isPartTime']) 'jobType': 'part-time',
        if (filters['isFullTime']) 'jobType': 'full-time',
        'salaryMin': filters['minSalary']?.toInt().toString(),
        'salaryMax': filters['maxSalary']?.toInt().toString(),
      },
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      final List jobs = data['jobs'] ?? [];
      setState(() {
        jobList = jobs.map((json) => Job.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error searching jobs: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _searchJobsByTitle(Map<String, dynamic> filters) async {
    setState(() => isLoading = true);

    final uri = Uri.parse('${baseUrl}jobs/searchByTitle').replace(
      queryParameters: {
        if (filters['title'] != null && filters['title'].isNotEmpty)
          'title': filters['title'],
      },
    );

    try {
      final response = await http.get(uri);
      final data = jsonDecode(response.body);
      final List jobs = data['jobs'] ?? [];
      setState(() {
        jobList = jobs.map((json) => Job.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error searching jobs by title: $e");
      setState(() => isLoading = false);
    }
  }

  void _openFilter() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const JobFilterSheet(),
    );

    if (result != null && result is Map<String, dynamic>) {
      await _searchJobs(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(showTabs: false, showBack: false),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController, // ✅ FIXED
                      decoration: InputDecoration(
                        hintText: 'Ажил хайх...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radius,
                          ),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _openFilter,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppColors.stateBackground,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                      ),
                      child: const Icon(Icons.tune, color: AppColors.iconColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (jobList.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'Одоогоор зарлагдсан ажил байхгүй байна.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  child: JobCard(job: jobList[index], onRefresh: _fetchAllJobs),
                );
              }, childCount: jobList.length),
            ),
        ],
      ),
    );
  }
}
