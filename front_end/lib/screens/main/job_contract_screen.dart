import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/styles.dart';
import '../../constant/api.dart';
import '../../models/user_model.dart';

// ... (import-ууд)
class JobContractScreen extends StatefulWidget {
  final String jobId;
  final int initialTabIndex;

  const JobContractScreen({
    super.key,
    required this.jobId,
    required this.initialTabIndex,
  });

  @override
  State<JobContractScreen> createState() => _JobContractScreenState();
}

class _JobContractScreenState extends State<JobContractScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool isLoading = false;
  bool hasTemplate = false;
  bool initControllerDone = false;
  String contractHtml = '';
  String summaryHtml = '';
  String? templateId;

  final List<Map<String, String>> templates = [
    {
      "name": "Хөдөлмөрийн гэрээ",
      "templateName": "employment_contract",
      "summary": "Хөдөлмөрийн гэрээний товч танилцуулга...",
    },
    {
      "name": "Хөлсөөр ажиллуулах гэрээ",
      "templateName": "wage_contract",
      "summary": "Хөлсөөр гэрээний товч танилцуулга...",
    },
  ];

  List<UserModel> employees = [];

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);
    await checkIfContractTemplateExists();
    await fetchEmployees();

    if (hasTemplate) {
      final safeIndex = widget.initialTabIndex.clamp(0, 2);
      _tabController = TabController(
        length: 3,
        vsync: this,
        initialIndex: safeIndex,
      );
    }

    setState(() {
      isLoading = false;
      initControllerDone = true;
    });
  }

  Future<void> checkIfContractTemplateExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.get(
        Uri.parse('${baseUrl}contracts/by-job/${widget.jobId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final html = data['contractHtml'];
        final summary = data['summaryHtml'];
        final templateId = data['contractId'];
        debugPrint("✅ Template ID: $templateId");
        if (html != null && summary != null) {
          hasTemplate = true;
          contractHtml = html;
          summaryHtml = summary;
          this.templateId = templateId; // ⬅️ зөв хадгалалт
          // debugPrint("✅ Contract HTML: $contractHtml");
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching contract: $e');
    }
  }

  Future<void> fetchEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.get(
        Uri.parse('${baseUrl}jobs/${widget.jobId}/employers'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> list = data['employers'] ?? [];
        setState(() {
          employees = list.map((e) => UserModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('❌ Exception while fetching employees: $e');
    }
  }

  Future<void> _generateTemplateAndSign(String templateName) async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final genResponse = await http.post(
        Uri.parse('${baseUrl}contracts/generate-template'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'jobId': widget.jobId, 'templateName': templateName}),
      );

      if (genResponse.statusCode == 200) {
        final json = jsonDecode(genResponse.body);
        final html = json['html'];

        /// ❗ ЭНЭ ХЭСЭГ ЧУХАЛ
        this.templateId = json['templateId']; // ⬅️ зөв хадгалалт
        debugPrint("✅ Template ID хадгалагдлаа: $templateId");

        _showContractPreview(html);
      } else {
        debugPrint("❌ Failed to generate: ${genResponse.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Гэрээ үүсгэхэд алдаа гарлаа.")),
        );
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _signTemplate() async {
    if (templateId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${baseUrl}contracts/template/$templateId/employer-sign'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Гэрээ амжилттай баталгаажлаа")),
        );
      } else {
        debugPrint("❌ Failed to sign: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Sign error: $e");
    }
  }

  Future<void> _sendContractsToWorkers() async {
    if (templateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Гэрээний загвар үүсээгүй байна.")),
      );
      return;
    }

    if (employees.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Илгээх ажилтан алга.")));
      return;
    }

    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final employeeIds = employees.map((e) => e.id).toList();

      final res = await http.post(
        Uri.parse('${baseUrl}contracts/template/$templateId/send'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'jobId': widget.jobId, 'employeeIds': employeeIds}),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Гэрээнүүд амжилттай илгээгдлээ!")),
        );
      } else {
        debugPrint("❌ Failed to send contracts: ${res.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Гэрээ илгээхэд алдаа гарлаа.")),
        );
      }
    } catch (e) {
      debugPrint("❌ Exception while sending: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Сүлжээний алдаа. Дахин оролдоно уу.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showContractPreview(String html) {
    bool isChecked = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SizedBox(
                height: 600,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "Гэрээний загвар",
                        style: AppTextStyles.heading,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(html, style: AppTextStyles.body),
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text("Би гэрээний нөхцөлийг зөвшөөрч байна"),
                      value: isChecked,
                      onChanged: (value) {
                        setModalState(() => isChecked = value!);
                      },
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Татгалзах"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  isChecked
                                      ? () async {
                                        await _signTemplate();
                                        Navigator.pop(context);
                                        // ❌ _sendContractsToWorkers() энд байх ёсгүй
                                      }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isChecked ? AppColors.primary : Colors.grey,
                              ),
                              child: const Text("Батлах"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmployeesTab() {
    if (employees.isEmpty) {
      return const Center(child: Text("Ажилчид одоогоор олдсонгүй."));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final user = employees[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user.name),
                  subtitle: Text("Утас: ${user.phone ?? 'Мэдэгдэхгүй'}"),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () async {
              final confirmed = await _confirmSendDialog();
              if (confirmed) {
                await _sendContractsToWorkers(); // ✅ зөв газар
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text("Гэрээ илгээх"),
          ),
        ),
      ],
    );
  }

  Future<bool> _confirmSendDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Гэрээ илгээх"),
              content: const Text(
                "Ажилчдад гэрээ илгээхдээ итгэлтэй байна уу?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Үгүй"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Тийм"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _contractItem(String title, String desc, String templateName) {
    return Column(
      children: [
        Text(title, style: AppTextStyles.heading),
        const SizedBox(height: 4),
        Text(desc, textAlign: TextAlign.center, style: AppTextStyles.subtitle),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _generateTemplateAndSign(templateName),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text("Сонгох", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTemplateSelectionScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text("Гэрээний загвар сонгох")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Та гэрээний загварыг сонгоно уу",
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: 20),
            Row(
              children: List.generate(templates.length, (index) {
                return Expanded(
                  child: _contractItem(
                    templates[index]['name']!,
                    templates[index]['summary']!,
                    templates[index]['templateName']!,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || (hasTemplate && !initControllerDone)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return hasTemplate
        ? _buildExistingContractTabs()
        : _buildTemplateSelectionScreen();
  }

  Widget _buildExistingContractTabs() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Гэрээний удирдлага"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "Гэрээ"),
            Tab(text: "Хураангуй"),
            Tab(text: "Ажилчид"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _contractHtmlView(contractHtml),
          _contractHtmlView(summaryHtml),
          _buildEmployeesTab(),
        ],
      ),
    );
  }

  Widget _contractHtmlView(String html) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(html, style: AppTextStyles.body),
    );
  }
}
