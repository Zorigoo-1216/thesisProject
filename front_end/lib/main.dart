import 'package:flutter/material.dart';
import './routes/app_routes.dart'; // centralized routes map
import './services/notification_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationOverlay.navigatorKey,
      title: 'Job Match',
      initialRoute: '/splash',
      routes: AppRoutes.routes, // <- use centralized route map
    );
  }
}
