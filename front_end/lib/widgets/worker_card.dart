import 'package:flutter/material.dart';
import '../models/worker_model.dart';
import '../constant/styles.dart';

class WorkerCard extends StatelessWidget {
  final Worker worker;
  final bool showCheckbox;
  final ValueChanged<bool?>? onChanged;

  const WorkerCard({
    super.key,
    required this.worker,
    this.showCheckbox = false,
    this.onChanged,
  });

  String _statusText(String status) {
    switch (status) {
      case 'pendingStart':
        return 'Хүлээгдэж буй';
      case 'working':
        return 'Ажиллаж байна';
      case 'verified':
        return 'Баталгаажсан';
      case 'completed':
        return 'Дууссан';
      case 'paiding':
        return 'Төлбөр хийгдэж байна';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (showCheckbox)
              Checkbox(value: worker.selected, onChanged: onChanged),
            const CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(worker.name, style: AppTextStyles.heading),
                  Text(worker.phone, style: AppTextStyles.subtitle),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(worker.rating.toStringAsFixed(1)),
                      const Spacer(),
                      Text("PROJECTS", style: AppTextStyles.subtitle),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_box,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Text(worker.projects.toString()),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("Хүсэлт илгээсэн: ${worker.requestTime}"),
                  Text("Ажил эхлэх: ${worker.workStartTime}"),
                  Text("Төлөв: ${_statusText(worker.status)}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
