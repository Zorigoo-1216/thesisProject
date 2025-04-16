import 'package:flutter/material.dart';
import '../../constant/styles.dart';
import '../../data/testdata/dummy_jobs.dart';
import '../../widgets/job_card.dart';
import './job_filter_sheet_screen.dart';

class JobListScreen extends StatelessWidget {
  const JobListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        toolbarHeight: 80,
        actions: const [
          Icon(Icons.notifications_none, color: AppColors.primary),
          SizedBox(width: AppSpacing.sm),
          Icon(Icons.settings, color: AppColors.primary),
          SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/profile.png'),
          ),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search + Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ажил хайх...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.iconColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => const JobFilterSheet(),
                    );
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColors.stateBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.iconColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 📋 Job List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: dummyJobs.length,
              itemBuilder: (context, index) {
                final job = dummyJobs[index];
                return JobCard(job: job);
              },
            ),
          ),
        ],
      ),
    );
  }
}
