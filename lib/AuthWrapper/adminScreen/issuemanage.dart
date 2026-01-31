import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IssueManageScreen extends StatefulWidget {
  const IssueManageScreen({super.key});

  @override
  State<IssueManageScreen> createState() => _IssueManageScreenState();
}

class _IssueManageScreenState extends State<IssueManageScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';

  // 🔥 UPDATED DARK FOREST PALETTE
  static const Color primaryDark = Color(0xFF0D2310); // Deep Obsidian Green
  static const Color forestGreen = Color(
    0xFF1B5E20,
  ); // Classic Management Green
  static const Color emeraldMed = Color(0xFF2E7D32); // Rich Emerald
  static const Color accentMint = Color(0xFF81C784); // Soft Mint Accent
  static const Color bgLeaf = Color(0xFFF1F8E9); // Very Light Green Wash

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLeaf,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issues')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: forestGreen),
            );
          }

          final allIssues = snapshot.data!.docs;

          final filteredIssues = allIssues.where((doc) {
            final issue = doc.data() as Map<String, dynamic>;
            final status = issue['status'] ?? '';
            final title = issue['title'] ?? '';

            final matchesFilter =
                selectedFilter == 'All' || status == selectedFilter;
            final matchesSearch = title.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );

            return matchesFilter && matchesSearch;
          }).toList();

          return CustomScrollView(
            // Using ScrollView for better header interaction
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header()),
              SliverToBoxAdapter(child: _summaryRow(allIssues)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      _searchBar(),
                      const SizedBox(height: 16),
                      _filterChips(),
                    ],
                  ),
                ),
              ),
              filteredIssues.isEmpty
                  ? const SliverFillRemaining(
                child: Center(
                  child: Text(
                    "No issues found",
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              )
                  : SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) =>
                        _animatedIssueCard(filteredIssues[i], i),
                    childCount: filteredIssues.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= IMPROVED ANIMATED CARD WRAPPER =================
  Widget _animatedIssueCard(QueryDocumentSnapshot doc, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 500)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuint,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _issueCard(doc),
    );
  }

  // ================= HEADER WITH PREMIUM GRADIENT =================
  Widget _header() {
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
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Management Hub",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                "Issue Tracker",
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

  // ================= SUMMARY CARDS WITH DEPTH =================
  Widget _summaryRow(List<QueryDocumentSnapshot> issues) {
    int count(String s) =>
        issues.where((i) => ((i.data() as Map)['status'] ?? '') == s).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _summaryCard(
              "Total",
              issues.length,
              forestGreen,
              Icons.analytics_rounded,
            ),
            _summaryCard(
              "Open",
              count('Open'),
              const Color(0xFFD32F2F),
              Icons.error_outline,
            ),
            _summaryCard(
              "Active",
              count('In Progress'),
              Colors.orange.shade800,
              Icons.loop_rounded,
            ),
            _summaryCard(
              "Solved",
              count('Resolved'),
              const Color(0xFF388E3C),
              Icons.check_circle_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, int count, Color color, IconData icon) {
    return Container(
      width: 110,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: primaryDark,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH BAR =================
  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v),
        decoration: InputDecoration(
          hintText: "Search issues...",
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search_rounded, color: forestGreen),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= FILTER CHIPS =================
  Widget _filterChips() {
    final filters = ['All', 'Open', 'In Progress', 'Resolved'];

    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: filters.map((f) {
          final selected = selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: ChoiceChip(
                label: Text(f),
                selected: selected,
                selectedColor: primaryDark,
                backgroundColor: Colors.white,
                elevation: selected ? 4 : 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? Colors.white : primaryDark,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (_) => setState(() => selectedFilter = f),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= ISSUE CARD =================
  Widget _issueCard(QueryDocumentSnapshot doc) {
    final issue = doc.data() as Map<String, dynamic>;
    final status = issue['status'] ?? 'Unknown';
    final title = issue['title'] ?? 'No Title';
    final location = issue['location'] ?? 'Unknown Location';
    final category = issue['category'] ?? 'General';
    final priority = issue['priority'] ?? 'Low';
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: () => _showDetails(doc),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _statusChip(status, color),
                    const Spacer(),
                    _createdAt(issue['createdAt']),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                    color: primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, thickness: 1),
                ),
                Row(
                  children: [
                    _tag(category, forestGreen, Icons.category_outlined),
                    const SizedBox(width: 8),
                    _tag(
                      priority,
                      _priorityColor(priority),
                      Icons.flag_outlined,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: bgLeaf,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: forestGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _createdAt(dynamic ts) {
    if (ts is Timestamp) {
      return Text(
        ts.toDate().toString().substring(0, 10),
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return const SizedBox();
  }

  Widget _tag(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgLeaf,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= MODERN BOTTOM SHEET =================
  void _showDetails(QueryDocumentSnapshot doc) {
    final issue = doc.data() as Map<String, dynamic>;
    final title = issue['title'] ?? 'No Title';
    final description = issue['description'] ?? 'No description';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Issue Details",
              style: TextStyle(
                color: forestGreen.withOpacity(0.6),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: primaryDark,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 35),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: forestGreen),
                      ),
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('issues')
                          .doc(doc.id)
                          .update({'status': 'In Progress'});
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Mark Active",
                      style: TextStyle(
                        color: forestGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: forestGreen,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('issues')
                          .doc(doc.id)
                          .update({
                        'status': 'Resolved',
                        'resolvedAt': FieldValue.serverTimestamp(),
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Resolve Issue",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================
  Color _statusColor(String s) {
    switch (s) {
      case 'Open':
        return const Color(0xFFE53935);
      case 'In Progress':
        return Colors.orange.shade800;
      case 'Resolved':
        return const Color(0xFF2E7D32);
      default:
        return forestGreen;
    }
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return const Color(0xFFC62828);
      case 'Medium':
        return const Color(0xFFEF6C00);
      case 'Low':
        return forestGreen;
      default:
        return Colors.grey;
    }
  }
}
