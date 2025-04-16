import 'package:flutter/material.dart';
import '../../models/worker_model.dart';
import '../../widgets/worker_card.dart';
import '../../constant/styles.dart';

class WorkProgressScreen extends StatefulWidget {
  final int initialTabIndex;
  const WorkProgressScreen({super.key, required this.initialTabIndex});

  @override
  State<WorkProgressScreen> createState() => _WorkProgressScreenState();
}

class _WorkProgressScreenState extends State<WorkProgressScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool selecting = false;
  List<Worker> allWorkers = [];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    allWorkers = List.generate(5, (index) {
      return Worker(
        name: 'Worker $index',
        phone: '9901010$index',
        rating: 4.5,
        projects: 12,
        requestTime: '2024-04-15 09:00',
        workStartTime: '2024-04-16 08:00',
        status: 'pendingStart',
      );
    });
    super.initState();
  }

  void resetSelection() {
    setState(() {
      selecting = false;
      for (var worker in allWorkers) {
        worker.selected = false;
      }
    });
  }

  List<Worker> get filtered =>
      allWorkers
          .where(
            (w) =>
                _tabController.index == 0 && w.status == 'pendingStart' ||
                _tabController.index == 1 &&
                    ['working', 'verified'].contains(w.status) ||
                _tabController.index == 2 &&
                    ['completed', 'paiding'].contains(w.status),
          )
          .toList();

  void confirmAction() {
    setState(() {
      for (var worker in allWorkers) {
        if (worker.selected) {
          if (_tabController.index == 0) {
            worker.status = 'working';
          } else if (_tabController.index == 1) {
            worker.status = 'completed';
          } else if (_tabController.index == 2) {
            worker.status = 'paiding';
          }
        }
        worker.selected = false;
      }
      selecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ажлын явц"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.subtitle,
          tabs: const [
            Tab(text: 'Ажилчид'),
            Tab(text: 'Ажлын явц'),
            Tab(text: 'Төлбөр'),
          ],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildList(), _buildList(), _buildList()],
      ),
      bottomNavigationBar:
          list.isEmpty
              ? null
              : Padding(
                padding: const EdgeInsets.all(16),
                child:
                    selecting
                        ? Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: confirmAction,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                child: const Text(
                                  "Батлах",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: resetSelection,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                                child: const Text("Цуцлах"),
                              ),
                            ),
                          ],
                        )
                        : ElevatedButton(
                          onPressed: () => setState(() => selecting = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text(
                            "Сонгох",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
              ),
    );
  }

  Widget _buildList() {
    final list = filtered;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final worker = list[index];
        return WorkerCard(
          worker: worker,
          showCheckbox: selecting,
          onChanged: (val) => setState(() => worker.selected = val ?? false),
        );
      },
    );
  }
}
