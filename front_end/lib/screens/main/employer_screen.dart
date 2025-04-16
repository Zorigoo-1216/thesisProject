import 'package:flutter/material.dart';
import '../../constant/styles.dart';

class EmployerScreen extends StatefulWidget {
  const EmployerScreen({super.key});

  @override
  State<EmployerScreen> createState() => _EmployerScreenState();
}

class _EmployerScreenState extends State<EmployerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ажлын зар"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepPurple,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Үүсгэсэн ажлууд"),
            Tab(text: "Ажлын зар үүсгэх"),
          ],
        ),
        actions: const [
          Icon(Icons.notifications_none, color: AppColors.primary),
          SizedBox(width: AppSpacing.sm),
          Icon(Icons.settings, color: AppColors.primary),
          SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/profile.png'),
          ),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_CreatedJobsTab(), CreateJobTab()],
      ),
    );
  }
}

class _CreatedJobsTab extends StatelessWidget {
  const _CreatedJobsTab();

  final List<Map<String, dynamic>> jobList = const [
    {
      "title": "Барилгын туслах ажилтан авна",
      "location": "БЗД, Жуков, Сансрын гүүрийн хойно",
      "salary": "120000₮ / өдөр",
      "date": "2025-01-01 to 2025-01-02",
      "tags": [
        "Боломжит ажилтан",
        "Гэрээ",
        "Ажиллах хүсэлт",
        "Ярилцлага",
        "Гэрээ байгуулах ажилчид",
        "Ажлын явц",
        "Ажилчид",
        "Төлбөр",
        "Үнэлгээ",
      ],
    },
    // ... other jobs
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: jobList.length,
      itemBuilder: (context, index) {
        final job = jobList[index];
        return Card(
          elevation: AppSpacing.cardElevation,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.iconColor),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: AppColors.iconColor,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                _iconRow(Icons.calendar_month_outlined, job['date']),
                _iconRow(Icons.location_on_outlined, job['location']),
                _iconRow(Icons.attach_money, job['salary']),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 6,
                  runSpacing: -6,
                  children:
                      job['tags']
                          .map<Widget>((label) => _tag(context, label))
                          .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _iconRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.iconColor),
          const SizedBox(width: AppSpacing.xs),
          Text(text, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, String label) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case "Боломжит ажилтан":
            Navigator.pushNamed(context, '/suitable-workers');
            break;
          case "Гэрээ":
            Navigator.pushNamed(context, '/job-contract');
            break;
          case "Үнэлгээ":
            Navigator.pushNamed(context, '/rate-employee');
            break;
          case "Ажиллах хүсэлт":
            Navigator.pushNamed(context, '/job-request');
            break;
          case "Ярилцлага":
            Navigator.pushNamed(context, '/interview');
            break;
          case "Гэрээ байгуулах ажилчид":
            Navigator.pushNamed(context, '/contract-employees');
            break;
          case "Ажлын явц":
            Navigator.pushNamed(context, '/job-progress');
            break;
          case "Ажилчид":
            Navigator.pushNamed(context, '/job-employees');
            break;
          case "Төлбөр":
            Navigator.pushNamed(context, '/job-payment');
            break;
          default:
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(top: 6, right: 6),
        decoration: BoxDecoration(
          color: AppColors.tagColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

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

  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController breakStartController = TextEditingController();
  final TextEditingController breakEndController = TextEditingController();

  @override
  void dispose() {
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
          _input('Ажлын нэр'),
          _input('Ажлын тайлбар', maxLines: 3),
          Row(
            children: [
              Expanded(child: _dropdown('Дүүрэг', ['БЗД', 'СБД', 'ХУД'])),
              const SizedBox(width: 10),
              Expanded(child: _dropdown('Хороо', ['1-р хороо', '2-р хороо'])),
            ],
          ),
          _input('Хаяг'),
          _dropdown('Цалингийн төрөл', ['Өдөр', 'Цаг', 'Гүйцэтгэл']),
          _input('Цалингийн хэмжээ', prefix: '₮'),
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
          _dropdown('Ажлын салбар', ['Барилга', 'Үйлчилгээ']),
          _dropdown('Ажлын төрөл', ['Өдөр', 'Цаг']),
          if (isIndividual) _input('Ажилчдын тоо'),
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
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: AppColors.primary,
            ),
            child: const Text("Үргэлжлүүлэх", style: AppTextStyles.whiteButton),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, {String? prefix, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
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

  Widget _dropdown(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DropdownButtonFormField<String>(
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
        onChanged: (_) {},
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
