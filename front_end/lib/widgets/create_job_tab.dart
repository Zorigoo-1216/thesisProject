import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_end/constant/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/styles.dart';

class CreateJobTab extends StatefulWidget {
  const CreateJobTab({super.key});

  @override
  State<CreateJobTab> createState() => _CreateJobTabState();
}

class _CreateJobTabState extends State<CreateJobTab> {
  bool isIndividual = true;

  bool includeMeal = false;
  bool includeTransport = false;
  bool includeBonus = false;
  bool hasInterview = false;
  bool supportDisability = false;

  final List<String> requirements = [''];
  final List<String> additions = [''];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController salaryAmountController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();

  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController breakStartController = TextEditingController();
  final TextEditingController breakEndController = TextEditingController();

  String? selectedDistrict;
  String? selectedKhoroo;
  String? selectedSalaryType;
  String? selectedBranch;
  String? selectedJobType;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    salaryAmountController.dispose();
    addressController.dispose();
    capacityController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    breakStartController.dispose();
    breakEndController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  Future<void> _submitJob() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var id = prefs.getString('id');
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Токен олдсонгүй")));
      return;
    }

    const jobTypeMap = {
      'Цагийн': 'hourly',
      'Бүтэн цагийн': 'full-time',
      'Өдөрийн': 'part-time',
    };

    const salaryTypeMap = {
      'Цаг': 'hourly',
      'Өдөр': 'daily',
      'Гүйцэтгэл': 'performance',
    };

    final jobData = {
      "employerId": id, // Replace with actual user ID
      "title": titleController.text,
      "description":
          descriptionController.text.trim().isEmpty
              ? "Тайлбар оруулаагүй"
              : descriptionController.text.trim(),
      "requirements": requirements.where((e) => e.trim().isNotEmpty).toList(),
      "location":
          "${selectedDistrict ?? ''} ${selectedKhoroo ?? ''}, ${addressController.text}",

      "salary": {
        "amount": int.tryParse(salaryAmountController.text) ?? 0,
        "currency": "MNT",
        "type": salaryTypeMap[selectedSalaryType] ?? 'hourly',
      },

      "benefits": {
        "transportIncluded": includeTransport,
        "mealIncluded": includeMeal,
        "bonusIncluded": includeBonus,
        "includeDefaultBenefits": false,
      },

      "seeker": isIndividual ? "individual" : "company",
      "capacity": int.tryParse(capacityController.text) ?? 1,
      "branch": selectedBranch ?? '',
      "jobType": jobTypeMap[selectedJobType] ?? 'hourly',
      "level": "none",
      "possibleForDisabled": supportDisability,

      "status": "open",
      "startDate": startDateController.text,
      "endDate": endDateController.text,

      "workStartTime": startTimeController.text,
      "workEndTime": endTimeController.text,
      "breakStartTime": breakStartController.text,
      "breakEndTime": breakEndController.text,

      "hasInterview": hasInterview,
      "applications": [],
      "employees": [],
    };

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}jobs/create'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(jobData),
      );
      print("📤 jobData being sent: ${jsonEncode(jobData)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Амжилттай хадгалагдлаа")));
      } else {
        print("Failed: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Алдаа гарлаа: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Сүлжээний алдаа: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            title: const Text('Хувь хүн ажил хайж байна'),
            value: isIndividual,
            onChanged: (val) => setState(() => isIndividual = val!),
          ),
          _input('Ажлын нэр', controller: titleController),
          _input(
            'Ажлын тайлбар',
            controller: descriptionController,
            maxLines: 3,
          ),
          Row(
            children: [
              Expanded(
                child: _dropdown(
                  'Дүүрэг',
                  ['БЗД', 'СБД', 'ХУД'],
                  selectedDistrict,
                  (val) => setState(() => selectedDistrict = val),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dropdown(
                  'Хороо',
                  ['1-р хороо', '2-р хороо'],
                  selectedKhoroo,
                  (val) => setState(() => selectedKhoroo = val),
                ),
              ),
            ],
          ),
          _input('Хаяг', controller: addressController),
          _dropdown(
            'Цалингийн төрөл',
            ['Өдөр', 'Цаг', 'Гүйцэтгэл'],
            selectedSalaryType,
            (val) => setState(() => selectedSalaryType = val),
          ),
          _input(
            'Цалингийн хэмжээ',
            controller: salaryAmountController,
            prefix: '₮',
          ),
          _stateCheckbox(
            'Унаа',
            includeTransport,
            (val) => setState(() => includeTransport = val),
          ),
          _stateCheckbox(
            'Хоол',
            includeMeal,
            (val) => setState(() => includeMeal = val),
          ),
          _stateCheckbox(
            'Урамшуулал',
            includeBonus,
            (val) => setState(() => includeBonus = val),
          ),
          _dropdown(
            'Ажлын салбар',
            ['Барилга', 'Үйлчилгээ'],
            selectedBranch,
            (val) => setState(() => selectedBranch = val),
          ),
          _dropdown(
            'Ажлын төрөл',
            ['Өдөр', 'Цаг'],
            selectedJobType,
            (val) => setState(() => selectedJobType = val),
          ),
          if (isIndividual)
            _input('Ажилчдын тоо', controller: capacityController),
          _stateCheckbox(
            'Ярилцлагын шаттай',
            hasInterview,
            (val) => setState(() => hasInterview = val),
          ),
          _stateCheckbox(
            'Хөгжлийн бэрхшээлтэй ажилтан ажиллах боломжтой',
            supportDisability,
            (val) => setState(() => supportDisability = val),
          ),

          _datePicker('Ажил эхлэх огноо', startDateController),
          _datePicker('Ажил дуусах огноо', endDateController),
          _timePicker('Ажил эхлэх цаг', startTimeController),
          _timePicker('Ажил дуусах цаг', endTimeController),
          _timePicker('Завсарлага эхлэх', breakStartController),
          _timePicker('Завсарлага дуусах', breakEndController),

          const SizedBox(height: 12),
          _repeatableForm('Ажлын шаардлага', requirements),
          const SizedBox(height: 12),
          _repeatableForm('Нэмэлт мэдээлэл', additions),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitJob,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: AppColors.primary,
            ),
            child: const Text("Хадгалах", style: AppTextStyles.whiteButton),
          ),
        ],
      ),
    );
  }

  Widget _input(
    String label, {
    TextEditingController? controller,
    String? prefix,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefix,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            borderSide: BorderSide.none,
          ),
        ),
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _stateCheckbox(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (val) => onChanged(val ?? false),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _repeatableForm(String label, List<String> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.heading),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => setState(() => values.add('')),
            ),
          ],
        ),
        ...values.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: TextField(
              onChanged: (val) => values[entry.key] = val,
              decoration: InputDecoration(
                hintText: '$label оруулна уу',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _datePicker(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(context, controller),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          suffixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _timePicker(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectTime(context, controller),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          suffixIcon: const Icon(Icons.access_time),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
