import 'package:flutter/material.dart';

class IssueManageScreen extends StatefulWidget {
  const IssueManageScreen({super.key});

  @override
  State<IssueManageScreen> createState() => _IssueManageScreenState();
}

class _IssueManageScreenState extends State<IssueManageScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';

  static const Color primary = Color(0xFF22577A);
  static const Color secondary = Color(0xFF38A3A5);
  static const Color success = Color(0xFF57CC99);
  static const Color highlight = Color(0xFF80ED99);
  static const Color background = Color(0xFFC7F9CC);

  final List<Map<String, dynamic>> issues = [
    {
      'title': 'Water Leakage',
      'category': 'Plumbing',
      'location': 'Block A - Room 203',
      'description': 'Continuous water leakage from wash basin.',
      'status': 'Open',
      'priority': 'High',
      'date': '12 Sep 2025',
    },
    {
      'title': 'Fan not working',
      'category': 'Electrical',
      'location': 'Block B - Room 101',
      'description': 'Ceiling fan stopped working.',
      'status': 'In Progress',
      'priority': 'Medium',
      'date': '11 Sep 2025',
    },
    {
      'title': 'Room cleaning required',
      'category': 'Cleaning',
      'location': 'Block C - Room 305',
      'description': 'Room not cleaned for 3 days.',
      'status': 'Resolved',
      'priority': 'Low',
      'date': '10 Sep 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredIssues = issues.where((issue) {
      final matchesFilter =
          selectedFilter == 'All' || issue['status'] == selectedFilter;
      final matchesSearch =
      issue['title'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          _header(),
          _summaryRow(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _searchBar(),
                const SizedBox(height: 12),
                _filterChips(),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredIssues.length,
              itemBuilder: (_, i) => _issueCard(filteredIssues[i]),
            ),
          ),
        ],
      ),
    );
  }

  /// 🌿 HEADER
  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            "Issue Management",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 SUMMARY
  Widget _summaryRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _summaryCard("Total", issues.length, primary),
          _summaryCard("Open", _count('Open'), Colors.redAccent),
          _summaryCard("Active", _count('In Progress'), secondary),
          _summaryCard("Solved", _count('Resolved'), success),
        ],
      ),
    );
  }

  int _count(String status) =>
      issues.where((i) => i['status'] == status).length;

  Widget _summaryCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
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
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// 🔍 SEARCH
  Widget _searchBar() {
    return TextField(
      onChanged: (v) => setState(() => searchQuery = v),
      decoration: InputDecoration(
        hintText: "Search issues...",
        prefixIcon: const Icon(Icons.search, color: primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// 🏷 FILTERS
  Widget _filterChips() {
    final filters = ['All', 'Open', 'In Progress', 'Resolved'];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((f) {
          final selected = selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: selected,
              selectedColor: secondary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black,
              ),
              onSelected: (_) => setState(() => selectedFilter = f),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 📋 ISSUE CARD
  Widget _issueCard(Map<String, dynamic> issue) {
    final color = _statusColor(issue['status']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showDetails(issue),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    issue['status'],
                    style: TextStyle(color: color, fontSize: 12),
                  ),
                ),
                const Spacer(),
                Text(issue['date'], style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              issue['title'],
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(issue['location'],
                style: const TextStyle(color: Colors.grey)),
            const Divider(height: 24),
            Row(
              children: [
                _tag(issue['category'], primary),
                const SizedBox(width: 8),
                _tag(issue['priority'], _priorityColor(issue['priority'])),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11)),
    );
  }

  void _showDetails(Map<String, dynamic> issue) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(issue['title'],
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(issue['description']),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => issue['status'] = 'In Progress');
                      Navigator.pop(context);
                    },
                    child: const Text("Mark Active"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: success),
                    onPressed: () {
                      setState(() => issue['status'] = 'Resolved');
                      Navigator.pop(context);
                    },
                    child: const Text("Resolve"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Open':
        return Colors.redAccent;
      case 'In Progress':
        return secondary;
      case 'Resolved':
        return success;
      default:
        return primary;
    }
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return primary;
      default:
        return Colors.grey;
    }
  }
}
