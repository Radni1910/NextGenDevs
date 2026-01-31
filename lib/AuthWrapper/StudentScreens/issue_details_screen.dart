import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IssueDetailScreen extends StatefulWidget {
  final String? issueId;
  final String title;
  final String description;
  final String category;
  final String priority;
  final List<String> imageUrls;

  const IssueDetailScreen({
    super.key,
    this.issueId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.imageUrls,
  });

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _remarkController = TextEditingController();

  Map<String, dynamic>? issueData;
  bool isLoading = true;
  bool isUpvoting = false;
  bool isAddingRemark = false;

  // 🌿 Theme Colors (same as Announcement / Report Issue)
  static const Color primaryGreen = Color.fromARGB(255, 35, 130, 116);
  static const Color lightGreenBg = Color(0xFFEFFAF2);
  static const Color borderGreen = Color(0xFFC8E6C9);

  @override
  void initState() {
    super.initState();
    if (widget.issueId != null) {
      _loadIssueData();
    } else {
      // If no issueId provided, use the passed data
      issueData = {
        'title': widget.title,
        'description': widget.description,
        'category': widget.category,
        'priority': widget.priority,
        'imageUrls': widget.imageUrls,
        'status': 'Open',
        'upvotes': 0,
        'upvotedBy': <String>[],
        'createdAt': Timestamp.now(),
      };
      isLoading = false;
    }
  }

  Future<void> _loadIssueData() async {
    if (widget.issueId == null) return;

    try {
      final doc = await _firestore.collection('issues').doc(widget.issueId).get();
      if (doc.exists) {
        setState(() {
          issueData = doc.data();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading issue: $e')),
        );
      }
    }
  }

  Future<void> _toggleUpvote() async {
    if (widget.issueId == null || isUpvoting) return;

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to upvote')),
      );
      return;
    }

    setState(() => isUpvoting = true);

    try {
      final issueRef = _firestore.collection('issues').doc(widget.issueId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(issueRef);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
        final currentUpvotes = data['upvotes'] ?? 0;

        if (upvotedBy.contains(user.uid)) {
          // Remove upvote
          upvotedBy.remove(user.uid);
          transaction.update(issueRef, {
            'upvotes': currentUpvotes - 1,
            'upvotedBy': upvotedBy,
          });
        } else {
          // Add upvote
          upvotedBy.add(user.uid);
          transaction.update(issueRef, {
            'upvotes': currentUpvotes + 1,
            'upvotedBy': upvotedBy,
          });
        }
      });

      // Reload data to reflect changes
      await _loadIssueData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating upvote: $e')),
        );
      }
    } finally {
      setState(() => isUpvoting = false);
    }
  }

  Future<void> _addRemark() async {
    if (widget.issueId == null || _remarkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a remark')),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to add remarks')),
      );
      return;
    }

    setState(() => isAddingRemark = true);

    try {
      // Get user details
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final userName = userData?['name'] ?? 'Anonymous';
      final userRoom = userData?['block'] != null && userData?['room'] != null
          ? "${userData?['block']}/${userData?['room']}"
          : userData?['hostel'] ?? 'Unknown';

      // Create new remark object
      final newRemark = {
        'userId': user.uid,
        'userName': userName,
        'userRoom': userRoom,
        'remark': _remarkController.text.trim(),
        'createdAt': Timestamp.now(),
      };

      // Add remark to the remarks array in the main document
      await _firestore.collection('issues').doc(widget.issueId).update({
        'remarks': FieldValue.arrayUnion([newRemark]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _remarkController.clear();

      // Reload issue data to show the new remark
      await _loadIssueData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remark added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error adding remark: $e'); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding remark: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isAddingRemark = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: lightGreenBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Color.fromARGB(255, 5, 35, 81),
          elevation: 0,
          title: const Text(
            "Issue Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (issueData == null) {
      return Scaffold(
        backgroundColor: lightGreenBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Color.fromARGB(255, 5, 35, 81),
          elevation: 0,
          title: const Text(
            "Issue Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: Text('Issue not found'),
        ),
      );
    }

    final title = issueData!['title']?.toString() ?? widget.title;
    final description = issueData!['description']?.toString() ?? widget.description;
    final category = issueData!['category']?.toString() ?? widget.category;
    final priority = issueData!['priority']?.toString() ?? widget.priority;
    final imageUrls = List<String>.from(issueData!['imageUrls'] ?? widget.imageUrls);
    final status = issueData!['status']?.toString() ?? 'Open';
    final upvotes = issueData!['upvotes'] ?? 0;
    final upvotedBy = List<String>.from(issueData!['upvotedBy'] ?? []);
    final currentUser = _auth.currentUser;
    final hasUpvoted = currentUser != null && upvotedBy.contains(currentUser.uid);

    return Scaffold(
      backgroundColor: lightGreenBg,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Color.fromARGB(255, 5, 35, 81),
        elevation: 0,
        title: const Text(
          "Issue Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(status),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIssueCoreInfo(title, description, category, priority, imageUrls),
                  const SizedBox(height: 18),

                  const Divider(height: 40),

                  const Text(
                    "Timeline",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 10, 31, 63),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTimeline(status),

                  const Divider(height: 40),



                  if (widget.issueId != null) _buildRemarksSection(),

                  const SizedBox(height: 80), // space for bottom buttons
                ],
              ),
            ),
          ],
        ),
      ),


    );
  }

  // ✅ Status Header (green theme)
  Widget _buildStatusHeader(String status) {
    IconData statusIcon;
    String statusText;
    String assignedTo = "Maintenance Team A"; // This could come from Firebase too

    switch (status.toLowerCase()) {
      case 'resolved':
        statusIcon = Icons.check_circle;
        statusText = "RESOLVED";
        break;
      case 'in progress':
        statusIcon = Icons.pending_actions;
        statusText = "IN PROGRESS";
        break;
      case 'assigned':
        statusIcon = Icons.assignment_ind;
        statusText = "ASSIGNED";
        break;
      default:
        statusIcon = Icons.report_problem;
        statusText = "OPEN";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: primaryGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGreen, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: Color.fromARGB(255, 5, 35, 81),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Status: $statusText",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 5, 35, 81),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status.toLowerCase() == 'open'
                    ? "Waiting for assignment"
                    : "Assigned to: $assignedTo",
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Main issue card
  Widget _buildIssueCoreInfo(String title, String description, String category, String priority, List<String> imageUrls) {
    Color priorityColor;
    switch (priority.toLowerCase()) {
      case 'urgent':
        priorityColor = Colors.red;
        break;
      case 'high':
        priorityColor = Colors.orange;
        break;
      case 'medium':
        priorityColor = Colors.amber;
        break;
      default:
        priorityColor = Colors.green;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGreen, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoChip("$priority Priority", priorityColor),
              _infoChip(category, const Color.fromARGB(255, 5, 35, 81)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title.isNotEmpty ? title : 'Issue reported',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: Color.fromARGB(255, 10, 31, 63),
            ),
          ),
          const SizedBox(height: 10),
          if (description.isNotEmpty)
            Text(
              description,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14.5,
                height: 1.5,
              ),
            ),
          const SizedBox(height: 14),
          if (imageUrls.isNotEmpty)
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final url = imageUrls[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _FullImageView(imageUrl: url),
                        ),
                      );
                    },
                    child: Container(
                      width: 260,
                      decoration: BoxDecoration(
                        color: lightGreenBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderGreen, width: 1.2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.broken_image, size: 40),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: lightGreenBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderGreen, width: 1.2),
              ),
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 50,
              ),
            ),
        ],
      ),
    );
  }

  // ✅ Timeline
  Widget _buildTimeline(String status) {
    final createdAt = issueData?['createdAt'] as Timestamp?;
    final createdTime = createdAt?.toDate();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGreen, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _timelineStep(
              "Reported",
              createdTime != null
                  ? "${createdTime.day}/${createdTime.month}, ${createdTime.hour}:${createdTime.minute.toString().padLeft(2, '0')}"
                  : "Jan 24, 09:15 AM",
              true
          ),
          _timelineStep(
              "Assigned",
              status.toLowerCase() != 'open' ? "Jan 24, 11:30 AM" : "Waiting...",
              status.toLowerCase() != 'open'
          ),
          _timelineStep(
              "In Progress",
              status.toLowerCase() == 'in progress' || status.toLowerCase() == 'resolved'
                  ? "Jan 25, 10:00 AM"
                  : "Waiting...",
              status.toLowerCase() == 'in progress' || status.toLowerCase() == 'resolved'
          ),
          _timelineStep(
              "Resolved",
              status.toLowerCase() == 'resolved' ? "Jan 26, 02:30 PM" : "Waiting...",
              status.toLowerCase() == 'resolved'
          ),
        ],
      ),
    );
  }

  Widget _timelineStep(String title, String time, bool isDone) {
    return Row(
      children: [
        Column(
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? primaryGreen : Colors.grey,
              size: 20,
            ),
            Container(width: 2, height: 30, color: borderGreen),
          ],
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                color: const Color.fromARGB(255, 10, 31, 63),
              ),
            ),
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }


  // ✅ Remarks Section
  Widget _buildRemarksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Remarks",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 10, 31, 63),
          ),
        ),
        const SizedBox(height: 16),

        // Add remark input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderGreen, width: 1.2),
          ),
          child: Column(
            children: [
              TextField(
                controller: _remarkController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Add your remark or update...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderGreen),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryGreen, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isAddingRemark ? null : _addRemark,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isAddingRemark
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text("Add Remark"),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Display existing remarks
        _buildExistingRemarks(),
      ],
    );
  }

  // ✅ Build existing remarks from array
  Widget _buildExistingRemarks() {
    final remarks = issueData?['remarks'] as List<dynamic>? ?? [];

    if (remarks.isEmpty) {
      return const SizedBox.shrink();
    }


    // Sort remarks by createdAt (newest first)
    final sortedRemarks = List<Map<String, dynamic>>.from(remarks);
    sortedRemarks.sort((a, b) {
      final aTime = a['createdAt'] as Timestamp?;
      final bTime = b['createdAt'] as Timestamp?;
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });

    return Column(
      children: sortedRemarks.map((remarkData) {
        final userName = remarkData['userName'] ?? 'Anonymous';
        final userRoom = remarkData['userRoom'] ?? 'Unknown';
        final remark = remarkData['remark'] ?? '';
        final createdAt = remarkData['createdAt'] as Timestamp?;
        final timeStr = createdAt != null
            ? "${createdAt.toDate().day}/${createdAt.toDate().month} ${createdAt.toDate().hour}:${createdAt.toDate().minute.toString().padLeft(2, '0')}"
            : "Just now";

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderGreen, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: primaryGreen.withValues(alpha: 0.2),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 5, 35, 81),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$userName ($userRoom)",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 10, 31, 63),
                          ),
                        ),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                remark,
                style: const TextStyle(
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ✅ Bottom Action Footer
  Widget _buildActionFooter(bool hasUpvoted, int upvotes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: borderGreen, width: 1.2)),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.issueId != null ? () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Add Remark"),
                    content: TextField(
                      controller: _remarkController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "Enter your remark...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _addRemark();
                        },
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                );
              } : null,
              icon: const Icon(Icons.comment),
              label: const Text("Add Remark"),
              style: OutlinedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.issueId != null && !isUpvoting ? _toggleUpvote : null,
              icon: Icon(hasUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined),
              label: Text(hasUpvoted ? "Upvoted ($upvotes)" : "Upvote ($upvotes)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasUpvoted ? primaryGreen.withValues(alpha: 0.8) : primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Chips
  Widget _infoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }
}

class _FullImageView extends StatelessWidget {
  final String imageUrl;

  const _FullImageView({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator(color: Colors.white);
            },
          ),
        ),
      ),
    );
  }
}
