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
      case 'not_started':
        return 'Эхлээгүй Байна';
      case 'pendingStart':
        return 'Хүлээгдэж буй';
      case 'in_progress':
        return 'Ажиллаж байна';
      case 'verified':
        return 'Шалгаж байна';
      case 'completed':
        return 'Дууссан';
      case 'paiding':
        return 'Төлбөр хийгдэж байна';
      default:
        return 'Тодорхойгүй';
    }
  }

  String getWorkedTime() {
    if (worker.workedHours != null && worker.workedMinutes != null) {
      return "${worker.workedHours}ц ${worker.workedMinutes}мин";
    }
    return "-";
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(worker.rating.toStringAsFixed(1)),
                      const Spacer(),
                      Text(
                        "Төслүүд: ${worker.projects}",
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (worker.status == 'in_progress') ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(getWorkedTime(), style: AppTextStyles.subtitle),
                        const Spacer(),
                        const Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          worker.salary != null ? "${worker.salary}₮" : "-",
                          style: AppTextStyles.subtitle,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Төлөв: ${_statusText(worker.status)}",
                      style: const TextStyle(color: AppColors.primary),
                    ),
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
