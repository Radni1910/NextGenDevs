import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen>
    with TickerProviderStateMixin {
  // 🎨 Premium Theme Palette
  static const Color primaryDark = Color(0xFF0D2310);
  static const Color forestGreen = Color(0xFF1B5E20);
  static const Color bgLeaf = Color(0xFFF1F8E9);
  static const Color borderGreen = Color(0xFFC8E6C9);

  String selectedFilter = 'All';

  // Changed to nullable to prevent LateInitializationError
  AnimationController? _summaryController;

  @override
  void initState() {
    super.initState();
    // ⚙️ Safe Initialization
    _summaryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Start after the first frame is painted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _summaryController?.forward();
    });
  }

  @override
  void dispose() {
    _summaryController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLeaf,
      body: Column(
        children: [
          _buildPremiumHeader(context),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('issues')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: forestGreen),
                  );
                }

                final allIssues = snapshot.data?.docs ?? [];
                final filteredIssues = allIssues.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'Unassigned';
                  return selectedFilter == 'All' || status == selectedFilter;
                }).toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  children: [
                    _buildAnimatedSummary(allIssues),
                    const SizedBox(height: 24),
                    _buildPremiumFilters(),
                    const SizedBox(height: 12),
                    ...filteredIssues
                        .map((doc) => _buildIssueCard(doc))
                        .toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= PREMIUM HEADER =================
  Widget _buildPremiumHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 50, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryDark, forestGreen],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Issue Assignment",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ================= ANIMATED SUMMARY TILES =================
  Widget _buildAnimatedSummary(List<QueryDocumentSnapshot> issues) {
    int unassigned = issues
        .where((i) => ((i.data() as Map)['assignedTo'] == null))
        .length;
    int assigned = issues
        .where((i) => ((i.data() as Map)['assignedTo'] != null))
        .length;
    int done = issues
        .where((i) => ((i.data() as Map)['status'] == 'Resolved'))
        .length;

    return Row(
      children: [
        _staggeredTile('Total', issues.length, Colors.blueAccent, 0),
        _staggeredTile('Pending', unassigned, Colors.redAccent, 1),
        _staggeredTile('Assigned', assigned, Colors.orangeAccent, 2),
        _staggeredTile('Done', done, forestGreen, 3),
      ],
    );
  }

  Widget _staggeredTile(String label, int count, Color color, int index) {
    if (_summaryController == null) return const SizedBox();

    // 🎭 FIXED: Using easeOutBack for that premium pop effect
    final animation = CurvedAnimation(
      parent: _summaryController!,
      curve: Interval((0.15 * index), 1.0, curve: Curves.easeOutBack),
    );

    return Expanded(
      child: ScaleTransition(
        scale: animation,
        child: FadeTransition(
          opacity: animation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderGreen),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= PREMIUM FILTERS =================
  Widget _buildPremiumFilters() {
    final filters = ['All', 'Unassigned', 'In Progress', 'Resolved'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: true,
              checkmarkColor: Colors.white, // Visible white checkmark
              label: Text(f),
              selected: isSelected,
              selectedColor: forestGreen,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              onSelected: (_) => setState(() => selectedFilter = f),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: isSelected ? forestGreen : borderGreen),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= ISSUE CARD =================
  Widget _buildIssueCard(QueryDocumentSnapshot doc) {
    final issue = doc.data() as Map<String, dynamic>;
    final assignedTo = issue['assignedTo'];
    final priority = (issue['priority'] ?? 'Medium').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _priorityBadge(priority),
              Text(
                issue['category'] ?? 'General',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            issue['title'] ?? 'Untitled Issue',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            issue['location'] ?? 'Location not specified',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "STATUS",
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    assignedTo == null
                        ? 'Pending Assignment'
                        : 'Assigned to $assignedTo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: assignedTo == null
                          ? Colors.redAccent
                          : forestGreen,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (assignedTo == null)
                ElevatedButton(
                  onPressed: () => _showAssignSheet(doc),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: forestGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    "Assign",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priorityBadge(String priority) {
    Color pColor = priority.toLowerCase() == 'urgent'
        ? Colors.red
        : (priority.toLowerCase() == 'high' ? Colors.orange : forestGreen);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: pColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  void _showAssignSheet(QueryDocumentSnapshot doc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Assign to Warden',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Confirming will update the status and notify the warden.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: forestGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('issues')
                      .doc(doc.id)
                      .update({
                    'assignedTo': 'Warden',
                    'status': 'In Progress',
                    'assignedAt': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  'Confirm Assignment',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
