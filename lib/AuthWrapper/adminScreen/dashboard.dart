import 'package:flutter/material.dart';
import 'package:dormtrack/AuthWrapper/adminScreen/lostfound.dart';
import 'package:dormtrack/AuthWrapper/adminScreen/issuemanage.dart';
import 'package:dormtrack/AuthWrapper/adminScreen/annoucement.dart';
import 'package:dormtrack/AuthWrapper/adminScreen/analytic.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  // 🎨 Palette
  static const Color primary = Color(0xFF22577A);
  static const Color secondary = Color(0xFF38A3A5);
  static const Color success = Color(0xFF57CC99);
  static const Color highlight = Color(0xFF80ED99);
  static const Color background = Color(0xFFC7F9CC);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isTablet = width >= 650 && width < 1100;

    return Scaffold(
      backgroundColor: background.withOpacity(0.35),
      body: Row(
        children: [
          // 🧭 Sidebar
          if (isDesktop || isTablet)
            NavigationRail(
              extended: isDesktop,
              backgroundColor: Colors.white,
              selectedIndex: _selectedIndex,
              selectedIconTheme: const IconThemeData(color: primary),
              unselectedIconTheme: const IconThemeData(color: Colors.grey),
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: CircleAvatar(
                  backgroundColor: primary,
                  child: const Icon(Icons.admin_panel_settings,
                      color: Colors.white),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                    icon: Icon(Icons.dashboard_rounded),
                    label: Text('Dashboard')),
                NavigationRailDestination(
                    icon: Icon(Icons.bar_chart_rounded),
                    label: Text('Analytics')),
                NavigationRailDestination(
                    icon: Icon(Icons.settings_rounded),
                    label: Text('Settings')),
              ],
            ),

          // 📄 Main Content
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeaderCard(),
                      const SizedBox(height: 28),
                      _sectionTitle("Overview"),
                      const SizedBox(height: 16),
                      _buildStatsRow(),
                      const SizedBox(height: 32),
                      _sectionTitle("Quick Actions"),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
                _buildActionGrid(width),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔝 AppBar
  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        "Admin Dashboard",
        style: TextStyle(fontWeight: FontWeight.bold, color: primary),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          color: primary,
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: secondary,
          child: Icon(Icons.person, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  // 👋 Header Card
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome, Admin 👋",
            style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Monitor hostel operations and manage activities",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // 📊 Stats
  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard("Open Issues", "12", primary),
        _statCard("Resolved", "42", success),
        _statCard("Lost Items", "5", secondary),
        _statCard("Users", "158", primary),
      ],
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 6),
            Text(title,
                style:
                const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // 🧩 Action Grid
  Widget _buildActionGrid(double width) {
    int crossAxisCount = width >= 1200
        ? 4
        : width >= 800
        ? 3
        : 2;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.15,
        ),
        delegate: SliverChildListDelegate([
          _actionCard(
            icon: Icons.assignment_rounded,
            title: "Manage Issues",
            color: primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IssueManageScreen()),
            ),
          ),
          _actionCard(
            icon: Icons.analytics_rounded,
            title: "Analytics",
            color: secondary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen()),
            ),
          ),
          _actionCard(
            icon: Icons.campaign_rounded,
            title: "Announcements",
            color: success,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AdminAnnouncementScreen()),
            ),
          ),
          _actionCard(
            icon: Icons.find_in_page_rounded,
            title: "Lost & Found",
            color: primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminLostFoundScreen()),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.15),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primary),
    );
  }
}
