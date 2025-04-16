import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => setState(() => isRecommendedTab = false),
                    child: Text(
                      "Шүүлтүүр",
                      style: TextStyle(
                        color:
                            isRecommendedTab
                                ? Colors.black
                                : const Color(0xFF636AE8),
                        fontWeight:
                            isRecommendedTab
                                ? FontWeight.normal
                                : FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  TextButton(
                    onPressed: () => setState(() => isRecommendedTab = true),
                    child: Text(
                      "Надад зориулсан",
                      style: TextStyle(
                        color:
                            isRecommendedTab
                                ? const Color(0xFF636AE8)
                                : Colors.black,
                        fontWeight:
                            isRecommendedTab
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Content
              if (!isRecommendedTab)
                _filterContent()
              else
                _recommendedContent(),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF636AE8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: _dropdownDecoration('Салбар'),
          value: selectedCategory,
          items:
              [
                'Барилга',
                'Цэвэрлэгээ',
                'Зөөвөр',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) => setState(() => selectedCategory = value),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: _dropdownDecoration('Байршил'),
          value: selectedLocation,
          items:
              [
                'Улаанбаатар',
                'Дархан',
                'Эрдэнэт',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) => setState(() => selectedLocation = value),
        ),
        const SizedBox(height: 16),
        const Text(
          "Ажиллах цагийн төрөл",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
        const SizedBox(height: 12),
        const Text(
          "Цалингийн хэмжээ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
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
          activeColor: const Color(0xFF636AE8),
          onChanged: (RangeValues values) {
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

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
