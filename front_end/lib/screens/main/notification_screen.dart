import 'package:flutter/material.dart';
import '../../widgets/custom_sliver_app_bar.dart';
import '../../constant/styles.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  final List<Map<String, dynamic>> notifications = const [
    {
      "title": "Шинэ ажилтай таарч байна",
      "message": "Танд тохирох цэвэрлэгээний ажил нэмэгдлээ.",
      "isRead": false,
      "time": "5 минутын өмнө",
    },
    {
      "title": "Гэрээ баталгаажсан",
      "message": "Та гэрээгээ амжилттай баталгаажууллаа.",
      "isRead": true,
      "time": "Өчигдөр",
    },
    {
      "title": "Цалин шилжлээ",
      "message": "8,000₮ таны данс руу шилжлээ.",
      "isRead": true,
      "time": "2 өдрийн өмнө",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const CustomSliverAppBar(showTabs: false, showBack: true),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children:
                      notifications.map((notif) {
                        return Card(
                          color:
                              notif['isRead']
                                  ? Colors.white
                                  : AppColors.primary.withOpacity(0.05),
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Icon(
                              notif['isRead']
                                  ? Icons.notifications_none
                                  : Icons.notifications_active,
                              color: AppColors.primary,
                            ),
                            title: Text(
                              notif['title'],
                              style: TextStyle(
                                fontWeight:
                                    notif['isRead']
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(notif['message']),
                            trailing: Text(
                              notif['time'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
