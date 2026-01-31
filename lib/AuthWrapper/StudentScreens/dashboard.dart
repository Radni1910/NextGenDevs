import 'dart:math' as math;
import 'package:dormtrack/AuthWrapper/StudentScreens/announcement_screen.dart';
import 'package:dormtrack/AuthWrapper/StudentScreens/lost_found_screen.dart';
import 'package:dormtrack/AuthWrapper/StudentScreens/my_issues_screen.dart';
import 'package:dormtrack/AuthWrapper/StudentScreens/report_issue_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  // Logic Variables
  String studentName = "Student";
  String hostelDisplay = "";
  bool isLoading = true;
  String latestAnnouncement = "";
  String latestAnnouncementTitle = "";
  OverlayEntry? _notificationOverlay;
  late AnimationController _borderController;

  // Theme Constants (matching your provided style)
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color accentTeal = Color(0xFF00ACC1);
  static const Color lightBg = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _loadStudentData();
    _loadLatestAnnouncement();
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  // ================= LOGIC: STUDENT DATA =================
  Future<void> _loadStudentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!doc.exists) return;
    final data = doc.data()!;
    setState(() {
      studentName = data['name'] ?? 'Student';
      hostelDisplay = data['hostel']?.toString() ?? '';
      isLoading = false;
    });
  }

  // ================= LOGIC: ANNOUNCEMENT =================
  Future<void> _loadLatestAnnouncement() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('announcements')
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final data = snap.docs.first.data();
        setState(() {
          latestAnnouncementTitle = data['title'] ?? '';
          latestAnnouncement = data['message'] ?? '';
        });
      }
    } catch (_) {}
  }

  // ================= LOGIC: STREAMS =================
  Stream<int> openIssuesCountStream(String uid) {
    return FirebaseFirestore.instance
        .collection('issues')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        final status =
            doc.data()['status']?.toString().toLowerCase() ?? 'open';
        return status != 'resolved';
      }).length;
    });
  }

  // ================= LOGIC: NOTIFICATION OVERLAY =================
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
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi $studentName!",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: primaryBlue,
                        ),
                      ),
                      Text(
                        hostelDisplay.isNotEmpty
                            ? hostelDisplay
                            : "Welcome Back",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _toggleNotificationOverlay,
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.notifications_active_outlined,
                            color: primaryBlue,
                            size: 28,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // --- BENTO HERO CARD (Animated Border) ---
              _buildBentoHeroCard(),

              const SizedBox(height: 25),
              const Text(
                "Overview",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 12),

              // --- STATS ROW ---
              Row(
                children: [
                  Expanded(
                    child: _DerivedStudentStat(
                      label: "Open",
                      stream: openIssuesCountStream(uid),
                      color: Colors.red.shade50,
                      iconColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RealtimeStudentStat(
                      label: "Resolved",
                      color: Colors.green.shade50,
                      iconColor: Colors.green,
                      stream: FirebaseFirestore.instance
                          .collection('issues')
                          .where('userId', isEqualTo: uid)
                          .where('status', isEqualTo: 'Resolved')
                          .snapshots(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RealtimeStudentStat(
                      label: "Lost",
                      color: Colors.orange.shade50,
                      iconColor: Colors.orange,
                      stream: FirebaseFirestore.instance
                          .collection('lost_found_items')
                          .where('userId', isEqualTo: uid)
                          .where('status', isEqualTo: 'lost')
                          .snapshots(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 15),

              // --- GRID MENU ---
              _buildGridMenu(context),

              const SizedBox(height: 25),
              _buildAnnouncementPreview(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- BIGGER BENTO HERO WIDGET ---
  Widget _buildBentoHeroCard() {
    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          // Massive height for a bold look
          constraints: const BoxConstraints(minHeight: 280),
          padding: const EdgeInsets.all(
            3.5,
          ), // Slightly thicker animated border
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            gradient: SweepGradient(
              colors: const [
                primaryBlue,
                accentTeal,
                Colors.transparent,
                primaryBlue,
              ],
              transform: GradientRotation(
                _borderController.value * 2 * math.pi,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              // Subtle inner shadow for depth
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        "DormTrack\nDashboard",
                        style: TextStyle(
                          fontSize: 32, // Large headline
                          fontWeight: FontWeight.w900,
                          color: primaryBlue,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    // Illustration moved to the top right
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: SvgPicture.asset(
                        'assets/images/role_hero_illustration.svg',
                        placeholderBuilder: (_) => const Icon(
                          Icons.auto_awesome,
                          size: 70,
                          color: accentTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your central hub for hostel life.",
                      style: TextStyle(
                        color: Colors.blueGrey.shade700,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Monitor your reported issues, check lost items, and stay in the loop with official hostel announcements in real-time.",
                      style: TextStyle(
                        color: Colors.blueGrey.shade400,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- GRID MENU ---
  Widget _buildGridMenu(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 0.95, // Adjusted for the new layout
      children: [
        _menuCard(
          context,
          "Report Issue",
          Icons.add_chart_rounded,
          "images/report.png",
          const Color(0xFFE0F2F1),
          accentTeal,
          const ReportIssueScreen(),
        ),
        _menuCard(
          context,
          "My Issues",
          Icons.list_alt_rounded,
          "images/myissue.png",
          const Color(0xFFE3F2FD),
          primaryBlue,
          const MyIssuesScreen(),
        ),
        _menuCard(
          context,
          "Announcements",
          Icons.campaign_rounded,
          "images/announce.png",
          const Color(0xFFFFF3E0),
          Colors.orange,
          const AnnouncementsScreen(),
        ),
        _menuCard(
          context,
          "Lost & Found",
          Icons.search_rounded,
          "images/lostfound.png",
          const Color(0xFFF1F8E9),
          Colors.green,
          const LostFoundScreen(),
        ),
      ],
    );
  }

  Widget _menuCard(
      BuildContext context,
      String title,
      IconData icon, // Re-added icon
      String imagePath, // PNG path
      Color bgColor,
      Color iconColor,
      Widget target,
      ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context, MaterialPageRoute(builder: (_) => target));
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            // 1. TOP LEFT ICON
            Positioned(
              top: 15,
              left: 15,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20), // Smaller icon
              ),
            ),

            // 2. CENTER ILLUSTRATION
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(
                  35.0,
                ), // Keeps image from touching edges
                child: Center(
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
              ),
            ),

            // 3. BOTTOM TEXT
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: primaryBlue,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ANNOUNCEMENT PREVIEW ---
  Widget _buildAnnouncementPreview() {
    if (latestAnnouncement.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Latest Update",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  latestAnnouncement,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- NOTIFICATION CARD ---
  Widget _notificationCard() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Material(
      elevation: 20,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 320,
        constraints: const BoxConstraints(maxHeight: 400),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Updates",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const Divider(height: 25),
              const Text(
                "Issues",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('issues')
                    .where('userId', isEqualTo: uid)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Text(
                      "No updates",
                      style: TextStyle(fontSize: 12),
                    );
                  }
                  return Column(
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final status = data['status'] ?? 'Open';
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.circle,
                          size: 10,
                          color: _statusColor(status),
                        ),
                        title: Text(
                          data['title'] ?? 'Issue',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            color: _statusColor(status),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.redAccent;
    }
  }
}

// --- STAT BOX COMPONENTS ---
class _RealtimeStudentStat extends StatelessWidget {
  final String label;
  final Stream<QuerySnapshot> stream;
  final Color color;
  final Color iconColor;

  const _RealtimeStudentStat({
    required this.label,
    required this.stream,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return _StatBox(
          label: label,
          value: count.toString(),
          color: color,
          iconColor: iconColor,
        );
      },
    );
  }
}

class _DerivedStudentStat extends StatelessWidget {
  final String label;
  final Stream<int> stream;
  final Color color;
  final Color iconColor;

  const _DerivedStudentStat({
    required this.label,
    required this.stream,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return _StatBox(
          label: label,
          value: count.toString(),
          color: color,
          iconColor: iconColor,
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color iconColor;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: iconColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
