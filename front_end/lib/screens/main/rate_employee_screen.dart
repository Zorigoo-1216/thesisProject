import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/api.dart';
import '../../constant/styles.dart';
import '../../widgets/custom_sliver_app_bar.dart';
import '../../models/rate_worker.dart';

class RateEmployeeScreen extends StatefulWidget {
  final String jobId;
  const RateEmployeeScreen({super.key, required this.jobId});

  @override
  State<RateEmployeeScreen> createState() => _RateEmployeeScreenState();
}

class _RateEmployeeScreenState extends State<RateEmployeeScreen> {
  List<RateWorker> workers = [];
  List<bool> isExpanded = [];
  List<double> ratings = [];
  List<bool> isRated = [];
  List<TextEditingController> commentControllers = [];
  bool loading = true;
  String jobType = '';

  @override
  void initState() {
    super.initState();
    loadRateWorkers();
  }

  Future<void> loadRateWorkers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final res = await http.get(
        Uri.parse('${baseUrl}ratings/job/${widget.jobId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final List<dynamic> list = data['data'];
        setState(() {
          workers = list.map((e) => RateWorker.fromJson(e)).toList();
          isExpanded = List.generate(workers.length, (_) => false);
          ratings = List.generate(workers.length, (_) => 0.0);
          isRated = List.generate(workers.length, (_) => false);
          commentControllers = List.generate(
            workers.length,
            (_) => TextEditingController(),
          );
          // ⬇️ энд нэмнэ:
          if (list.isNotEmpty && list[0]['jobType'] != null) {
            jobType = list[0]['jobType']; // jobType-г авч хадгална
          }
          loading = false;
        });
      } else {
        debugPrint("⚠️ RateWorker fetch failed: ${data['message']}");
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint('❌ Exception loading workers: $e');
      setState(() => loading = false);
    }
  }

  void handleRating(int index, double rating) {
    if (isRated[index]) return;
    setState(() => ratings[index] = rating);
  }

  Future<void> submitRating(int index) async {
    if (isRated[index]) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final worker = workers[index];

    final score = ratings[index];
    final comment = commentControllers[index].text;

    if (score == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Оноо өгнө үү")));
      return;
    }

    final body = jsonEncode({
      'employeeId': worker.id,
      'rating': {'score': score, 'comment': comment, 'branchType': ""},
    });

    try {
      final res = await http.post(
        Uri.parse('${baseUrl}ratings/job/${widget.jobId}/employee'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 201 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${worker.name} үнэлгээ илгээгдлээ')),
        );
        setState(() {
          isExpanded[index] = false;
          isRated[index] = true;
        });
      } else {
        debugPrint("⚠️ Rating failed: ${data['message']}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Алдаа: ${data['message']}')));
      }
    } catch (e) {
      debugPrint("❌ Rating exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Үнэлгээ илгээхэд алдаа гарлаа')),
      );
    }
  }

  Widget buildStarRow(int index) {
    return Row(
      children: List.generate(5, (i) {
        return IconButton(
          onPressed: () => handleRating(index, i + 1),
          icon: Icon(
            Icons.star,
            color:
                ratings[index] >= i + 1
                    ? AppColors.primary
                    : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    for (var controller in commentControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(showTabs: false, showBack: true, tabs: []),
          SliverToBoxAdapter(
            child:
                loading
                    ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : workers.isEmpty
                    ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text("Үнэлгээ өгөх ажилчин алга")),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: workers.length,
                        itemBuilder: (context, index) {
                          final worker = workers[index];
                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radius,
                              ),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const CircleAvatar(
                                    backgroundImage: AssetImage(
                                      'assets/images/avatar.png',
                                    ),
                                    radius: 28,
                                  ),
                                  title: Text(worker.name),
                                  subtitle: Text(worker.phone),
                                  trailing: IconButton(
                                    icon: Icon(
                                      isExpanded[index]
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isExpanded[index] = !isExpanded[index];
                                      });
                                    },
                                  ),
                                ),
                                if (isExpanded[index])
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm,
                                    ),
                                    child:
                                        isRated[index]
                                            ? const Text(
                                              "Та энэ ажилчныг үнэлсэн байна",
                                              style: TextStyle(
                                                color: AppColors.subtitle,
                                              ),
                                            )
                                            : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                buildStarRow(index),
                                                Text(
                                                  "${ratings[index]} оноо",
                                                  style: const TextStyle(
                                                    color: AppColors.subtitle,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                TextField(
                                                  controller:
                                                      commentControllers[index],
                                                  enabled: !isRated[index],
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "Сэтгэгдэл бичих...",
                                                    filled: true,
                                                    fillColor:
                                                        Colors.grey.shade100,
                                                    suffixIcon: IconButton(
                                                      icon: const Icon(
                                                        Icons.send,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                      onPressed:
                                                          () => submitRating(
                                                            index,
                                                          ),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            AppSpacing.radius,
                                                          ),
                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
