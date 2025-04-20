import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constant/styles.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class EmployeeContractScreen extends StatefulWidget {
  const EmployeeContractScreen({super.key});

  @override
  State<EmployeeContractScreen> createState() => _EmployeeContractScreenState();
}

class _EmployeeContractScreenState extends State<EmployeeContractScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isSigned = false;
  String contractHtml = "";
  String summaryHtml = "";
  bool isLoading = true;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    fetchContractData();
    super.initState();
  }

  Future<void> fetchContractData() async {
    try {
      final response = await http.get(
        Uri.parse('https://yourapi.com/api/contract/detail'),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN', // 🔐 Replace with actual token
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          contractHtml = data['contractHtml'] ?? "";
          summaryHtml = data['summaryHtml'] ?? "";
          isSigned = data['isSigned'] ?? false;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching contract: $e");
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
          const CustomSliverAppBar(showTabs: false, showBack: true),
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
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Accept contract API
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                        onPressed: () {
                          // TODO: Reject logic
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
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
