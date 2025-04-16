import 'package:flutter/material.dart';
import '../../constant/styles.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late Future<UserModel> futureUser;
  bool isEditing = false;
  Map<String, TextEditingController> controllers = {};
  UserModel? user;

  bool isJobEditing = false;
  Map<String, TextEditingController> jobControllers = {};

  bool isSkillEditing = false;
  final TextEditingController skillInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureUser = UserService.fetchUser();
  }

  void startEditing(UserModel userData) {
    setState(() {
      isEditing = true;
      controllers = {
        for (var entry in userData.personal.entries)
          entry.key: TextEditingController(text: entry.value),
      };
    });
  }

  void saveChanges() async {
    if (user == null) return;

    final updated = {
      for (var key in controllers.keys) key: controllers[key]!.text,
    };

    final updatedUser = UserModel(
      name: user!.name,
      role: user!.role,
      email: user!.email,
      phone: user!.phone,
      personal: updated,
      jobInfo: user!.jobInfo,
      skills: user!.skills,
      isVerified: user!.isVerified,
    );

    await UserService.updateUser(updatedUser);
    setState(() {
      user = updatedUser;
      isEditing = false;
    });
  }

  void startJobEditing(Map<String, String> jobData) {
    setState(() {
      isJobEditing = true;
      jobControllers = {
        for (var entry in jobData.entries)
          entry.key: TextEditingController(text: entry.value),
      };
    });
  }

  void saveJobChanges() async {
    if (user == null) return;

    final updatedJob = {
      for (var key in jobControllers.keys) key: jobControllers[key]!.text,
    };

    final updatedUser = UserModel(
      name: user!.name,
      role: user!.role,
      email: user!.email,
      phone: user!.phone,
      personal: user!.personal,
      jobInfo: updatedJob,
      skills: user!.skills,
      isVerified: user!.isVerified,
    );

    await UserService.updateUser(updatedUser);
    setState(() {
      user = updatedUser;
      isJobEditing = false;
    });
  }

  void addSkill(String skill) {
    if (skill.trim().isEmpty) return;
    setState(() {
      user!.skills.add(skill.trim());
      skillInputController.clear();
    });
  }

  void removeSkill(String skill) {
    setState(() {
      user!.skills.remove(skill);
    });
  }

  void verifyUser() async {
    if (user == null) return;

    final updatedUser = UserModel(
      name: user!.name,
      role: user!.role,
      email: user!.email,
      phone: user!.phone,
      personal: user!.personal,
      jobInfo: user!.jobInfo,
      skills: user!.skills,
      isVerified: true,
    );

    await UserService.updateUser(updatedUser);
    setState(() {
      user = updatedUser;
    });
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    for (var controller in jobControllers.values) {
      controller.dispose();
    }
    skillInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Профайл"),
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 12),
          Icon(Icons.settings),
          SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<UserModel>(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Алдаа гарлаа."));
          }

          if (snapshot.hasData) {
            user ??= snapshot.data!;
            final personal = user!.personal;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _header(user!),
                  const SizedBox(height: AppSpacing.lg),
                  _sectionCard(
                    title: "Хувийн мэдээлэл",
                    onEdit: () => startEditing(user!),
                    children: [
                      if (isEditing)
                        Column(
                          children: [
                            ...controllers.entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: TextField(
                                  controller: entry.value,
                                  decoration: InputDecoration(
                                    labelText: entry.key,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Хадгалах"),
                            ),
                          ],
                        )
                      else if (personal.isEmpty)
                        const Text("Хувийн мэдээлэл оруулаагүй байна.")
                      else
                        ...personal.entries.map(
                          (e) => _infoRow(e.key, e.value),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _sectionCard(
                    title: "Ажлын мэдээлэл",
                    onEdit: () => startJobEditing(user!.jobInfo),
                    children: [
                      if (isJobEditing)
                        Column(
                          children: [
                            ...jobControllers.entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: TextField(
                                  controller: entry.value,
                                  decoration: InputDecoration(
                                    labelText: entry.key,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: saveJobChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Хадгалах"),
                            ),
                          ],
                        )
                      else
                        ...user!.jobInfo.entries.map(
                          (e) => _infoRow(e.key, e.value),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _sectionCard(
                    title: "Ур чадвар",
                    onEdit: () {
                      setState(() {
                        isSkillEditing = !isSkillEditing;
                      });
                    },
                    children: [
                      if (isSkillEditing) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: skillInputController,
                                decoration: const InputDecoration(
                                  hintText: "Шинэ ур чадвар...",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed:
                                  () => addSkill(skillInputController.text),
                              child: const Text("Нэмэх"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            user!.skills.map((skill) {
                              return Chip(
                                label: Text(skill),
                                backgroundColor: AppColors.tagColor,
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                deleteIcon:
                                    isSkillEditing
                                        ? const Icon(Icons.close, size: 18)
                                        : null,
                                onDeleted:
                                    isSkillEditing
                                        ? () => removeSkill(skill)
                                        : null,
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _sectionCard(
                    title: "Баталгаажуулалт",
                    onEdit: () {},
                    children: [
                      Row(
                        children: [
                          Icon(
                            user!.isVerified
                                ? Icons.verified
                                : Icons.error_outline,
                            color: user!.isVerified ? Colors.blue : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user!.isVerified
                                ? "Баталгаажсан"
                                : "Баталгаажаагүй",
                          ),
                          const Spacer(),
                          if (!user!.isVerified)
                            ElevatedButton(
                              onPressed: verifyUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Баталгаажуулах"),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text("Хэрэглэгчийн мэдээлэл олдсонгүй."));
        },
      ),
    );
  }

  Widget _header(UserModel user) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('assets/images/avatar.png'),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(user.name, style: AppTextStyles.heading),
        const SizedBox(height: AppSpacing.xs),
        Text(user.role, style: AppTextStyles.subtitle),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(user.email),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(user.phone),
          ],
        ),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required VoidCallback onEdit,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(title, style: AppTextStyles.heading),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
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
          const Icon(Icons.label_important, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text("$label: $value")),
        ],
      ),
    );
  }
}
