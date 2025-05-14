import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constant/styles.dart';
import '../../constant/api.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_sliver_app_bar.dart';

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

  List<String> selectedLicenses = [];
  final branches = ['Барилга', 'Цэвэрлэгээ', 'Үйлдвэр', 'Худалдаа'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUser();
  }

  void _initializeControllers() {
    birthDateController = TextEditingController();
    identityController = TextEditingController();
    locationController = TextEditingController();
    branchController = TextEditingController();
    experienceController = TextEditingController();
    salaryController = TextEditingController();
    languageController = TextEditingController();
    skillController = TextEditingController();
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
      final loadedUser = UserModel.fromJson(data['data']['data']);
      setState(() {
        user = loadedUser;
        isVerified = loadedUser.isVerified;
        selectedLicenses = List<String>.from(
          loadedUser.profile?.driverLicense ?? [],
        );
        _populateControllers(loadedUser);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _populateControllers(UserModel user) {
    birthDateController.text = user.profile?.birthDate ?? '';
    identityController.text = user.profile?.identityNumber ?? '';
    locationController.text = user.profile?.location ?? '';
    branchController.text = user.profile?.mainBranch ?? '';
    experienceController.text = user.profile?.experienceLevel ?? '';
    salaryController.text = user.profile?.waitingSalaryPerHour.toString() ?? '';
    languageController.text = user.profile?.languageSkills.join(', ') ?? '';
    skillController.clear();
  }

  Future<void> _saveChanges() async {
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final updatedProfile = {
      'birthDate': birthDateController.text,
      'identityNumber': identityController.text,
      'location': locationController.text,
      'mainBranch': branchController.text,
      'experienceLevel': experienceController.text,
      'waitingSalaryPerHour': double.tryParse(salaryController.text),
      'languageSkills':
          languageController.text.split(',').map((e) => e.trim()).toList(),
      'skills': user!.profile?.skills ?? [],
      'isVerified': isVerified,
      'driverLicense': selectedLicenses,
    };

    final response = await http.put(
      Uri.parse('${baseUrl}auth/profile/${user!.id}/update'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'profile': updatedProfile}),
    );

    if (response.statusCode == 200) {
      setState(() {
        isEditing = false;
        isLoading = true;
      });
      await _loadUser();
    }
  }

  void _addSkill() {
    final newSkill = skillController.text.trim();
    if (newSkill.isNotEmpty && user != null) {
      setState(() {
        user!.profile!.skills.add(newSkill);
        skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    if (user != null && user!.profile!.skills.contains(skill)) {
      setState(() {
        user!.profile!.skills.remove(skill);
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : user == null
              ? const Center(child: Text("Хэрэглэгчийн мэдээлэл олдсонгүй."))
              : _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    //final bool isMainTab = ModalRoute.of(context)?.isFirst ?? false;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          CustomSliverAppBar(showTabs: false, showBack: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  _buildPersonalInfoCard(),
                  _buildWorkInfoCard(),
                  _buildSkillsCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildAppBar() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       IconButton(
  //         icon: const Icon(Icons.arrow_back),
  //         onPressed: () => Navigator.pop(context),
  //       ),
  //       const Text(
  //         'Профайл',
  //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //       ),
  //       const Row(
  //         children: [
  //           Icon(Icons.notifications_none),
  //           SizedBox(width: 12),
  //           Icon(Icons.settings),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/avatar.png'),
          ),
          const SizedBox(height: 8),
          Text(user!.name, style: AppTextStyles.heading),
          Text(user!.profile?.mainBranch ?? '-', style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        _buildInfoRow(Icons.email, user!.email ?? '-'),
        _buildInfoRow(Icons.phone, user!.phone ?? '-'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return _buildCardSection(
      title: "Хувийн мэдээлэл",
      children: [
        if (isEditing) _buildEditablePersonalInfo(),
        if (!isEditing) _buildPersonalInfoDisplay(),
      ],
    );
  }

  Widget _buildEditablePersonalInfo() {
    return Column(
      children: [
        _buildDateField("Төрсөн огноо", birthDateController),
        _buildField("Регистр", identityController),
        _buildField("Гэрийн хаяг", locationController),
        _buildDropdownField("Үндсэн салбар", branchController, branches),
        SwitchListTile(
          title: const Text("Баталгаажуулсан эсэх"),
          value: isVerified,
          onChanged: (val) => setState(() => isVerified = val),
        ),
        _buildLicenseSection(),
        ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text("Хадгалах", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildLicenseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Жолооны үнэмлэх", style: AppTextStyles.subtitle),
        ...['B', 'C', 'D'].map(
          (type) => CheckboxListTile(
            title: Text("Ангилал $type"),
            value: selectedLicenses.contains(type),
            onChanged:
                (val) => setState(() {
                  val!
                      ? selectedLicenses.add(type)
                      : selectedLicenses.remove(type);
                }),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoDisplay() {
    return Column(
      children: [
        _buildInfoDisplayRow("Төрсөн огноо", user!.profile?.birthDate ?? '-'),
        _buildInfoDisplayRow("Регистр", user!.profile?.identityNumber ?? '-'),
        _buildInfoDisplayRow("Гэрийн хаяг", user!.profile?.location ?? '-'),
        _buildInfoDisplayRow("Хүйс", user!.gender ?? '-'),
        _buildInfoDisplayRow(
          "Баталгаажуулсан",
          user!.isVerified ? 'Тийм' : 'Үгүй',
        ),
        _buildInfoDisplayRow(
          "Жолооны үнэмлэх",
          user!.profile?.driverLicense.join(", ") ?? 'Байхгүй',
        ),
      ],
    );
  }

  Widget _buildWorkInfoCard() {
    return _buildCardSection(
      title: "Ажлын мэдээлэл",
      children: [
        if (isEditing) _buildEditableWorkInfo(),
        if (!isEditing) _buildWorkInfoDisplay(),
      ],
    );
  }

  Widget _buildEditableWorkInfo() {
    return Column(
      children: [
        _buildField("Туршлага", experienceController),
        _buildField("Цалин (₮/цаг)", salaryController, isNumber: true),
        _buildField("Хэлний чадварууд", languageController),
      ],
    );
  }

  Widget _buildWorkInfoDisplay() {
    return Column(
      children: [
        _buildInfoDisplayRow("Үндсэн салбар", user!.profile?.mainBranch ?? '-'),
        _buildInfoDisplayRow("Туршлага", user!.profile?.experienceLevel ?? '-'),
        _buildInfoDisplayRow(
          "Цалин",
          "${user!.profile?.waitingSalaryPerHour.toStringAsFixed(0) ?? '-'}₮/цаг",
        ),
        _buildInfoDisplayRow(
          "Хэл",
          user!.profile?.languageSkills.join(', ') ?? '-',
        ),
      ],
    );
  }

  Widget _buildSkillsCard() {
    return _buildCardSection(
      title: "Ур чадвар",
      children: [if (isEditing) _buildSkillInput(), _buildSkillChips()],
    );
  }

  Widget _buildSkillInput() {
    return Row(
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
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _addSkill,
          child: const Text("Нэмэх", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSkillChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          user!.profile?.skills
              .map(
                (skill) => Chip(
                  label: Text(skill),
                  backgroundColor: AppColors.tagColor,
                  deleteIcon:
                      isEditing ? const Icon(Icons.close, size: 18) : null,
                  onDeleted: isEditing ? () => _removeSkill(skill) : null,
                ),
              )
              .toList() ??
          [],
    );
  }

  Widget _buildCardSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
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
              IconButton(
                icon: Icon(
                  isEditing ? Icons.save : Icons.edit,
                  color: AppColors.primary,
                ),
                onPressed:
                    () => setState(() {
                      if (isEditing) _saveChanges();
                      isEditing = !isEditing;
                    }),
              ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(controller.text) ?? DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              controller.text = "${picked.toLocal()}".split(' ')[0];
            }
          },
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : null,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildDropdownField(
    String label,
    TextEditingController controller,
    List<String> items,
  ) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) => controller.text = value ?? '',
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildInfoDisplayRow(String label, String value) {
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
