import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  double minSalary = 10000;
  double maxSalary = 200000;

  bool isRecommendedTab = false;

  @override
  void initState() {
    super.initState();
    loadInitialData(); // Эхний удаад өгөгдлийг ачаална
  }

  Future<void> loadInitialData() async {
    // Энд шаардлагатай өгөгдлийг ачаална
    // Жишээ нь, SharedPreferences эсвэл API-аас өгөгдөл татах
    final prefs = await SharedPreferences.getInstance();
    final savedCategory = prefs.getString('selectedCategory');
    final savedLocation = prefs.getString('selectedLocation');
    final savedMinSalary = prefs.getDouble('minSalary') ?? 10000;
    final savedMaxSalary = prefs.getDouble('maxSalary') ?? 200000;

    setState(() {
      selectedCategory = savedCategory;
      selectedLocation = savedLocation;
      minSalary = savedMinSalary;
      maxSalary = savedMaxSalary;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Хуудас руу орох бүрт өгөгдлийг шинэчлэх
    setState(() {
      loadInitialData();
    });
  }

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

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tabButton(
          title: "Шүүлтүүр",
          active: !isRecommendedTab,
          onTap: () => setState(() => isRecommendedTab = false),
        ),
        const SizedBox(width: AppSpacing.lg),
        _tabButton(
          title: "Надад зориулсан",
          active: isRecommendedTab,
          onTap: () => setState(() => isRecommendedTab = true),
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
        _checkboxTile("Цагийн ажил", isPartTime, (val) {
          setState(() => isPartTime = val ?? false);
        }),
        _checkboxTile("Бүтэн цагийн", isFullTime, (val) {
          setState(() => isFullTime = val ?? false);
        }),

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
          min: 5000,
          max: 300000,
          divisions: 5000,
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

  Widget _recommendedContent() {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text(
        'Санал болгож буй ажлуудыг таны ур чадвар болон туршлага дээр үндэслэн харуулна.',
        style: TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

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
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down),
      items:
          items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, textAlign: TextAlign.start),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }

  Widget _checkboxTile(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context, {
            'category': selectedCategory,
            'location': selectedLocation,
            'isPartTime': isPartTime,
            'isFullTime': isFullTime,
            'minSalary': minSalary,
            'maxSalary': maxSalary,
            'recommended': isRecommendedTab,
          });
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
