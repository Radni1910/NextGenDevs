import 'package:flutter/material.dart';

// Correct imports with lowercase filenames
import 'AuthWrapper/auth/student_sign_in.dart';
import 'AuthWrapper/splash_screen.dart'; // your splash screen file
import 'AuthWrapper/auth/management_sign_in.dart';

void main() => runApp(const HostelTrackerApp());

/* ===================== MAIN APP ===================== */
class HostelTrackerApp extends StatelessWidget {
  const HostelTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins', useMaterial3: true),
      home: const SplashScreen(), // Splash screen is first
    );
  }
}

/* ===================== ROLE SELECTION SCREEN ===================== */
class RoleSelectionMobile extends StatelessWidget {
  const RoleSelectionMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Reusable logo without text
              const DormTrackLogo(iconSize: 50, showText: false),

              const SizedBox(height: 16),
              const Text(
                'DormTrack',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF14532D),
                ),
              ),
              const Text(
                'Smart Hostel Issue Tracking System',
                style: TextStyle(color: Color(0xFF4D7C0F), fontSize: 16),
              ),
              const SizedBox(height: 48),

              Expanded(
                child: ListView(
                  children: [
                    RoleCard(
                      title: 'Student Portal',
                      subtitle: 'Report issues & track resolutions',
                      icon: Icons.school_rounded,
                      iconGradient: const [
                        Color.fromARGB(255, 84, 191, 240),
                        Color(0xFF2563EB),
                      ],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentSignIn(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    RoleCard(
                      title: 'Management',
                      subtitle: 'Manage facility & assign tasks',
                      icon: Icons.admin_panel_settings_rounded,
                      iconGradient: const [
                        Color.fromARGB(255, 253, 146, 164),
                        Color(0xFFE11D48),
                      ],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManagementSignIn(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Text(
                "Efficiency . Transparency . Accountability",
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/* ===================== ROLE CARD WIDGET ===================== */
class RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> iconGradient;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconGradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: iconGradient),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14532D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== REUSABLE LOGO ===================== */
class DormTrackLogo extends StatelessWidget {
  final double iconSize;
  final bool showText;

  const DormTrackLogo({super.key, this.iconSize = 64, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF57CC99), Color(0xFF80ED99), Color(0xFFC7F9CC)],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF57CC99).withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.domain_rounded,
            size: iconSize,
            color: Colors.white,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 20),
          const Text(
            'DormTrack',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Color(0xFF14532D),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Smart Hostel Issue Tracking System',
            style: TextStyle(color: Color(0xFF4D7C0F), fontSize: 14),
          ),
        ],
      ],
    );
  }
}
