import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:lottie/lottie.dart';

class WardenDashboard extends StatefulWidget {
  const WardenDashboard({super.key});

  @override
  State<WardenDashboard> createState() => _WardenDashboardState();
}

class _WardenDashboardState extends State<WardenDashboard>
    with SingleTickerProviderStateMixin {
  // Theme Colors
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color accentBlue = Color(0xFF3A86FF);
  static const Color skyBlue = Color(0xFF00B4D8);
  static const Color softBg = Color(0xFFF8F9FA);
  static const Color cardWhite = Colors.white;

  late AnimationController _borderController;
  String selectedSection = 'issues';
  Map<String, dynamic>? profile;
  bool isProfileLoading = true;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _loadProfile();
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('management')
          .doc(uid)
          .get();
      if (mounted) {
        setState(() {
          profile = doc.data();
          isProfileLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isProfileLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isProfileLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: accentBlue)),
      );
    }

    return Scaffold(
      backgroundColor: softBg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP LOGO (Gradient) + TEXT
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [accentBlue, skyBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Icon(
                      Icons
                          .apartment_rounded, // Using a clean icon as the logo base
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "DormTrack",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: primaryNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. WARDEN LOTTIE ANIMATION
            Center(
              child: Lottie.asset(
                'animations/warden.json',
                height: 160,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
            const SizedBox(height: 25),

            // 3. ENHANCED (BIGGER) BENTO PROFILE CARD
            _buildBentoProfileCard(),

            const SizedBox(height: 30),

            // 4. SECTION SWITCHER
            _buildSectionSwitcher(),

            const SizedBox(height: 30),

            // 5. DYNAMIC HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedSection == 'issues'
                      ? "Active Tasks"
                      : "Inventory Logs",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: primaryNavy,
                  ),
                ),
                if (selectedSection == 'lost')
                  IconButton(
                    onPressed: () => _showAddItemBottomSheet(context),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: accentBlue,
                      size: 28,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 15),

            // 6. CONTENT AREA
            selectedSection == 'issues' ? _issues() : _lostFound(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildBentoProfileCard() {
    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(3.0), // Thicker animated border
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: SweepGradient(
              colors: const [
                accentBlue,
                skyBlue,
                Colors.transparent,
                accentBlue,
              ],
              transform: GradientRotation(
                _borderController.value * 2 * math.pi,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 30,
            ), // Bigger padding
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40, // Increased size
                  backgroundColor: accentBlue.withOpacity(0.1),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: accentBlue,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back,",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        profile?['name'] ?? 'Warden',
                        style: const TextStyle(
                          fontSize: 26, // Increased font size
                          fontWeight: FontWeight.w900,
                          color: primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryNavy.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          profile?['role']?.toString().toUpperCase() ??
                              "OFFICIAL WARDEN",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryNavy,
                            letterSpacing: 1.2,
                          ),
                        ),
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

  // Rest of the methods (_buildSectionSwitcher, _bentoTile, _issues, _lostFound, etc. remain unchanged)
  // [Omitted for brevity, but functional with the same logic as your original code]

  Widget _buildSectionSwitcher() {
    return Row(
      children: [
        Expanded(
          child: _bentoTile(
            "Issues",
            Icons.warning_amber_rounded,
            selectedSection == 'issues',
                () => setState(() => selectedSection = 'issues'),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _bentoTile(
            "Lost/Found",
            Icons.qr_code_scanner_rounded,
            selectedSection == 'lost',
                () => setState(() => selectedSection = 'lost'),
          ),
        ),
      ],
    );
  }

  Widget _bentoTile(
      String title,
      IconData icon,
      bool selected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? accentBlue : cardWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? accentBlue.withOpacity(0.3)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : accentBlue, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : primaryNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _issues() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('issues')
          .where('assignedTo', isEqualTo: 'Warden')
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) return _buildEmptyState("No pending issues");
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final bool isResolved =
                data['status'].toString().toLowerCase() == 'resolved';
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isResolved ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? 'Issue',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: primaryNavy,
                          ),
                        ),
                        Text(
                          "Status: ${data['status']}",
                          style: TextStyle(
                            color: isResolved ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isResolved)
                    IconButton.filled(
                      onPressed: () =>
                          docs[index].reference.update({'status': 'Resolved'}),
                      icon: const Icon(Icons.check),
                      style: IconButton.styleFrom(backgroundColor: primaryNavy),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _lostFound() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lost_found_items')
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) return _buildEmptyState("Inventory is empty");
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.85,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'lost';
            final isFound = status == 'found' || status == 'claimed';
            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isFound
                        ? Icons.verified_rounded
                        : Icons.help_outline_rounded,
                    color: isFound ? Colors.green : Colors.red,
                  ),
                  const Spacer(),
                  Text(
                    data['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFound
                            ? Colors.green.shade50
                            : primaryNavy,
                        foregroundColor: isFound ? Colors.green : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isFound
                          ? null
                          : () async {
                        await docs[index].reference.update({
                          'status': 'found',
                          'foundAt': FieldValue.serverTimestamp(),
                        });
                        HapticFeedback.mediumImpact();
                      },
                      child: Text(
                        isFound ? "FOUND" : "MARK FOUND",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.inbox_rounded, size: 50, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(msg, style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  void _showAddItemBottomSheet(BuildContext context) {
    final titleCtrl = TextEditingController();

    final descCtrl = TextEditingController();

    File? pickedImage;

    bool isUploading = false;

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            25,

            20,

            25,

            MediaQuery.of(context).viewInsets.bottom + 30,
          ),

          decoration: const BoxDecoration(
            color: cardWhite,

            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                width: 40,

                height: 4,

                decoration: BoxDecoration(
                  color: Colors.grey.shade200,

                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 25),

              const Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  "Report Item",

                  style: TextStyle(
                    fontSize: 24,

                    fontWeight: FontWeight.w900,

                    color: primaryNavy,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();

                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,

                    imageQuality: 50,
                  );

                  if (pickedFile != null)
                    setModalState(() => pickedImage = File(pickedFile.path));
                },

                child: Container(
                  height: 100,

                  width: double.infinity,

                  margin: const EdgeInsets.only(bottom: 15),

                  decoration: BoxDecoration(
                    color: softBg,

                    borderRadius: BorderRadius.circular(18),

                    border: Border.all(color: Colors.grey.shade100),
                  ),

                  child: pickedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),

                    child: Image.file(pickedImage!, fit: BoxFit.cover),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,

                        color: accentBlue.withOpacity(0.4),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        "Add Photo",

                        style: TextStyle(
                          color: accentBlue.withOpacity(0.4),

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              TextField(
                controller: titleCtrl,

                decoration: InputDecoration(
                  hintText: "Item Name",

                  filled: true,

                  fillColor: softBg,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),

                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: descCtrl,

                decoration: InputDecoration(
                  hintText: "Description",

                  filled: true,

                  fillColor: softBg,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),

                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,

                height: 60,

                child: ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                    if (titleCtrl.text.isEmpty) return;

                    setModalState(() => isUploading = true);

                    String? downloadUrl;

                    if (pickedImage != null) {
                      String fileName = path.basename(pickedImage!.path);

                      Reference ref = FirebaseStorage.instance
                          .ref()
                          .child('lost_found/$fileName');

                      await ref.putFile(pickedImage!);

                      downloadUrl = await ref.getDownloadURL();
                    }

                    await FirebaseFirestore.instance
                        .collection('lost_found_items')
                        .add({
                      'title': titleCtrl.text.trim(),

                      'description': descCtrl.text.trim(),

                      'status': 'lost',

                      'imageUrl': downloadUrl ?? "",

                      'createdAt': FieldValue.serverTimestamp(),

                      'addedBy':
                      FirebaseAuth.instance.currentUser!.uid,
                    });

                    Navigator.pop(context);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Submit Report",

                    style: TextStyle(
                      fontWeight: FontWeight.w900,

                      color: Colors.white,

                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
