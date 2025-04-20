import 'package:flutter/material.dart';
import '../../constant/styles.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class EmployeeWorkProgressScreen extends StatefulWidget {
  const EmployeeWorkProgressScreen({super.key});

  @override
  State<EmployeeWorkProgressScreen> createState() =>
      _EmployeeWorkProgressScreenState();
}

class _EmployeeWorkProgressScreenState
    extends State<EmployeeWorkProgressScreen> {
  bool isStarted = false;
  bool isFinished = false;

  void startJob() {
    setState(() => isStarted = true);
  }

  void finishJob() {
    setState(() => isFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    String status =
        isStarted
            ? (isFinished ? "Шалгаж байна" : "Ажиллаж байна")
            : "Хүлээж байна";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(showTabs: false, showBack: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: AppSpacing.cardElevation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/images/avatar.png',
                            ),
                            radius: 20,
                          ),
                          SizedBox(width: 8),
                          Text("О.Эрдэнэцогт", style: AppTextStyles.heading),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _statusBadge(status),
                      const SizedBox(height: 12),
                      const Text("Ажилласан цаг: 01:05:30"),
                      const SizedBox(height: 4),
                      const Text("Бодогдсон цалин: 154500₮"),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                            isStarted
                                ? isFinished
                                    ? [
                                      _actionButton("Цалин харах", () {
                                        Navigator.pushNamed(
                                          context,
                                          '/employee-payment',
                                        );
                                      }),
                                      _outlinedButton("Цуцлах", () {
                                        setState(() {
                                          isFinished = false;
                                          isStarted = false;
                                        });
                                      }),
                                    ]
                                    : [
                                      _actionButton("Дуусгах", finishJob),
                                      _outlinedButton("Засварлах", () {}),
                                    ]
                                : [_actionButton("Эхлүүлэх", startJob)],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.stateBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(color: AppColors.primary)),
    );
  }

  Widget _actionButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }

  Widget _outlinedButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}
