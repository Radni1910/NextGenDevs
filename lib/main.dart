import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ✅ Ensure these paths match your actual folder structure
import 'AuthWrapper/splash_screen.dart';
import 'AuthWrapper/auth/student_sign_in.dart';
import 'AuthWrapper/auth/management_sign_in.dart';
import 'widgets/dormtrack_logo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const HostelTrackerApp());
}

class HostelTrackerApp extends StatelessWidget {
  const HostelTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins', useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

// ... (Imports remain exactly the same) ...

class RoleSelectionMobile extends StatefulWidget {
  const RoleSelectionMobile({super.key});

  @override
  State<RoleSelectionMobile> createState() => _RoleSelectionMobileState();
}

class _RoleSelectionMobileState extends State<RoleSelectionMobile>
    with SingleTickerProviderStateMixin {
  String selectedRole = 'Student';
  late AnimationController _borderController;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // 🔰 1. Logo moved further down
              const SizedBox(height: 80),
              const DormTrackLogo(iconSize: 50, showText: false),
              const SizedBox(height: 12),
              const Text(
                'DormTrack',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D47A1),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 35),
              const Text(
                "Choose your role",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Select your role to access your dashboard",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey, fontSize: 14),
              ),

              const SizedBox(height: 35),

              // 💳 Role Cards
              _buildAnimatedCard(
                index: 0,
                child: RoleCard(
                  title: 'Student Portal',
                  subtitle: 'Report issues & track resolutions',
                  svgPath: 'assets/images/student_icon.svg',
                  isSelected: selectedRole == 'Student',
                  borderAnim: _borderController,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => selectedRole = 'Student');
                  },
                ),
              ),

              const SizedBox(height: 20),

              _buildAnimatedCard(
                index: 1,
                child: RoleCard(
                  title: 'Management',
                  subtitle: 'Manage facility & assign tasks',
                  svgPath: 'assets/images/management_icon.svg',
                  isSelected: selectedRole == 'Management',
                  borderAnim: _borderController,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => selectedRole = 'Management');
                  },
                ),
              ),

              // 🚀 2. "Get Started" pulled closer to the Management button
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Widget nextScreen = selectedRole == 'Student'
                        ? const StudentSignIn()
                        : const ManagementSignIn();

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => nextScreen),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Get started",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // 🚀 3. Efficiency/Transparency text moved up
              const SizedBox(height: 16),

              const Text(
                'Efficiency • Transparency • Accountability',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Bottom breathing room
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ... (RoleCard component code remains the same as your previous working version)

/* ===================== IMPROVED MASSIVE ROLE CARD ===================== */
class RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String svgPath;
  final bool isSelected;
  final Animation<double> borderAnim;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.svgPath,
    required this.isSelected,
    required this.borderAnim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: borderAnim,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: isSelected
                      ? SweepGradient(
                    colors: const [
                      Color(0xFF0D47A1),
                      Color(0xFF00ACC1),
                      Color(0xFF80CBC4),
                      Colors.transparent,
                      Color(0xFF0D47A1),
                    ],
                    transform: GradientRotation(
                      borderAnim.value * 2 * math.pi,
                    ),
                  )
                      : null,
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: const Color(
                        0xFF0D47A1,
                      ).withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                      : null,
                ),
                child: Container(
                  // 🚀 Vertical padding adjusted for big SVG
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF8FDFF) : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: !isSelected
                        ? Border.all(color: Colors.grey.shade100, width: 2)
                        : null,
                  ),
                  child: Row(
                    children: [
                      // 🎨 MAXIMIZED SVG FRAME
                      Container(
                        height: 130, // Increased size
                        width: 130, // Increased size
                        padding: const EdgeInsets.all(
                          2,
                        ), // Near-zero padding so SVG fills space
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0D47A1).withValues(alpha: 0.05)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SvgPicture.asset(
                          svgPath,
                          fit: BoxFit.contain, // Ensures SVG hits the edges
                          placeholderBuilder: (context) => Icon(
                            title.contains('Student')
                                ? Icons.school_rounded
                                : Icons.admin_panel_settings_rounded,
                            size: 60,
                            color: isSelected
                                ? const Color(0xFF0D47A1)
                                : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 📝 TEXT SECTION
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isSelected
                                    ? const Color(0xFF0D47A1)
                                    : const Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? Colors.blue.shade900
                                    : Colors.blueGrey.shade600,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ✅ CAPCUT STYLE SELECTION BADGE
          if (isSelected)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00ACC1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
