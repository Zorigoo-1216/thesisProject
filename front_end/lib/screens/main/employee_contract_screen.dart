import 'package:flutter/material.dart';
import '../../constant/styles.dart';

class EmployeeContractScreen extends StatefulWidget {
  const EmployeeContractScreen({super.key});

  @override
  State<EmployeeContractScreen> createState() => _EmployeeContractScreenState();
}

class _EmployeeContractScreenState extends State<EmployeeContractScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Гэрээ"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.notifications_none, color: AppColors.primary),
          SizedBox(width: 12),
          Icon(Icons.settings, color: AppColors.text),
          SizedBox(width: 12),
        ],
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [Tab(text: 'Гэрээ'), Tab(text: 'Гэрээний хураангуй')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _contractText(),
                _contractText(), // You can replace with summary content
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Accept contract API
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                  ),
                ),
                child: const Text("Батлах"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Cancel logic
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                  ),
                ),
                child: const Text(
                  "Татгалзах",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contractText() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Text(
          '''Ullamco pariatur amet adipisicing proident qui magna exercitation ad laboris ad proident. Cillum id exercitation nisi commodo aliqua aute deserunt deserunt elit sit pariatur excepteur. Aliqua ullamco eiusmod id ipsum id adipisicing nostrud fugiat reprehenderit reprehenderit amet officia ea proident ut. Aliqua sint mollit amet incididunt et quis officia do amet sit sint anim consequat nostrud amet sit. Consequat incididunt excepteur sunt ut esse id ut aute officia proident anim. Excepteur dolor aliquip esse quis labore ea ad nulla nulla non officia aliqua eu ex. Eiusmod cupidatat sunt exercitation Lorem occaecat Lorem veniam non sunt amet proident nisi reprehenderit.''',
          style: AppTextStyles.body,
        ),
      ),
    );
  }
}
