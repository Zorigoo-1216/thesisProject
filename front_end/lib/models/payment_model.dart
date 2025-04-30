class Payment {
  final String id;
  final String status;
  final int totalAmount;
  final PaymentBreakdown breakdown;
  final String workerName;
  final DateTime? jobStartedAt;
  final DateTime? jobEndedAt;
  bool selected; // ✅ сонгогдсон эсэх
  Payment({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.breakdown,
    required this.workerName,
    this.jobStartedAt,
    this.jobEndedAt,
    this.selected = false,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'] ?? '',
      status: json['status'] ?? 'unpaid',
      totalAmount: json['totalAmount'] ?? 0,
      breakdown: PaymentBreakdown.fromJson(json['breakdown'] ?? {}),
      workerName:
          json['workerId']?['firstName'] != null
              ? "${json['workerId']['lastName'] ?? ''} ${json['workerId']['firstName'] ?? ''}"
              : 'Нэргүй',
      jobStartedAt:
          json['jobstartedAt'] != null
              ? DateTime.tryParse(json['jobstartedAt'])
              : null,
      jobEndedAt:
          json['jobendedAt'] != null
              ? DateTime.tryParse(json['jobendedAt'])
              : null,
      selected: false,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'status': status,
    'totalAmount': totalAmount,
    'breakdown': breakdown.toJson(),
    'workerName': workerName,
    'jobstartedAt': jobStartedAt?.toIso8601String(),
    'jobendedAt': jobEndedAt?.toIso8601String(),
    'selected': selected,
  };

  /// ⏱️ Ажилласан хугацааг цаг:минут формат руу хөрвүүлнэ
  String getFormattedWorkedTime() {
    if (jobStartedAt == null || jobEndedAt == null) return "0 цаг 0 мин";
    final duration = jobEndedAt!.difference(jobStartedAt!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return "$hours цаг ${minutes.toString().padLeft(2, '0')} мин";
  }
}

/// 💰 Дэлгэрэнгүй breakdown model
class PaymentBreakdown {
  final int baseSalary;
  final int transportAllowance;
  final int mealAllowance;
  final int socialInsurance;
  final int taxDeduction;

  PaymentBreakdown({
    this.baseSalary = 0,
    this.transportAllowance = 0,
    this.mealAllowance = 0,
    this.socialInsurance = 0,
    this.taxDeduction = 0,
  });

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentBreakdown(
      baseSalary: json['baseSalary'] ?? 0,
      transportAllowance: json['transportAllowance'] ?? 0,
      mealAllowance: json['mealAllowance'] ?? 0,
      socialInsurance: json['socialInsurance'] ?? 0,
      taxDeduction: json['taxDeduction'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'baseSalary': baseSalary,
    'transportAllowance': transportAllowance,
    'mealAllowance': mealAllowance,
    'socialInsurance': socialInsurance,
    'taxDeduction': taxDeduction,
  };
}
