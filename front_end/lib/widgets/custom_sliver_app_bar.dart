import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/styles.dart';

class CustomSliverAppBar extends StatelessWidget {
  final TabController? tabController;
  final bool showTabs;
  final bool showBack;
  final List<Tab>? tabs;

  const CustomSliverAppBar({
    super.key,
    this.tabController,
    this.showTabs = false,
    this.showBack = true,
    this.tabs,
  });

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.background,
      leading:
          showBack
              ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primary, // 🎯 Энд өнгөө өөрчил
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
              : null,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none,
            color: AppColors.iconColor,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/notification');
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: AppColors.iconColor),
          onPressed: () {},
        ),
        GestureDetector(
          onTapDown: (details) {
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                details.globalPosition.dx,
                details.globalPosition.dy,
                0,
                0,
              ),
              items: [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(Icons.logout, color: AppColors.iconColor),
                      SizedBox(width: 8),
                      Text("Гарах"),
                    ],
                  ),
                ),
              ],
            ).then((value) {
              if (value == 'logout') _logout(context);
            });
          },
          child: const CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage('assets/images/avatar.png'),
          ),
        ),
        const SizedBox(width: 12),
      ],
      bottom:
          (showTabs &&
                  tabController != null &&
                  tabs != null &&
                  tabs!.isNotEmpty)
              ? TabBar(
                controller: tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                tabs: tabs!,
              )
              : null,
    );
  }
}
