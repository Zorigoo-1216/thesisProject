import 'package:flutter/material.dart';
import '../../constant/styles.dart';

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
      appBar: AppBar(title: const Text("Цалингийн мэдээлэл")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                title: const Text("О.Эрдэнэцогт"),
                subtitle: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ажилласан цаг: 01:05:30"),
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
                    onPressed: () {
                      showConfirmDialog();
                    },
                    child: const Text("Цалин өгсөн"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => isPaid = false),
                    child: const Text("Цалин өгөөгүй"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
