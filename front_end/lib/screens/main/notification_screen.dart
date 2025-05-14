import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/custom_sliver_app_bar.dart';
import '../../constant/styles.dart';
import '../../constant/api.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationsFromPrefs();
  }

  Future<void> _loadNotificationsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      await fetchNotifications(userId);
    } else {
      debugPrint("⚠️ userId not found in SharedPreferences");
    }
    setState(() => isLoading = false);
  }

  Future<void> fetchNotifications(String userId) async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse('${baseUrl}notifications/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List<dynamic> list = data['data'] ?? [];
      setState(() {
        notifications = List<Map<String, dynamic>>.from(list);
      });
    } else {
      debugPrint("❌ Notification fetch error: ${res.body}");
    }

    setState(() => isLoading = false);
  }

  Future<void> markAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.put(
      Uri.parse('${baseUrl}notifications/$notificationId/read'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      setState(() {
        final index = notifications.indexWhere(
          (n) => n['_id'] == notificationId,
        );
        if (index != -1) notifications[index]['isRead'] = true;
      });
    } else {
      debugPrint("❌ Failed to mark as read: ${res.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                slivers: [
                  const CustomSliverAppBar(showTabs: false, showBack: true),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children:
                            notifications.map((notif) {
                              return GestureDetector(
                                onTap: () => markAsRead(notif['_id']),
                                child: Card(
                                  color:
                                      notif['isRead']
                                          ? Colors.white
                                          : AppColors.primary.withOpacity(0.05),
                                  elevation: 0,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
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
                                      notif['time'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
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
    );
  }
}
