import 'package:flutter/material.dart';
import '../constant/styles.dart';

class JobRequestCard extends StatelessWidget {
  final String name;
  final bool showCheckbox;
  final bool checked;
  final ValueChanged<bool> onChanged;

  const JobRequestCard({
    super.key,
    required this.name,
    required this.showCheckbox,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                'assets/images/avatar.png',
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
                  Text(name, style: AppTextStyles.heading),
                  const Text(
                    "Professional title",
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text("4.5", style: TextStyle(fontSize: 14)),
                      Spacer(),
                      Text("PROJECTS", style: AppTextStyles.subtitle),
                      SizedBox(width: 4),
                      Icon(
                        Icons.check_box_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 2),
                      Text("50", style: TextStyle(fontSize: 14)),
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
