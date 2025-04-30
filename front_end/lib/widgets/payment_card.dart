import 'package:flutter/material.dart';
import '../models/payment_model.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final bool showCheckbox;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.selected,
    required this.showCheckbox,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCheckbox) Checkbox(value: selected, onChanged: onChanged),
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
          ],
        ),
        title: Text(payment.workerName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Нийт цалин: ${payment.totalAmount}₮"),
            if (payment.jobStartedAt != null && payment.jobEndedAt != null)
              Text("Ажилласан: ${payment.getFormattedWorkedTime()}"),
            Text("Төлөв: ${payment.status}"),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Үндсэн цалин: ${payment.breakdown.baseSalary}₮"),
                Text(
                  "Тээврийн нэмэгдэл: ${payment.breakdown.transportAllowance}₮",
                ),
                Text("Хоолны нэмэгдэл: ${payment.breakdown.mealAllowance}₮"),
                Text("НДШ: -${payment.breakdown.socialInsurance}₮"),
                Text("Татвар: -${payment.breakdown.taxDeduction}₮"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
