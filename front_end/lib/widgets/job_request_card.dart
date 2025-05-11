import 'package:flutter/material.dart';
import '../constant/styles.dart';
import 'package:front_end/models/user_model.dart';

class JobRequestCard extends StatefulWidget {
  final UserModel? user;
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
  State<JobRequestCard> createState() => _JobRequestCardState();
}

class _JobRequestCardState extends State<JobRequestCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    if (user == null) return SizedBox();

    final review = user.reviews.isNotEmpty ? user.reviews.first : null;

    // Default 0 үнэлгээ
    final criteria = {
      'speed': 0,
      'performance': 0,
      'quality': 0,
      'time_management': 0,
      'stress_management': 0,
      'learning_ability': 0,
      'ethics': 0,
      'communication': 0,
      'punctuality': 0,
      'job_completion': 0,
      'no_show': 0,
      'absenteeism': 0,
    };

    if (review != null) {
      for (var key in review.criteria.keys) {
        criteria[key] = review.criteria[key]!.clamp(0, 5).toInt();
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => setState(() => expanded = !expanded),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  if (widget.showCheckbox)
                    Checkbox(
                      value: widget.checked,
                      onChanged: (val) => widget.onChanged(val ?? false),
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
                        Text(user.name, style: AppTextStyles.heading),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text("${user.averageRating.overall}"),
                            const Spacer(),
                            const Icon(
                              Icons.check_box_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 2),
                            Text("${user.profile?.skills.length ?? 0}"),
                            Icon(
                              expanded
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              size: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      criteria.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(child: Text(_localizedLabel(entry.key))),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    Icons.star,
                                    size: 16,
                                    color:
                                        i < entry.value
                                            ? Colors.orange
                                            : Colors.grey[300], // саарал өнгө
                                  );
                                }),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _localizedLabel(String key) {
    const labels = {
      'speed': 'Хурд',
      'performance': 'Гүйцэтгэл',
      'quality': 'Чанар',
      'time_management': 'Цагийн менежмент',
      'stress_management': 'Стресс удирдлага',
      'learning_ability': 'Суралцах чадвар',
      'ethics': 'Ёс зүй',
      'communication': 'Харилцаа',
      'punctuality': 'Цаг баримтлалт',
      'job_completion': 'Ажил гүйцэтгэл',
      'no_show': 'Ирээгүй',
      'absenteeism': 'Тасалсан',
    };
    return labels[key] ?? key;
  }
}
