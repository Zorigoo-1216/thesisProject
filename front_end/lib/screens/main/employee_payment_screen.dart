import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/api.dart';
import '../../constant/styles.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class EmployeePaymentScreen extends StatefulWidget {
  final String jobId;
  const EmployeePaymentScreen({super.key, required this.jobId});

  @override
  State<EmployeePaymentScreen> createState() => _EmployeePaymentScreenState();
}

class _EmployeePaymentScreenState extends State<EmployeePaymentScreen> {
  Map<String, dynamic>? payment;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPayment();
  }

  Future<void> loadPayment() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getString('userId') ?? '';

    final res = await http.get(
      Uri.parse('${baseUrl}payments/job/${widget.jobId}/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['success'] == true &&
          data['data'] != null &&
          data['data'].isNotEmpty) {
        setState(() {
          payment = data['data'];
          loading = false;
        });
      } else {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("Мэдээлэл"),
                content: const Text(
                  "Ажил дуусаагүй байна. Төлбөр үүсээгүй байна.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
        setState(() => loading = false);
      }
    } else {
      setState(() => loading = false);
    }
  }

  Future<void> markAsPaid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getString('userId') ?? '';

    final res = await http.put(
      Uri.parse('${baseUrl}payments/${widget.jobId}/${payment!['_id']}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Цалин төлөгдсөн төлөвт шилжлээ")),
      );
      await loadPayment();
    } else {
      debugPrint('❌ Mark as paid failed: ${res.body}');
    }
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'paid':
        color = Colors.green;
        label = 'Төлөгдсөн';
        break;
      case 'paiding':
        color = Colors.orange;
        label = 'Төлөгдөх шатандаа';
        break;
      default:
        color = Colors.red;
        label = 'Төлөгдөөгүй';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.stateBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(showTabs: false, showBack: true, tabs: []),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child:
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : payment == null
                      ? const Text("Төлбөрийн мэдээлэл олдсонгүй.")
                      : Column(
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radius,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: const CircleAvatar(
                                backgroundImage: AssetImage(
                                  'assets/images/avatar.png',
                                ),
                              ),
                              title: Text(
                                payment!['workerId']?['lastName'] != null
                                    ? "${payment!['workerId']['lastName']} ${payment!['workerId']['firstName']}"
                                    : 'Нэргүй',
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  if (payment!['jobstartedAt'] != null &&
                                      payment!['jobendedAt'] != null)
                                    Text(
                                      "Ажилласан: ${_formatWorkedTime(payment!['jobstartedAt'], payment!['jobendedAt'])}",
                                    ),
                                  const SizedBox(height: 4),
                                  Text("Цалин: ${payment!['totalAmount']}₮"),
                                ],
                              ),
                              trailing: _statusBadge(payment!['status']),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (payment!['status'] == 'paiding')
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: markAsPaid,
                                    child: const Text("Цалин өгсөн"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed:
                                        () => ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Цалинг өгөөгүй гэж тэмдэглэх боломжгүй",
                                            ),
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

  String _formatWorkedTime(String start, String end) {
    try {
      final startTime = DateTime.parse(start);
      final endTime = DateTime.parse(end);
      final diff = endTime.difference(startTime);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      return "$hours цаг ${minutes.toString().padLeft(2, '0')} мин";
    } catch (_) {
      return "0 цаг 0 мин";
    }
  }
}
