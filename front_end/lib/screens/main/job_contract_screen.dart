import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../constant/styles.dart';
import '../../constant/api.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_sliver_app_bar.dart';

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
      "summary":
          "Ажилтны байнгын хөдөлмөр эрхлэх нөхцөл, үүрэг, цалин хөлс, нийгмийн даатгалын зохицуулалт. Ажлын байрны тодорхойлолт, ажиллах цагийн хуваарь, ажлын аюулгүй байдал болон тэтгэмжийн талаар тусгасан.",
    },
    {
      "name": "Хөлсөөр ажиллуулах гэрээ",
      "templateName": "wage_contract",
      "summary":
          "Тодорхой хугацааны туршид гүйцэтгэх ажил, үйлчилгээний нөхцөл, хөлс төлөлт, үүрэг хариуцлага. Ажил гүйцэтгэгчийн эрх, ажил олгогчийн үүрэг, гэрээ дуусгавар болох нөхцөл болон төлбөрийн зохицуулалтыг багтаасан.",
    },
  ];

  List<UserModel> employees = [];

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Хуудас руу орох бүрт мэдээллийг шинэчлэх
    setState(() {
      isLoading = true;
    });
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    setState(() {
      isLoading = true;
      initControllerDone = false;
    });

    await checkIfContractTemplateExists();
    await fetchEmployees();

    if (hasTemplate && _tabController == null) {
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
        final summary = json['summary'];

        // Хадгалахгүй. Зөвхөн preview
        await _showContractPreview(html, summary, templateName);
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

  Future<void> _saveTemplate(
    String templateName,
    String html,
    String summary,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${baseUrl}contracts/createtemplate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'jobId': widget.jobId,
          'templateName': templateName,
          'contentHTML': html,
          'summary': summary,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final id = json['templateId'];

        setState(() {
          hasTemplate = true;
          templateId = id;
          contractHtml = html;
          summaryHtml = summary;

          _tabController = TabController(
            length: 3,
            vsync: this,
            initialIndex: 0,
          );

          initControllerDone =
              true; // ✅ controller үүссэн гэдгийг баталгаажуулсан
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Гэрээ амжилттай батлагдлаа")),
        );
      } else {
        debugPrint('❌ Failed to save template: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Гэрээ хадгалахад алдаа гарлаа.")),
        );
      }
    } catch (e) {
      debugPrint('❌ Exception saving template: $e');
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

  Future<void> _showContractPreview(
    String html,
    String summary,
    String templateName,
  ) async {
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
                                        await _saveTemplate(
                                          templateName,
                                          html,
                                          summary,
                                        );
                                        Navigator.pop(context);
                                      }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    //isChecked ? AppColors.primary : Colors.grey,
                                    isChecked ? AppColors.primary : Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                "Батлах",
                                //style: TextStyle(color: Colors.white),
                              ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    "Тийм",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
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
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
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
            child: const Text(
              "Гэрээ илгээх",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _contractItem(String title, String desc, String templateName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.description, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.heading.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              desc,
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _generateTemplateAndSign(templateName),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                "Сонгох",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSelectionScreen() {
    final bool isMainTab = ModalRoute.of(context)?.isFirst ?? false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(showTabs: false, showBack: !isMainTab),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Та гэрээний загварыг сонгоно уу",
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: 20),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: templates.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                    itemBuilder: (context, index) {
                      final item = templates[index];
                      return _contractItem(
                        item['name']!,
                        item['summary']!,
                        item['templateName']!,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      "🔄 build: isLoading=$isLoading | hasTemplate=$hasTemplate | initControllerDone=$initControllerDone | tabController=${_tabController != null}",
    );

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasTemplate && (!initControllerDone || _tabController == null)) {
      return const Scaffold(
        body: Center(child: Text("Гэрээ ачааллаж байна...")),
      );
    }

    return hasTemplate
        ? _buildExistingContractTabs()
        : _buildTemplateSelectionScreen();
  }

  Widget _buildExistingContractTabs() {
    final bool isMainTab = ModalRoute.of(context)?.isFirst ?? false;
    if (_tabController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              CustomSliverAppBar(
                tabController: _tabController,
                showTabs: true,
                showBack: !isMainTab,
                tabs: const [
                  Tab(text: "Гэрээ"),
                  Tab(text: "Хураангуй"),
                  Tab(text: "Ажилчид"),
                ],
              ),
            ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _contractHtmlView(contractHtml),
            _contractHtmlView(summaryHtml),
            _buildEmployeesTab(),
          ],
        ),
      ),
    );
  }

  Widget _contractHtmlView(String html) {
    debugPrint("HTML Content: $html");
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Html(
        data: html,
        style: {
          "body": Style(
            fontSize: FontSize.medium,
            lineHeight: LineHeight.number(1.6),
            fontWeight: FontWeight.normal,
          ),
        },
      ),
    );
  }
}
