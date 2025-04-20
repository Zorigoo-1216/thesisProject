import 'package:flutter/material.dart';
import '../../constant/styles.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class EmployeePaymentScreen extends StatefulWidget {
  const EmployeePaymentScreen({super.key});

  @override
  State<EmployeePaymentScreen> createState() => _EmployeePaymentScreenState();
}

class _EmployeePaymentScreenState extends State<EmployeePaymentScreen> {
  bool? isPaid;

  void showConfirmDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Цалинг шилжүүлэх"),
            content: const Text("Цалинг амжилттай шилжүүллээ."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() => isPaid = true);
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Widget _statusBadge(bool paid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.stateBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        paid ? "Төлөгдсөн" : "Төлөгдөөгүй",
        style: TextStyle(
          color: paid ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(showTabs: false, showBack: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/avatar.png'),
                      ),
                      title: const Text("О.Эрдэнэцогт"),
                      subtitle: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 6),
                          Text("Ажилласан цаг: 01:05:30"),
                          SizedBox(height: 4),
                          Text("Цалин: 154500₮"),
                        ],
                      ),
                      trailing: isPaid != null ? _statusBadge(isPaid!) : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: showConfirmDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Цалин өгсөн"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => isPaid = false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Цалин өгөөгүй"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
