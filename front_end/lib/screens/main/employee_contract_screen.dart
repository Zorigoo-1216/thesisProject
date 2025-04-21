import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:front_end/constant/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../constant/styles.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class EmployeeContractScreen extends StatefulWidget {
  final String jobId;
  const EmployeeContractScreen({super.key, required this.jobId});

  @override
  State<EmployeeContractScreen> createState() => _EmployeeContractScreenState();
}

class _EmployeeContractScreenState extends State<EmployeeContractScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final String jobId;
  late String workerId;
  late String token;
  late String contractId;

  bool isSigned = false;
  String contractHtml = "";
  String summaryHtml = "";
  bool isLoading = true;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    jobId = widget.jobId;
    _tabController = TabController(length: 2, vsync: this);
    getWorkerIdAndFetch();
  }

  Future<void> getWorkerIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    workerId = prefs.getString('userId') ?? '';
    if (token.isNotEmpty && workerId.isNotEmpty) {
      await fetchContractData();
    } else {
      debugPrint("⚠️ Token эсвэл WorkerId байхгүй байна");
    }
  }

  Future<void> fetchContractData() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}contracts/by-job/$jobId/worker/$workerId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          contractId = data['_id']; // ⬅️ Save this
          contractHtml = data['contentHTML'] ?? "";
          summaryHtml = data['summary'] ?? "";
          isSigned = data['isSignedByWorker'] ?? false;
          isLoading = false;
        });
      } else {
        debugPrint("⚠️ Contract fetch failed: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Error fetching contract: $e");
    }
  }

  Future<void> _signContract() async {
    setState(() => isProcessing = true);
    try {
      final res = await http.put(
        Uri.parse('${baseUrl}contracts/$contractId/worker-sign'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() {
          isSigned = true;
          isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Гэрээг амжилттай баталлаа.")),
        );
      } else {
        debugPrint("❌ Failed to sign contract: ${res.body}");
        setState(() => isProcessing = false);
      }
    } catch (e) {
      debugPrint("❌ Error signing contract: $e");
      setState(() => isProcessing = false);
    }
  }

  Future<void> _rejectContract() async {
    setState(() => isProcessing = true);
    try {
      final res = await http.put(
        Uri.parse('${baseUrl}contracts/$contractId/worker-reject'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Та гэрээг татгалзлаа.")));
      } else {
        debugPrint("❌ Failed to reject contract: ${res.body}");
        setState(() => isProcessing = false);
      }
    } catch (e) {
      debugPrint("❌ Error rejecting contract: $e");
      setState(() => isProcessing = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(showTabs: false, showBack: true, tabs: []),
          SliverFillRemaining(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          indicatorColor: AppColors.primary,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: Colors.grey,
                          tabs: const [
                            Tab(text: 'Гэрээ'),
                            Tab(text: 'Гэрээний хураангуй'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _contractHtmlView(contractHtml),
                              _contractHtmlView(summaryHtml),
                            ],
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
      bottomNavigationBar:
          !isSigned && contractHtml.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child:
                    isProcessing
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _signContract,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radius,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  "Батлах",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _rejectContract,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radius,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  "Татгалзах",
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
              )
              : null,
    );
  }

  Widget _contractHtmlView(String htmlData) {
    if (htmlData.isEmpty) {
      return const Center(
        child: Text("Гэрээ үүсээгүй байна.", style: AppTextStyles.subtitle),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Html(
          data: htmlData,
          style: {
            "body": Style(
              fontSize: FontSize.medium,
              color: AppColors.text,
              fontFamily: 'Roboto',
            ),
          },
        ),
      ),
    );
  }
}
