import 'package:flutter/material.dart';

class AdminAnnouncementScreen extends StatefulWidget {
  const AdminAnnouncementScreen({super.key});

  @override
  State<AdminAnnouncementScreen> createState() =>
      _AdminAnnouncementScreenState();
}

class _AdminAnnouncementScreenState extends State<AdminAnnouncementScreen> {
  // 🎨 Palette
  static const Color primary = Color(0xFF22577A);
  static const Color secondary = Color(0xFF38A3A5);
  static const Color success = Color(0xFF57CC99);
  static const Color highlight = Color(0xFF80ED99);
  static const Color background = Color(0xFFC7F9CC);

  final List<Map<String, dynamic>> announcements = [
    {
      'title': 'Water Supply Interruption',
      'message':
      'Due to maintenance work, water supply will be unavailable from 10 AM to 4 PM.',
      'priority': 'Urgent',
      'audience': 'Block B',
      'date': '15 Sep 2025',
    },
    {
      'title': 'Pest Control Drive',
      'message':
      'Pest control will be conducted in all hostels between 9 AM and 5 PM.',
      'priority': 'Normal',
      'audience': 'All Hostels',
      'date': '18 Sep 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        foregroundColor: primary,
        title: const Text(
          "Announcements",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        itemBuilder: (_, i) => _announcementCard(announcements[i]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _showAddSheet,
      ),
    );
  }

  /// 📢 ANNOUNCEMENT CARD
  Widget _announcementCard(Map<String, dynamic> data) {
    final bool urgent = data['priority'] == 'Urgent';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    urgent ? Icons.warning_rounded : Icons.campaign_rounded,
                    color: secondary,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                      Text(
                        data['date'],
                        style: TextStyle(
                          fontSize: 12,
                          color: primary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                _priorityChip(data['priority']),
              ],
            ),
          ),

          // Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              data['message'],
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: primary.withOpacity(0.85),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: highlight.withOpacity(0.35),
              borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.groups, size: 16, color: primary),
                const SizedBox(width: 6),
                Text(
                  data['audience'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.edit, size: 18, color: secondary),
                const SizedBox(width: 12),
                Icon(Icons.delete, size: 18, color: Colors.redAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priorityChip(String priority) {
    final bool urgent = priority == 'Urgent';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: urgent ? Colors.red.withOpacity(0.15) : success.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: urgent ? Colors.red : success,
        ),
      ),
    );
  }

  /// ➕ ADD SHEET
  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input("Title"),
            const SizedBox(height: 12),
            _input("Message", maxLines: 3),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondary,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Publish"),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: highlight.withOpacity(0.25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
