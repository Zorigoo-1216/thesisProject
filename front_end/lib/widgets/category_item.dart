import 'package:flutter/material.dart';
import '../constant/styles.dart';

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xs),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.stateBackground,
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.subtitle.copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
