import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:dormtrack/services/analytics_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  AdminAnalyticsScreen({super.key});
  final AnalyticsService analytics = AnalyticsService();

  static const Color primaryDark = Color(0xFF0D2310);
  static const Color forestGreen = Color(0xFF1B5E20);
  static const Color emeraldMed = Color(0xFF2E7D32);
  static const Color bgLeaf = Color(0xFFF1F8E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLeaf,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _animatedWrapper(child: _overviewSection(), delay: 100),
                  const SizedBox(height: 32),
                  _animatedWrapper(
                    child: _sectionTitle("Issue Resolution Progress"),
                    delay: 200,
                  ),
                  const SizedBox(height: 16),
                  _animatedWrapper(child: _statusProgress(), delay: 300),
                  const SizedBox(height: 32),
                  _animatedWrapper(
                    child: _sectionTitle("Category Distribution"),
                    delay: 400,
                  ),
                  const SizedBox(height: 16),
                  _animatedWrapper(child: _categoryCards(), delay: 500),
                  const SizedBox(height: 32),
                  _animatedWrapper(
                    child: _sectionTitle("Operational Insights"),
                    delay: 600,
                  ),
                  const SizedBox(height: 16),
                  _animatedWrapper(child: _recentInsights(), delay: 700),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedWrapper({required Widget child, required int delay}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuint,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryDark, forestGreen, emeraldMed],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Data & Intelligence",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                "Analytics Hub",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewSection() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        StreamBuilder<int>(
          stream: analytics.totalIssues(),
          builder: (context, snapshot) => _overviewCard(
            "Total Issues",
            (snapshot.data ?? 0).toString(),
            Icons.analytics,
            forestGreen,
          ),
        ),
        StreamBuilder<int>(
          stream: analytics.resolvedIssues(),
          builder: (context, snapshot) => _overviewCard(
            "Resolved",
            (snapshot.data ?? 0).toString(),
            Icons.verified,
            emeraldMed,
          ),
        ),
        StreamBuilder<int>(
          stream: analytics.openIssues(),
          builder: (context, snapshot) => _overviewCard(
            "Pending",
            (snapshot.data ?? 0).toString(),
            Icons.hourglass_top_rounded,
            Colors.orange.shade800,
          ),
        ),
        StreamBuilder<int>(
          stream: FirebaseFirestore.instance
              .collection('lostFound')
              .snapshots()
              .map((s) => s.size),
          builder: (context, snapshot) => _overviewCard(
            "Lost & Found",
            (snapshot.data ?? 0).toString(),
            Icons.inventory_2_rounded,
            Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  Widget _overviewCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(
            count,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              fontFamily: 'Poppins',
              color: primaryDark,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusProgress() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('issues').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(
            child: CircularProgressIndicator(color: forestGreen),
          );
        final docs = snapshot.data!.docs;
        final total = docs.length;
        if (total == 0) return const SizedBox();
        final resolved = docs
            .where(
              (d) =>
          d.data().toString().contains('status') &&
              d['status'] == 'Resolved',
        )
            .length;
        final open = docs
            .where(
              (d) =>
          d.data().toString().contains('status') &&
              d['status'] == 'Open',
        )
            .length;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              _progressTile("Resolution Rate", resolved / total, emeraldMed),
              const SizedBox(height: 20),
              _progressTile(
                "Pending Requests",
                open / total,
                Colors.red.shade800,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _progressTile(String title, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
            Text(
              "${(value * 100).toInt()}%",
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _categoryCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('issues').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(
            child: CircularProgressIndicator(color: forestGreen),
          );
        Map<String, int> categoryCount = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          categoryCount[data['category'] ?? 'Others'] =
              (categoryCount[data['category'] ?? 'Others'] ?? 0) + 1;
        }
        return _categoryPieChart(categoryCount);
      },
    );
  }

  Widget _categoryPieChart(Map<String, int> categoryCount) {
    // 🔥 VIBRANT MULTI-COLOR PALETTE
    final List<Color> vibrantColors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.deepPurpleAccent,
      Colors.tealAccent.shade700,
      Colors.pinkAccent,
      Colors.amber,
      Colors.indigoAccent,
    ];
    int index = 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          SizedBox(
            height: 320,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 70,
                sectionsSpace: 8,
                sections: categoryCount.entries.map((entry) {
                  final color = vibrantColors[index % vibrantColors.length];
                  index++;
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    color: color,
                    radius: 90,
                    showTitle: true,
                    title: '${entry.value}',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 40,
              crossAxisSpacing: 10,
            ),
            itemCount: categoryCount.length,
            itemBuilder: (context, i) {
              final entry = categoryCount.entries.elementAt(i);
              final color = vibrantColors[i % vibrantColors.length];
              return Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _recentInsights() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('issues').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final docs = snapshot.data!.docs;
        Map<String, int> hostelCount = {};
        for (var doc in docs) {
          final h = (doc.data() as Map)['userHostel'] ?? 'General';
          hostelCount[h] = (hostelCount[h] ?? 0) + 1;
        }
        String topHostel = hostelCount.isNotEmpty
            ? hostelCount.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key
            : "N/A";

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              _insightTile(
                "Highest Volume: $topHostel",
                Icons.location_on_rounded,
              ),
              const Divider(indent: 70, endIndent: 20),
              _insightTile(
                "Reporting Trends: Stable",
                Icons.trending_up_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        fontFamily: 'Poppins',
        color: primaryDark,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  Widget _insightTile(String text, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgLeaf,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: forestGreen, size: 20),
      ),
      title: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: primaryDark,
          fontSize: 14,
        ),
      ),
    );
  }
}
