import 'package:flutter/material.dart';
//import 'package:jobmatch/routes/app_routes.dart';
//import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/start');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // You can update this
      body: Center(
        child: Image.asset(
          'assets/images/logo.png', // 🖼️ your splash logo path
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
