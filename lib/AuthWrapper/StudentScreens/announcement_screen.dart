import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  // 🎨 THEME COLORS (Matched to Dashboard Blue)
  static const Color primaryBlue = Color.fromARGB(255, 5, 35, 81);
  static const Color accentTeal = Color(0xFF00BFA5);
  static const Color scaffoldBg = Color(0xFFF8FAFF);
  static const Color borderBlue = Color(0xFFD1E3FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg, // ✅ Updated to match blue theme
      appBar: AppBar(
        title: const Text(
          "Campus Announcements",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('announcements')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No announcements yet",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final announcements = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: announcements.length,
            separatorBuilder: (_, _) =>
            const SizedBox(height: 20), // Bigger spacing
            itemBuilder: (context, index) {
              final data = announcements[index].data() as Map<String, dynamic>;

              return _announcementCard(data);
            },
          );
        },
      ),
    );
  }

  /// 🧾 Announcement Card (Enhanced to appear BIGGER)
  Widget _announcementCard(Map<String, dynamic> data) {
    return Container(
      // ✅ Increased padding to make card feel more substantial
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // More rounded corners
        border: Border.all(color: borderBlue, width: 1.5), // Thicker border
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Bigger Icon Container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w900, // Heavier weight
                        fontSize: 18, // Bigger title
                        color: primaryBlue,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTag(data['audience'], accentTeal), // Teal tag
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ✅ Larger text for message body
          Text(
            data['message'],
            style: const TextStyle(
              color: Color(0xFF455A64),
              fontSize: 15, // Slightly larger font
              height: 1.5, // Better line spacing
            ),
          ),

          const SizedBox(height: 20),

          // ✅ Metadata Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data['createdAt'] != null
                    ? (data['createdAt'] as Timestamp)
                    .toDate()
                    .toString()
                    .substring(0, 16)
                    : '',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8), // Modern square-round look
      ),
      child: Text(
        label.toUpperCase(), // Uppercase for a more "Tag" feel
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
