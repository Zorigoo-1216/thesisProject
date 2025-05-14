import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/styles.dart';
import '../../widgets/category_item.dart';
//import '../../widgets/job_card.dart';
import '../../widgets/custom_sliver_app_bar.dart';
import '../../models/job_model.dart';
import '../../models/user_model.dart';
import '../../constant/api.dart';
import '../../widgets/job_card.dart';
import '../../widgets/user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  List<UserModel> workers = [];
  List<Job> jobs = [];
  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final loadedWorkers = await fetchWorkers();
    final loadedJobs = await fetchJobs();

    setState(() {
      workers = loadedWorkers;
      jobs = loadedJobs;
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    print('🔥 Ачаалсан нэр: $name');

    // ✂️ Нэрийг задалж, эхний үгийг авах
    final firstName = (name ?? 'Хэрэглэгч').split(RegExp(r'\s+')).first;

    setState(() {
      userName = firstName;
    });
  }

  Future<List<UserModel>> fetchWorkers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return [];

    final url = Uri.parse('${baseUrl}auth/workers');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body)['workers'] ?? [];
      print('🔥 Ажилчид: $decoded');
      return decoded
          .map((e) => e['viewUserDTO']) // зөв DTO-г задлах
          .where((e) => e != null) // null хамгаалалт
          .map((e) => UserModel.fromJson(e))
          .toList();
    } else {
      print("❌ fetchWorkers failed: ${response.statusCode}");
      return [];
    }
  }

  Future<List<Job>> fetchJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return [];

    final url = Uri.parse('${baseUrl}jobs/topjobs');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body)['jobs'] ?? [];
      return decoded.map((e) => Job.fromJson(e)).toList();
    } else {
      print("❌ fetchJobs failed: ${response.statusCode}");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    //final bool isMainTab = ModalRoute.of(context)?.isFirst ?? false;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(showTabs: true, showBack: false, tabs: []),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Сайн уу $userName 👋', style: AppTextStyles.heading),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo.png', // 🔥 зөв зам
                          height: 300,
                          width: 300,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Таны ажил болон хэрэгцээний хөтөч',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // 💼 Эрэлттэй салбарууд
                  const Text(
                    'Эрэлттэй салбарууд',
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceEvenly, // flex: space-evenly
                    children: const [
                      CategoryItem(icon: Icons.apartment, label: 'Барилга'),
                      CategoryItem(
                        icon: Icons.restaurant,
                        label: 'Зоогийн газар',
                      ),
                      CategoryItem(icon: Icons.factory, label: 'Үйлдвэр'),
                      CategoryItem(
                        icon: Icons.local_shipping,
                        label: 'Худалдаа',
                      ),
                      CategoryItem(icon: Icons.directions_car, label: 'Засвар'),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 👷 Өндөр үнэлгээтэй ажилчид
                  const Text(
                    'Өндөр үнэлгээтэй ажилчид',
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 150,
                    child:
                        workers.isEmpty
                            ? const Center(child: Text('Ажилтан олдсонгүй'))
                            : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: workers.length,
                              itemBuilder:
                                  (context, index) =>
                                      UserCard(user: workers[index]),
                            ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 📋 Ажлын зарууд
                  const Text('Ажлын зарууд', style: AppTextStyles.heading),
                  const SizedBox(height: AppSpacing.sm),
                  Column(
                    children:
                        jobs.isEmpty
                            ? [const Text('Ажлын зар олдсонгүй')]
                            : jobs.map((job) => JobCard(job: job)).toList(),
                  ),
                  //...dummyJobs.map((job) => JobCard(job: job)).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
