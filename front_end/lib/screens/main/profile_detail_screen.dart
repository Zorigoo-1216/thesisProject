import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constant/styles.dart';
import '../../constant/api.dart';
import '../../models/user_model.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  UserModel? user;
  bool isLoading = true;
  bool isEditing = false;
  bool isVerified = false;

  late TextEditingController birthDateController;
  late TextEditingController identityController;
  late TextEditingController locationController;
  late TextEditingController branchController;
  late TextEditingController experienceController;
  late TextEditingController salaryController;
  late TextEditingController languageController;
  late TextEditingController skillController;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('${baseUrl}auth/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final loadedUser = UserModel.fromJson(data);
      setState(() {
        user = loadedUser;
        isVerified = loadedUser.isVerified;
        birthDateController = TextEditingController(
          text: loadedUser.profile?.birthDate ?? '',
        );
        identityController = TextEditingController(
          text: loadedUser.profile?.identityNumber ?? '',
        );
        locationController = TextEditingController(
          text: loadedUser.profile?.location ?? '',
        );
        branchController = TextEditingController(
          text: loadedUser.profile?.mainBranch ?? '',
        );
        experienceController = TextEditingController(
          text: loadedUser.profile?.experienceLevel ?? '',
        );
        salaryController = TextEditingController(
          text: loadedUser.profile?.waitingSalaryPerHour?.toString() ?? '',
        );
        languageController = TextEditingController(
          text: loadedUser.profile?.languageSkills.join(", ") ?? '',
        );
        skillController = TextEditingController();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final updatedProfile = {
      "birthDate": birthDateController.text,
      "identityNumber": identityController.text,
      "location": locationController.text,
      "mainBranch": branchController.text,
      "experienceLevel": experienceController.text,
      "waitingSalaryPerHour": double.tryParse(salaryController.text),
      "languageSkills":
          languageController.text.split(',').map((e) => e.trim()).toList(),
      "skills": user!.profile?.skills,
      "isVerified": isVerified,
    };

    final response = await http.put(
      Uri.parse('${baseUrl}profile/update'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"profile": updatedProfile}),
    );

    if (response.statusCode == 200) {
      setState(() => isEditing = false);
      _loadUser();
    }
  }

  void _addSkill() {
    final newSkill = skillController.text.trim();
    if (newSkill.isNotEmpty && user != null) {
      setState(() {
        user!.profile?.skills.add(newSkill);
        skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      user!.profile?.skills.remove(skill);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : user == null
              ? const Center(child: Text("Хэрэглэгчийн мэдээлэл олдсонгүй."))
              : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            const Text(
                              "Профайл",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Row(
                              children: [
                                Icon(Icons.notifications_none),
                                SizedBox(width: 12),
                                Icon(Icons.settings),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(
                                  'assets/images/avatar.png',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(user!.name, style: AppTextStyles.heading),
                              Text(
                                user!.profile?.mainBranch ?? '-',
                                style: AppTextStyles.subtitle,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.email,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(user!.email ?? "-"),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(user!.phone ?? "-"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _cardSection(
                          title: "Хувийн мэдээлэл",
                          editable: true,
                          onSave: _saveChanges,
                          onEdit: () => setState(() => isEditing = true),
                          children: [
                            if (isEditing)
                              Column(
                                children: [
                                  _editField(
                                    "Төрсөн огноо",
                                    birthDateController,
                                  ),
                                  _editField("Регистр", identityController),
                                  _editField("Гэрийн хаяг", locationController),
                                  _editField("Үндсэн салбар", branchController),
                                  _editField("Туршлага", experienceController),
                                  _editField("Цалин (₮/цаг)", salaryController),
                                  _editField(
                                    "Хэлний чадварууд",
                                    languageController,
                                  ),
                                  SwitchListTile(
                                    title: const Text("Баталгаажуулсан эсэх"),
                                    value: isVerified,
                                    onChanged:
                                        (val) =>
                                            setState(() => isVerified = val),
                                  ),
                                  ElevatedButton(
                                    onPressed: _saveChanges,
                                    child: const Text("Хадгалах"),
                                  ),
                                ],
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow(
                                    "Төрсөн огноо",
                                    user!.profile?.birthDate ?? '-',
                                  ),
                                  _infoRow(
                                    "Регистр",
                                    user!.profile?.identityNumber ?? '-',
                                  ),
                                  _infoRow(
                                    "Гэрийн хаяг",
                                    user!.profile?.location ?? '-',
                                  ),
                                  _infoRow("Хүйс", user!.gender ?? '-'),
                                  _infoRow(
                                    "Баталгаажуулсан эсэх",
                                    user!.isVerified ? 'Тийм' : 'Үгүй',
                                  ),
                                  _infoRow(
                                    "Хөгжлийн бэрхшээлтэй эсэх",
                                    user!.profile?.isDisabledPerson == true
                                        ? 'Тийм'
                                        : 'Үгүй',
                                  ),
                                  _infoRow(
                                    "Жолооны үнэмлэх",
                                    user!.profile?.driverLicense.join(", ") ??
                                        'Байхгүй',
                                  ),
                                ],
                              ),
                          ],
                        ),
                        _cardSection(
                          title: "Ажлын мэдээлэл",
                          editable: true,
                          onEdit: () => setState(() => isEditing = true),
                          children: [
                            _infoRow(
                              "Үндсэн салбар",
                              user!.profile?.mainBranch ?? '-',
                            ),
                            _infoRow(
                              "Туршлага",
                              user!.profile?.experienceLevel ?? '-',
                            ),
                            _infoRow(
                              "Хүсэж буй цалин",
                              "${user!.profile?.waitingSalaryPerHour?.toStringAsFixed(0) ?? '-'}₮/цаг",
                            ),
                            _infoRow(
                              "Хэл",
                              user!.profile?.languageSkills.join(', ') ?? '-',
                            ),
                          ],
                        ),
                        _cardSection(
                          title: "Ур чадвар",
                          editable: true,
                          onEdit: () => setState(() => isEditing = true),
                          children: [
                            if (isEditing) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: skillController,
                                      decoration: const InputDecoration(
                                        hintText: "Шинэ ур чадвар...",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: _addSkill,
                                    child: const Text("Нэмэх"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  user!.profile?.skills
                                      .map(
                                        (e) => Chip(
                                          label: Text(e),
                                          backgroundColor: AppColors.tagColor,
                                          labelStyle: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          deleteIcon:
                                              isEditing
                                                  ? const Icon(
                                                    Icons.close,
                                                    size: 18,
                                                  )
                                                  : null,
                                          onDeleted:
                                              isEditing
                                                  ? () => _removeSkill(e)
                                                  : null,
                                        ),
                                      )
                                      .toList() ??
                                  [],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _editField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _cardSection({
    required String title,
    required List<Widget> children,
    bool editable = false,
    VoidCallback? onEdit,
    VoidCallback? onSave,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppTextStyles.heading),
              const Spacer(),
              if (editable)
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: onEdit,
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.arrow_right, color: AppColors.primary),
          const SizedBox(width: 4),
          Expanded(child: Text("$label: $value", style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
