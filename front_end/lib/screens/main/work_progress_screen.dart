import 'package:flutter/material.dart';
import '../../constant/styles.dart';

class WorkProgressScreen extends StatefulWidget {
  final int initialTabIndex;
  const WorkProgressScreen({super.key, this.initialTabIndex = 0});

  @override
  State<WorkProgressScreen> createState() => _WorkProgressScreenState();
}

class _WorkProgressScreenState extends State<WorkProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool selecting = false;
  List<bool> selectedWorkers = [false, false, false, false];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  void resetSelection() {
    setState(() {
      selecting = false;
      selectedWorkers = List.filled(selectedWorkers.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ажлын явц"),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.subtitle,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Ажилчид"),
            Tab(text: "Ажлын явц"),
            Tab(text: "Төлбөр"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEmployeesTab(),
          _buildProgressTab(),
          _buildPaymentTab(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child:
            selecting
                ? Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Call your API
                          resetSelection();
                        },
                        child: const Text("Батлах"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: resetSelection,
                        child: const Text("Цуцлах"),
                      ),
                    ),
                  ],
                )
                : ElevatedButton.icon(
                  icon: const Icon(Icons.play_circle_fill_outlined),
                  label: const Text("Эхлүүлэх"),
                  onPressed: () {
                    setState(() => selecting = true);
                  },
                ),
      ),
    );
  }

  Widget _buildEmployeesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: selectedWorkers.length,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading:
                selecting
                    ? Checkbox(
                      value: selectedWorkers[index],
                      onChanged: (val) {
                        setState(() => selectedWorkers[index] = val ?? false);
                      },
                    )
                    : CircleAvatar(
                      backgroundImage: const AssetImage(
                        'assets/images/avatar.png',
                      ),
                      radius: 24,
                    ),
            title: const Text("Full name"),
            subtitle: const Text("99010101"),
          ),
        );
      },
    );
  }

  Widget _buildProgressTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/avatar.png'),
              radius: 24,
            ),
            title: const Text("Full name"),
            subtitle: const Text("99010101"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.stateBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "working",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentTab() {
    final payments = List.generate(
      3,
      (_) => {'name': 'Full name', 'time': 8, 'pay': 80000},
    );
    final totalPay = payments.fold(0, (sum, e) => sum + (e['pay'] as int));

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final item = payments[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                    radius: 24,
                  ),
                  title: Text(item['name'] as String),
                  subtitle: Text("99010101"),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Цаг: ${item['time']}"),
                      Text("${item['pay']}₮"),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text("Нийт төлбөр: $totalPay₮")],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.attach_money),
            label: const Text("Төлөх"),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
