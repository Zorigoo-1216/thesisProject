import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/socket_service.dart';
import 'home_screen.dart';
import 'joblist_screen.dart';
import 'employer_screen.dart';
import 'application_screen.dart';
//import 'application_screen.dart';
import 'profile_screen.dart';

//import 'profile_screen.dart'; // энэ бол таны хэрэглэгчийн профайл хуудас

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  String? userId; // ⬅️ userId хадгалах

  final Color primaryColor = const Color(0xFF636AE8);

  final List<Widget> _screens = const [
    HomeScreen(),
    JobListScreen(),
    EmployerScreen(),
    ApplicationScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUser(); // Энэ нь socket холбох кодыг найдвартай үед эхлүүлнэ
    });
  }

  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final storedUserId = prefs.getString('userId');

    print("🛰 Connecting socket with userId: $storedUserId");
    if (token != null && storedUserId != null) {
      setState(() {
        userId = storedUserId;
      });
      SocketService().connect(token, storedUserId);
      print(
        '🛰 Connecting socket with userId: $storedUserId',
      ); // ✅ Socket-д бүртгэх
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Joblist'),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Employer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Application',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
