// import 'package:flutter/material.dart';
// import 'package:front_end/models/job_model.dart';
// import 'package:front_end/screens/main/job_detail_screen.dart';
// import '../../constant/styles.dart';

// class JobCard extends StatefulWidget {
//   final Job job;
//   final VoidCallback onRefresh;

//   const JobCard({super.key, required this.job, required this.onRefresh});

//   @override
//   State<JobCard> createState() => _JobCardState();
// }

// class _JobCardState extends State<JobCard> {
//   bool isApplied = false;

//   void _applyJob() {
//     setState(() {
//       isApplied = true;
//     });
//   }

//   @override
//   @override
//   Widget build(BuildContext context) {
//     print("🔥 JobCard build called for ${widget.job.title}");
//     // return Padding(
//     //   padding: const EdgeInsets.only(bottom: AppSpacing.md),
//     //   child: Material(
//     //     color: AppColors.white,
//     //     borderRadius: BorderRadius.circular(AppSpacing.radius),
//     //     elevation: AppSpacing.cardElevation,
//     //     child: InkWell(
//     //       borderRadius: BorderRadius.circular(AppSpacing.radius),
//     //       onTap: () {
//     //         debugPrint("✅ CLICKED JOB: ${widget.job.title}");
//     //         Navigator.pushNamed(context, '/job-detail', arguments: widget.job);
//     //       },
//     //       child: Padding(
//     //         padding: const EdgeInsets.all(AppSpacing.md),
//     //         child: Column(
//     //           crossAxisAlignment: CrossAxisAlignment.start,
//     //           children: [
//     //             Row(
//     //               children: [
//     //                 const CircleAvatar(
//     //                   radius: 20,
//     //                   backgroundImage: AssetImage('assets/images/avatar.png'),
//     //                 ),
//     //                 const SizedBox(width: AppSpacing.sm),
//     //                 Expanded(
//     //                   child: Column(
//     //                     crossAxisAlignment: CrossAxisAlignment.start,
//     //                     children: [
//     //                       Text(
//     //                         widget.job.employerName,
//     //                         style: AppTextStyles.body,
//     //                       ),
//     //                       Text(
//     //                         widget.job.title,
//     //                         style: AppTextStyles.body.copyWith(
//     //                           fontWeight: FontWeight.bold,
//     //                         ),
//     //                       ),
//     //                     ],
//     //                   ),
//     //                 ),
//     //                 const Icon(
//     //                   Icons.favorite_border,
//     //                   color: AppColors.iconColor,
//     //                 ),
//     //               ],
//     //             ),
//     //             const SizedBox(height: AppSpacing.sm),
//     //             Text("1 цагийн өмнө", style: AppTextStyles.subtitle),
//     //             const SizedBox(height: AppSpacing.xs),
//     //             _iconRow(Icons.location_on_outlined, widget.job.location),
//     //             _iconRow(
//     //               Icons.attach_money,
//     //               widget.job.salary.getSalaryFormatted(),
//     //             ),
//     //             _iconRow(Icons.calendar_today_outlined, widget.job.postedAgo),
//     //             const SizedBox(height: AppSpacing.sm),
//     //             Align(
//     //               alignment: Alignment.centerRight,
//     //               child: ElevatedButton(
//     //                 onPressed: isApplied ? null : _applyJob,
//     //                 style: ElevatedButton.styleFrom(
//     //                   backgroundColor:
//     //                       isApplied ? Colors.grey[300] : AppColors.primary,
//     //                 ),
//     //                 child: Text(
//     //                   isApplied ? 'Applied' : 'Apply Now',
//     //                   style: TextStyle(
//     //                     color: isApplied ? Colors.black : Colors.white,
//     //                   ),
//     //                 ),
//     //               ),
//     //             ),
//     //           ],
//     //         ),
//     //       ),
//     //     ),
//     //   ),
//     // );
//     return Material(
//       child: InkWell(
//         onTap: () {
//           debugPrint("✅ SIMPLE INKWELL TAP");
//         },
//         child: Container(
//           height: 100,
//           color: Colors.amber,
//           child: const Center(child: Text("Test Tap")),
//         ),
//       ),
//     );
//   }

//   Widget _iconRow(IconData icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: AppSpacing.xs),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: AppColors.primary),
//           const SizedBox(width: AppSpacing.xs),
//           Text(text, style: AppTextStyles.subtitle),
//         ],
//       ),
//     );
//   }
// }
