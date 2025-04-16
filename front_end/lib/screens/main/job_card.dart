import 'package:flutter/material.dart';
import '../../constant/styles.dart';

class JobCard extends StatefulWidget {
  final String employerName;
  final String jobTitle;
  final String location;
  final String salary;
  final String date;

  const JobCard({
    super.key,
    required this.employerName,
    required this.jobTitle,
    required this.location,
    required this.salary,
    required this.date,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool isApplied = false;

  void _applyJob() {
    setState(() {
      isApplied = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/job-detail');
      },
      child: Card(
        color: AppColors.white,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
        elevation: AppSpacing.cardElevation,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.employerName, style: AppTextStyles.body),
                        Text(
                          widget.jobTitle,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.favorite_border, color: AppColors.iconColor),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text("1 цагийн өмнө", style: AppTextStyles.subtitle),
              const SizedBox(height: AppSpacing.xs),

              _iconRow(Icons.location_on_outlined, widget.location),
              _iconRow(Icons.attach_money, widget.salary),
              _iconRow(Icons.calendar_today_outlined, widget.date),

              const SizedBox(height: AppSpacing.sm),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: isApplied ? null : _applyJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isApplied ? Colors.grey[300] : AppColors.primary,
                  ),
                  child: Text(
                    isApplied ? 'Applied' : 'Apply Now',
                    style: TextStyle(
                      color: isApplied ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(text, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }
}
