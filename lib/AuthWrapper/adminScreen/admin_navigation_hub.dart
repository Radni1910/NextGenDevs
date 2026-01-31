import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard.dart';
import 'admin_leave_approval.dart';
import 'edit_menu_screen.dart';
import 'admin_profile.dart';

class AdminNavigationHub extends StatefulWidget {
  const AdminNavigationHub({super.key});

  @override
  State<AdminNavigationHub> createState() => _AdminNavigationHubState();
}

// ✅ Added TickerProvider for the animation
class _AdminNavigationHubState extends State<AdminNavigationHub>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    // ✅ Initialize the spinning glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.initState();
  }

  final List<Widget> _screens = [
    const AdminDashboard(),
    const AdminLeaveApproval(),
    const EditMenuScreen(),
    const AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF1F8E9,
      ), // Light background to make the dark bar pop
      body: Stack(
        // ✅ Using Stack so the Nav bar can float at the bottom
        children: [
          SafeArea(
            child: IndexedStack(index: _selectedIndex, children: _screens),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ManagementCustomNavBar(
              selectedIndex: _selectedIndex,
              glowController: _glowController,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ The Dark Forest Animated NavBar
class ManagementCustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final AnimationController glowController;

  const ManagementCustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 DARK FOREST COLORS
    const Color forestGreen = Color(0xFF1B5E20);
    const Color emeraldGlow = Color(0xFF4CAF50);
    const Color deepForest = Color(0xFF0D2310);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: deepForest.withOpacity(0.95), // Dark background
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            0,
            Icons.dashboard_rounded,
            "Home",
            forestGreen,
            emeraldGlow,
          ),
          _navItem(
            1,
            Icons.event_note_rounded,
            "Leaves",
            forestGreen,
            emeraldGlow,
          ),
          _navItem(
            2,
            Icons.restaurant_menu_rounded,
            "Menu",
            forestGreen,
            emeraldGlow,
          ),
          _navItem(
            3,
            Icons.person_rounded,
            "Profile",
            forestGreen,
            emeraldGlow,
          ),
        ],
      ),
    );
  }

  Widget _navItem(
      int index,
      IconData icon,
      String label,
      Color primary,
      Color accent,
      ) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onItemSelected(index);
      },
      child: AnimatedBuilder(
        animation: glowController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: isSelected
                  ? SweepGradient(
                colors: [
                  primary,
                  accent,
                  const Color(0xFFA5D6A7), // Mint
                  Colors.transparent,
                  primary,
                ],
                transform: GradientRotation(
                  glowController.value * 2 * math.pi,
                ),
              )
                  : null,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE8F5E9)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? primary : Colors.white60,
                    size: 24,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
