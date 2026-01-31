import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this is added
import 'package:dormtrack/AuthWrapper/adminScreen/lostfound.dart';
import 'package:dormtrack/AuthWrapper/adminScreen/issuemanage.dart';
import 'package:dormtrack/AuthWrapper/adminScreen/announcement.dart';
import 'package:dormtrack/AuthWrapper/adminScreen/analytic.dart';
import 'package:dormtrack/AuthWrapper/adminScreen/assignment.dart';
import 'package:lottie/lottie.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _notificationOverlay;
  late AnimationController _borderController;
  String adminName = "Admin";
  bool isLoading = true;

  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color accentTeal = Color(0xFF00897B);
  static const Color lightBg = Color(0xFFF1F8E9);

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _loadAdminData();
  }

  @override
  void dispose() {
    _borderController.dispose();
    _notificationOverlay?.remove();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('management')
        .doc(user.uid)
        .get();

    if (mounted) {
      setState(() {
        if (doc.exists) {
          adminName = doc.data()?['name'] ?? 'Super Admin';
        }
        isLoading = false;
      });
    }
  }

  void _toggleNotificationOverlay() {
    if (_notificationOverlay != null) {
      _notificationOverlay!.remove();
      _notificationOverlay = null;
      return;
    }
    _notificationOverlay = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _notificationOverlay?.remove();
          _notificationOverlay = null;
        },
        child: Stack(
          children: [
            Positioned(
              top: kToolbarHeight + 20,
              right: 20,
              child: _notificationCard(),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_notificationOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Center(
        child: CircularProgressIndicator(color: primaryGreen),
      );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, $adminName",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: primaryGreen,
                    ),
                  ),
                  const Text(
                    "Management Portal",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _toggleNotificationOverlay,
                child: const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.notifications_active_outlined,
                    color: primaryGreen,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildBentoHeroCard(),
          const SizedBox(height: 25),
          const Text(
            "System Overview",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AdminStat(
                  label: "Open",
                  collection: "issues",
                  color: Colors.red.shade50,
                  iconColor: Colors.red,
                  filterField: "status",
                  filterValue: "Resolved",
                  inverse: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AdminStat(
                  label: "Resolved",
                  collection: "issues",
                  color: Colors.green.shade50,
                  iconColor: Colors.green,
                  filterField: "status",
                  filterValue: "Resolved",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AdminStat(
                  label: "Items",
                  collection: "lost_found_items",
                  color: Colors.orange.shade50,
                  iconColor: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 15),
          _buildGridMenu(),
          const SizedBox(
            height: 100,
          ), // ✅ Extra space so the bottom nav doesn't cover the last cards
        ],
      ),
    );
  }

  Widget _buildBentoHeroCard() {
    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 320,
          ), // Increased height for the animation
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: SweepGradient(
              colors: const [
                primaryGreen,
                accentTeal,
                Colors.transparent,
                primaryGreen,
              ],
              transform: GradientRotation(
                _borderController.value * 2 * math.pi,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(37),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Lottie Animation (Top)
                SizedBox(
                  height: 160, // Large area for the manager.json animation
                  child: Lottie.asset(
                    'animations/manager.json',
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
                const SizedBox(height: 15),

                // 2. Title (Single Line)
                const Text(
                  "Admin Control Center",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: primaryGreen,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // 3. Subtext (Exactly 2 Lines)
                Text(
                  "Efficiently manage your dormitory operations, track issues in real-time,\nand maintain communication with all residents from this dashboard.",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridMenu() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 0.85, // Made taller to accommodate much bigger images
      children: [
        _menuCard(
          "Manage Issues",
          'images/manage_issues.svg',
          Icons.assignment_rounded,
          const Color(0xFFE0F2F1),
          accentTeal,
          const IssueManageScreen(),
          isSvg: true,
        ),
        _menuCard(
          "Analytics",
          'images/report.png',
          Icons.analytics_rounded,
          const Color(0xFFE3F2FD),
          Colors.blue,
          AdminAnalyticsScreen(),
          isSvg: false,
        ),
        _menuCard(
          "Announcements",
          'images/announce.png',
          Icons.campaign_rounded,
          const Color(0xFFFFF3E0),
          Colors.orange,
          const AdminAnnouncementScreen(),
          isSvg: false,
        ),
        _menuCard(
          "Lost & Found",
          'images/lostfound.png',
          Icons.find_in_page_rounded,
          const Color(0xFFF1F8E9),
          Colors.green,
          const AdminLostFoundScreen(),
          isSvg: false,
        ),
        _menuCard(
          "Assignments",
          'images/assignment.svg',
          Icons.task_alt_rounded,
          const Color(0xFFF3E5F5),
          Colors.purple,
          const AssignmentScreen(),
          isSvg: true,
        ),
      ],
    );
  }

  Widget _menuCard(
      String title,
      String assetPath,
      IconData icon,
      Color bgColor,
      Color themeColor,
      Widget target, {
        required bool isSvg,
      }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context, MaterialPageRoute(builder: (_) => target));
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: themeColor.withOpacity(0.3), width: 2),
        ),
        child: Stack(
          children: [
            // 1. Initial Logo (Top Left)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: themeColor, size: 16),
              ),
            ),

            // 2. Main Large Image (Centered and Enlarged)
            Positioned.fill(
              top: 30, // Brought higher up
              bottom: 45, // Leaves just enough room for text
              child: Padding(
                padding: const EdgeInsets.all(
                  8.0,
                ), // Reduced padding to let image grow
                child: Center(
                  child: isSvg
                      ? SvgPicture.asset(assetPath, fit: BoxFit.contain)
                      : Image.asset(assetPath, fit: BoxFit.contain),
                ),
              ),
            ),

            // 3. Title (Bottom Center)
            // 3. Title (Bottom Center)
            Positioned(
              bottom: 15,
              left: 8,
              right: 8,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  // Removed 'const' because themeColor is dynamic
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color:
                  themeColor, // <--- This will now match the icon/border color of each card
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationCard() {
    return Material(
      elevation: 20,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "System Updates",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            Divider(),
            Text(
              "Check recent activities in management logs.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  final String label;
  final String collection;
  final Color color;
  final Color iconColor;
  final String? filterField;
  final dynamic filterValue;
  final bool inverse;

  const _AdminStat({
    required this.label,
    required this.collection,
    required this.color,
    required this.iconColor,
    this.filterField,
    this.filterValue,
    this.inverse = false,
  });

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection(collection);
    if (filterField != null) {
      query = inverse
          ? query.where(filterField!, isNotEqualTo: filterValue)
          : query.where(filterField!, isEqualTo: filterValue);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: iconColor,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: iconColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
