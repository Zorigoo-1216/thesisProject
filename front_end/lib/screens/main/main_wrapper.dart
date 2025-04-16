import 'package:flutter/material.dart';
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

  final Color primaryColor = const Color(0xFF636AE8);

  final List<Widget> _screens = const [
    HomeScreen(),
    JobListScreen(),
    EmployerScreen(),
    ApplicationScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
