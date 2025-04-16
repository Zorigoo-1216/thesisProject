import 'package:flutter/material.dart';
import '../../constant/styles.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // 👤 Profile Header
            Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text("Full name", style: AppTextStyles.heading),
                const SizedBox(height: AppSpacing.xs),
                const Text("Barilgiin injener", style: AppTextStyles.subtitle),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email, color: AppColors.primary, size: 16),
                    const SizedBox(width: 4),
                    const Text("AvaSav@example.com"),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone, color: AppColors.primary, size: 16),
                    const SizedBox(width: 4),
                    const Text("98451216"),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // ✅ Rating & Projects
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _infoBox("Үнэлгээ", "4.5", icon: Icons.star),
                    const SizedBox(width: AppSpacing.sm),
                    _infoBox("Нийт ажил", "12", icon: Icons.work_outline),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // 📋 Хувийн мэдээлэл
            _sectionCard(
              title: "Хувийн мэдээлэл",
              onEdit: () {},
              children: const [
                _infoRow(Icons.calendar_today, "Төрсөн огноо: 1995-05-12"),
                _infoRow(Icons.credit_card, "Регистр: УБ12345678"),
                _infoRow(Icons.home, "Гэрийн хаяг: БЗД 14-р хороо"),
                _infoRow(Icons.male, "Хүйс : Эрэгтэй"),
                _infoRow(Icons.group, "Баталгаажуулсан эсэх : Тийм"),
                _infoRow(Icons.visibility_off, "Хөгжлийн бэрхшээлтэй : Үгүй"),
                _infoRow(Icons.directions_car, "Жолооны үнэмлэх : Байхгүй"),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // 👷 Ажлын мэдээлэл
            _sectionCard(
              title: "Ажлын мэдээлэл",
              onEdit: () {},
              children: const [
                _infoRow(Icons.business, "Үндсэн салбар : Барилга, дэд бүтэц"),
                _infoRow(Icons.school, "Туршлага : Intermediate"),
                _infoRow(Icons.monetization_on, "Хүсэж буй цалин: 8000₮/цаг"),
                _infoRow(Icons.language, "Хэл : Англи"),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // 🎯 Ур чадварууд
            _sectionCard(
              title: "Ур чадвар",
              onEdit: () {},
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    _skillChip("Swift"),
                    _skillChip("UI Design"),
                    _skillChip("iOS"),
                    _skillChip("Prototyping"),
                    _skillChip("User Testing"),
                    _skillChip("UX"),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ✅ Баталгаажуулалт
            _sectionCard(
              title: "Баталгаажуулалт",
              onEdit: () {},
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.verified_user, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text("Баталгаажаагүй"),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text("Баталгаажуулах"),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.stateBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.subtitle),
              Text(value, style: AppTextStyles.body),
            ],
          ),
        ],
      ),
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
                icon: const Icon(
                  Icons.edit,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }
}

class _infoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _infoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

Widget _skillChip(String label) {
  return Chip(
    label: Text(label),
    backgroundColor: AppColors.stateBackground,
    labelStyle: const TextStyle(color: AppColors.primary),
  );
}
