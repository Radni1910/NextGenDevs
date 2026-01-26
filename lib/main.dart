import 'package:dormtrack/AuthWrapper/StudentScreens/dashboard.dart';
import 'package:dormtrack/AuthWrapper/adminScreen/dashboard.dart';
import 'package:flutter/material.dart';

void main() => runApp(const HostelTrackerApp());

class HostelTrackerApp extends StatelessWidget {
  const HostelTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Inter', useMaterial3: true),
      home: const RoleSelectionMobile(),
    );
  }
}

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
              // Header Section
              const Icon(
                Icons.domain_rounded,
                color: Color(0xFF6366F1),
                size: 50,
              ),
              const SizedBox(height: 16),
              const Text(
                'DormTrack',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Text(
                'Smart Campus Management System',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
              ),
              const SizedBox(height: 48),

              // STACKED CARDS (Vertical Layout)
              Expanded(
                child: ListView(
                  children: [
                    RoleCard(
                      title: 'Student Portal',
                      subtitle: 'Report issues & track resolutions',
                      icon: Icons.school_rounded,
                      iconGradient: const [
                        Color(0xFF0EA5E9),
                        Color(0xFF2563EB),
                      ],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentDashboard(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    RoleCard(
                      title: 'Management',
                      subtitle: 'Manage facility & assign tasks',
                      icon: Icons.admin_panel_settings_rounded,
                      iconGradient: const [
                        Color(0xFFF43F5E),
                        Color(0xFFE11D48),
                      ],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AdminDashboard(),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: iconGradient),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
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
    );
  }
}
