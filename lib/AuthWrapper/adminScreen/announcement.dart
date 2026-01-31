import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnnouncementScreen extends StatefulWidget {
  const AdminAnnouncementScreen({super.key});

  @override
  State<AdminAnnouncementScreen> createState() =>
      _AdminAnnouncementScreenState();
}

// ✅ Added TickerProviderStateMixin for the glow animation
class _AdminAnnouncementScreenState extends State<AdminAnnouncementScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryDark = Color(0xFF0D2310);
  static const Color forestGreen = Color(0xFF1B5E20);
  static const Color emeraldMed = Color(0xFF2E7D32);
  static const Color accentTeal = Color(
    0xFF00897B,
  ); // Added for the sweep gradient
  static const Color bgLeaf = Color(0xFFF1F8E9);
  static const Color surfaceWhite = Colors.white;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _messageCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();

  late AnimationController _borderController; // ✅ For the glowy border
  String selectedAudience = "All Hostel";
  String selectedPriority = "Normal";
  String searchQuery = "";

  final Stream<QuerySnapshot> announcementStream = FirebaseFirestore.instance
      .collection('announcements')
      .orderBy('createdAt', descending: true)
      .snapshots();

  @override
  void initState() {
    super.initState();
    // ✅ Initialize the sweep animation controller
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLeaf,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: announcementStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: forestGreen),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _emptyState("No announcements yet");
                }
                final announcements = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title'].toString().toLowerCase();
                  final msg = data['message'].toString().toLowerCase();
                  return title.contains(searchQuery.toLowerCase()) ||
                      msg.contains(searchQuery.toLowerCase());
                }).toList();

                if (announcements.isEmpty) {
                  return _emptyState("No results found for '$searchQuery'");
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: announcements.length,
                  itemBuilder: (_, index) {
                    final doc = announcements[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _animatedWrapper(
                      delay: index * 50,
                      child: _announcementCard(data, doc.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryDark,
        elevation: 6,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: const Text(
          "Broadcast",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: _showAddSheet,
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
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
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "Announcements",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search by title or message...",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white70,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => searchQuery = "");
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📢 ANNOUNCEMENT CARD WITH BENTO GLOW ANIMATION
  Widget _announcementCard(Map<String, dynamic> data, String docId) {
    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(3.0), // The thickness of the glow
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: SweepGradient(
              colors: const [
                forestGreen,
                accentTeal,
                Colors.transparent,
                forestGreen,
              ],
              transform: GradientRotation(
                _borderController.value * 2 * math.pi,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceWhite,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start, // ✅ Alignment: Top Left
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              data['title'],
                              style: const TextStyle(
                                fontSize: 22, // ✅ Bigger Title
                                fontWeight: FontWeight.w900,
                                color: primaryDark,
                                fontFamily: 'Poppins',
                                height: 1.1,
                              ),
                            ),
                          ),
                          _priorityChip(data['priority']),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data['message'],
                        style: TextStyle(
                          fontSize: 17, // ✅ Bigger Message Body
                          height: 1.5,
                          color: primaryDark.withOpacity(0.75),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: forestGreen.withOpacity(0.05),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "To: ${data['audience']}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: emeraldMed,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: emeraldMed,
                        ),
                        onPressed: () => _showEditSheet(data, docId),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => FirebaseFirestore.instance
                            .collection('announcements')
                            .doc(docId)
                            .delete(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper UI methods (Keep as they are)
  Widget _priorityChip(String priority) {
    Color color = priority == 'Urgent'
        ? Colors.red
        : (priority == 'Important' ? Colors.orange : emeraldMed);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: forestGreen.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: primaryDark.withOpacity(0.5),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedWrapper({required Widget child, required int delay}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // --- Logic for Add/Edit Sheets remains identical to your Firestore structure ---
  void _showAddSheet() {
    _titleCtrl.clear();
    _messageCtrl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            _input("Title", controller: _titleCtrl),
            const SizedBox(height: 12),
            _input("Message", maxLines: 3, controller: _messageCtrl),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDark,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () async {
                if (_titleCtrl.text.isEmpty) return;
                await FirebaseFirestore.instance
                    .collection('announcements')
                    .add({
                  'title': _titleCtrl.text.trim(),
                  'message': _messageCtrl.text.trim(),
                  'audience': selectedAudience,
                  'priority': selectedPriority,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Post Announcement",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(Map<String, dynamic> data, String docId) {
    _titleCtrl.text = data['title'];
    _messageCtrl.text = data['message'];
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input("Title", controller: _titleCtrl),
            const SizedBox(height: 12),
            _input("Message", maxLines: 3, controller: _messageCtrl),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('announcements')
                    .doc(docId)
                    .update({
                  'title': _titleCtrl.text.trim(),
                  'message': _messageCtrl.text.trim(),
                });
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
      String hint, {
        int maxLines = 1,
        TextEditingController? controller,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: bgLeaf,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
