import 'package:dormtrack/AuthWrapper/StudentScreens/issue_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyIssuesScreen extends StatelessWidget {
  const MyIssuesScreen({super.key});

  // 🌿 UPDATED THEME to match Dashboard Blue
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color accentTeal = Color(0xFF00BFA5);
  static const Color scaffoldBg = Color(0xFFF8FAFF);
  static const Color borderBlue = Color(0xFFD1E3FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg, // ✅ updated to match blue theme background

      appBar: AppBar(
        title: const Text(
          "My Reported Issues",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue, // ✅ matching blue theme
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('issues')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error loading issues:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            );
          }

          final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
            snapshot.data?.docs ?? [],
          );

          docs.sort((a, b) {
            final ta = a.data()['createdAt'] as Timestamp?;
            final tb = b.data()['createdAt'] as Timestamp?;
            if (ta == null || tb == null) return 0;
            return tb.compareTo(ta); // newest first
          });

          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'You have not reported any issues yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final title = (data['title'] ?? 'Issue').toString();
              final status = (data['status'] ?? 'Open').toString();
              final hostel = (data['userHostel'] ?? '').toString();
              final category = (data['category'] ?? '').toString();
              final imageUrls =
                  (data['imageUrls'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                      <String>[];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white, // ✅ white cards
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: borderBlue,
                    width: 1.2,
                  ), // ✅ updated to blue border
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IssueDetailScreen(
                        issueId: docs[index].id, // Pass the document ID
                        title: title,
                        description: (data['description'] ?? '').toString(),
                        category: category,
                        priority: (data['priority'] ?? 'Medium').toString(),
                        imageUrls: imageUrls,
                      ),
                    ),
                  ),
                  leading: _statusIconFromStatus(status),
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF0D1B3E), // Deep navy for readability
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        _statusChipFromStatus(status),
                        const SizedBox(width: 8),
                        if (hostel.isNotEmpty)
                          Text(
                            hostel,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          )
                        else if (category.isNotEmpty)
                          Text(
                            category,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: primaryBlue, // ✅ blue trailing icon
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✅ Updated Icon style matching Blue/Teal theme
  Widget _statusIcon(int index) {
    bool resolved = index == 0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: resolved
            ? const Color(0xFFE0F2F1) // Light teal for resolved
            : primaryBlue.withValues(alpha: 0.1), // Light blue for progress
        shape: BoxShape.circle,
      ),
      child: Icon(
        resolved ? Icons.check_circle_rounded : Icons.pending_rounded,
        color: resolved ? accentTeal : primaryBlue,
        size: 22,
      ),
    );
  }

  // ✅ Updated Status chip matching priority style
  Widget _statusChip(int index) {
    bool resolved = index == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: resolved
            ? accentTeal // Teal background for resolved
            : const Color(0xFFE3F2FD), // Very light blue for "In Progress"
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        resolved ? "Resolved" : "In Progress",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: resolved ? Colors.white : primaryBlue,
        ),
      ),
    );
  }

  // Helpers based on status string (Maintained Logic)
  Widget _statusIconFromStatus(String status) {
    final normalized = status.toLowerCase();
    final resolved = normalized == 'resolved';
    return _statusIcon(resolved ? 0 : 1);
  }

  Widget _statusChipFromStatus(String status) {
    final normalized = status.toLowerCase();
    final resolved = normalized == 'resolved';
    return _statusChip(resolved ? 0 : 1);
  }
}
