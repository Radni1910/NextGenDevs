import 'package:flutter/material.dart';
import '../../widgets/custom_nav_bar.dart';
import 'leave_request_screen.dart';
import 'dashboard.dart'; // ✅ This is the essential import you caught
import 'mess_menu_screen.dart'; // ✅ Required for the Mess Menu tab
import 'profile_screen.dart'; // ✅ Required for the Profile tab

class StudentMainWrapper extends StatefulWidget {
  const StudentMainWrapper({super.key});

  @override
  State<StudentMainWrapper> createState() => _StudentMainWrapperState();
}

class _StudentMainWrapperState extends State<StudentMainWrapper>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _glowController;

  // These are the actual screens that will swap in the body
  final List<Widget> _pages = [
    const StudentDashboard(), // Index 0
    const MessMenuScreen(), // Index 1
    const LeaveRequestScreen(), // Index 2
    const ProfileScreen(), // Index 3

    const Center(
      child: Text("Profile", style: TextStyle(fontSize: 24)),
    ), // Index 3
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, // Allows content to flow behind the floating nav bar
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _currentIndex,
        glowController: _glowController,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
