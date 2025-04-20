import 'package:flutter/material.dart';
import '../constant/styles.dart';
import 'package:front_end/models/user_model.dart';

class JobRequestCard extends StatelessWidget {
  final UserModel? user; // Nullable UserModel
  final bool showCheckbox;
  final bool checked;
  final ValueChanged<bool> onChanged;

  const JobRequestCard({
    super.key,
    required this.user,
    required this.showCheckbox,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return SizedBox(); // Or show a placeholder if user is null
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (showCheckbox)
              Checkbox(
                value: checked,
                onChanged: (val) => onChanged(val ?? false),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                user!.avatar ??
                    'assets/images/avatar.png', // Access user.avatar
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user!.name, style: AppTextStyles.heading),
                  const Text(
                    "Professional title",
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "${user!.averageRating.overall ?? '-'}", // Access user.averageRating
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      const Text("PROJECTS", style: AppTextStyles.subtitle),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_box_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "${user!.profile?.skills.length ?? 0}", // Safe access
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
