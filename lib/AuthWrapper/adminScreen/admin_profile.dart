import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormtrack/main.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _adminIdController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  static const Color primaryDark = Color(0xFF0D2310);
  static const Color forestGreen = Color(0xFF1B5E20);
  static const Color backgroundGreen = Color(0xFFF1F8E9);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _adminIdController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileChanges() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('management')
          .doc(user?.uid)
          .update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'adminId': _adminIdController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated!"),
          backgroundColor: forestGreen,
        ),
      );
      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGreen,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('management')
            .doc(user?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: forestGreen),
            );
          }

          if (snapshot.hasData && snapshot.data!.exists && !_isEditing) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            _nameController.text = data['name'] ?? "";
            _phoneController.text = data['phone'] ?? "";
            _adminIdController.text = data['adminId'] ?? "";
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. Menu-Style Header
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    _buildMenuHeader(),
                    Positioned(bottom: -45, child: _buildAvatar()),
                  ],
                ),

                const SizedBox(height: 70),

                // 2. Profile Details Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildEditableTile(
                        Icons.person_pin_rounded,
                        "FULL NAME",
                        _nameController,
                      ),
                      _buildEditableTile(
                        Icons.badge_rounded,
                        "ADMINISTRATION ID",
                        _adminIdController,
                      ),
                      _buildEditableTile(
                        Icons.phone_android_rounded,
                        "MOBILE NUMBER",
                        _phoneController,
                      ),

                      const SizedBox(height: 35),

                      // 3. Dynamic Footer Buttons
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isEditing
                            ? _buildButton(
                          "SAVE CHANGES",
                          forestGreen,
                          _saveProfileChanges,
                          isLoading: _isLoading,
                        )
                            : _buildButton(
                          "LOGOUT SESSION",
                          Colors.redAccent.shade700,
                              () => _handleLogout(context),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuHeader() {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: forestGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                "View and manage account",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          IconButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            icon: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(
                _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: backgroundGreen, width: 5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: Icon(Icons.person_outline_rounded, size: 60, color: forestGreen),
      ),
    );
  }

  Widget _buildEditableTile(
      IconData icon,
      String label,
      TextEditingController controller,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isEditing ? forestGreen.withOpacity(0.3) : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: forestGreen, size: 28),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  enabled: _isEditing,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: 0.5,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          if (_isEditing)
            const Icon(Icons.draw_rounded, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildButton(
      String label,
      Color color,
      VoidCallback onTap, {
        bool isLoading = false,
      }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 4,
          shadowColor: color.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        )
            : Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const RoleSelectionMobile()),
            (route) => false,
      );
    }
  }
}
