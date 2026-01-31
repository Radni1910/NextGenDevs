import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class AdminLeaveApproval extends StatefulWidget {
  const AdminLeaveApproval({super.key});

  @override
  State<AdminLeaveApproval> createState() => _AdminLeaveApprovalState();
}

class _AdminLeaveApprovalState extends State<AdminLeaveApproval>
    with TickerProviderStateMixin {
  // 🎨 Theme Colors
  static const Color primaryDark = Color(0xFF0D2310);
  static const Color forestGreen = Color(0xFF1B5E20);

  Future<void> _updateStatus(String docId, String status) async {
    await FirebaseFirestore.instance
        .collection('leave_requests')
        .doc(docId)
        .update({'status': status, 'reviewedAt': FieldValue.serverTimestamp()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leave_requests')
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          final int pendingCount = snapshot.data?.docs.length ?? 0;

          return Column(
            children: [
              _buildHeader(context, pendingCount), // ✨ New Header added here
              Expanded(child: _buildBody(snapshot)),
            ],
          );
        },
      ),
    );
  }

  // ================= PREMIUM HEADER =================
  Widget _buildHeader(BuildContext context, int count) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Leave Approvals",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Review student requests",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          // 🔔 Small badge showing the number of requests
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$count Pending",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ================= BODY LOGIC =================
  Widget _buildBody(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator(color: forestGreen));
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return _buildLottieEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        var request = snapshot.data!.docs[index];
        return _buildLeaveCard(
          context,
          request.id,
          request.data() as Map<String, dynamic>,
        );
      },
    );
  }

  // ================= LOTTIE EMPTY STATE =================
  Widget _buildLottieEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'animations/approve.json',
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
          const Text(
            "All Clear!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: forestGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "No pending leave requests to review.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ================= LEAVE CARD =================
  Widget _buildLeaveCard(
      BuildContext context,
      String docId,
      Map<String, dynamic> data,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: forestGreen.withOpacity(0.1),
        ), // Subtle green border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data['studentName'] ?? "Unknown Student",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: primaryDark,
                ),
              ),
              const Chip(
                label: Text(
                  "PENDING",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Color(0xFFFFF3E0),
              ),
            ],
          ),
          const Divider(height: 24),
          _infoRow(
            Icons.calendar_today_rounded,
            "Duration",
            "${data['fromDate']} to ${data['toDate']}",
          ),
          const SizedBox(height: 10),
          _infoRow(
            Icons.notes_rounded,
            "Reason",
            data['reason'] ?? "No reason provided",
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _updateStatus(docId, "rejected"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "REJECT",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateStatus(docId, "approved"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: forestGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    "APPROVE",
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
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: primaryDark,
            ),
          ),
        ),
      ],
    );
  }
}
