import 'package:flutter/material.dart';
import '../../constant/styles.dart';

class JobFilterSheet extends StatefulWidget {
  const JobFilterSheet({super.key});

  @override
  State<JobFilterSheet> createState() => _JobFilterSheetState();
}

class _JobFilterSheetState extends State<JobFilterSheet> {
  String? selectedCategory;
  String? selectedLocation;
  bool isPartTime = false;
  bool isFullTime = false;
  double minSalary = 10;
  double maxSalary = 200;

  bool isRecommendedTab = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabs(),
              const SizedBox(height: AppSpacing.md),
              isRecommendedTab ? _recommendedContent() : _filterContent(),
              const SizedBox(height: AppSpacing.md),
              _buildSearchButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔘 Top Tabs
  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tabButton(
          title: "Шүүлтүүр",
          active: !isRecommendedTab,
          onTap: () {
            setState(() => isRecommendedTab = false);
          },
        ),
        const SizedBox(width: AppSpacing.lg),
        _tabButton(
          title: "Надад зориулсан",
          active: isRecommendedTab,
          onTap: () {
            setState(() => isRecommendedTab = true);
          },
        ),
      ],
    );
  }

  Widget _tabButton({
    required String title,
    required bool active,
    required VoidCallback onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: active ? AppColors.primary : Colors.black87,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  /// 🔎 Filter Content
  Widget _filterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdownField(
          label: 'Салбар',
          value: selectedCategory,
          items: ['Барилга', 'Цэвэрлэгээ', 'Зөөвөр'],
          onChanged: (val) => setState(() => selectedCategory = val),
        ),
        const SizedBox(height: AppSpacing.sm),
        _dropdownField(
          label: 'Байршил',
          value: selectedLocation,
          items: ['Улаанбаатар', 'Дархан', 'Эрдэнэт'],
          onChanged: (val) => setState(() => selectedLocation = val),
        ),
        const SizedBox(height: AppSpacing.md),

        const Text("Ажиллах цагийн төрөл", style: AppTextStyles.subtitle),
        CheckboxListTile(
          value: isPartTime,
          onChanged: (val) => setState(() => isPartTime = val ?? false),
          title: const Text("Цагийн ажил"),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          value: isFullTime,
          onChanged: (val) => setState(() => isFullTime = val ?? false),
          title: const Text("Бүтэн цагийн"),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: AppSpacing.sm),

        const Text("Цалингийн хэмжээ", style: AppTextStyles.subtitle),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("₮ ${minSalary.toInt()}"),
            Text("₮ ${maxSalary.toInt()}"),
          ],
        ),
        RangeSlider(
          values: RangeValues(minSalary, maxSalary),
          min: 0,
          max: 500,
          divisions: 50,
          activeColor: AppColors.primary,
          onChanged: (values) {
            setState(() {
              minSalary = values.start;
              maxSalary = values.end;
            });
          },
        ),
      ],
    );
  }

  /// 🌟 Recommended Tab
  Widget _recommendedContent() {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text(
        'Санал болгож буй ажлуудыг таны ур чадвар болон туршлага дээр үндэслэн харуулна.',
        style: TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  /// ⏹ Dropdown Widget
  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      value: value,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  /// 🔘 Bottom Search Button
  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
        ),
        child: const Text(
          "Хайх",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
