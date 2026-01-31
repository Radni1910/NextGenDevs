import 'package:dormtrack/AuthWrapper/adminScreen/dashboard.dart';
import 'package:flutter/material.dart';
import 'management_sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormtrack/warden/warden_dashboard.dart';
import '../../widgets/auth_animation.dart'; // ✅ Updated Import
import 'package:dormtrack/AuthWrapper/adminScreen/admin_navigation_hub.dart';

class ManagementSignIn extends StatefulWidget {
  const ManagementSignIn({super.key});

  @override
  State<ManagementSignIn> createState() => _ManagementSignInState();
}

class _ManagementSignInState extends State<ManagementSignIn> {
  final _formKey = GlobalKey<FormState>();

  final adminController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  // Modern Blue Theme Colors
  final Color primaryBlue = const Color(0xFF0D47A1);
  final Color accentBlue = const Color(0xFF2196F3);
  final Color lightBgBlue = const Color(0xFFF1F7FF);
  final Color textGrey = const Color(0xFF64748B);

  Future<void> loginManagement() async {
    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: adminController.text.trim(),
        password: passwordController.text.trim(),
      );

      User user = userCredential.user!;

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('management')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        throw 'No management account found';
      }

      final data = doc.data() as Map<String, dynamic>;
      final role = data['role'];

      if (mounted) {
        if (role == 'warden') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WardenDashboard()),
                (route) => false,
          );
        } else if (role == 'superadmin') {
          // ✅ CHANGED THIS: Now pointing to the Hub instead of just the Dashboard
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminNavigationHub()),
                (route) => false,
          );
        } else {
          await FirebaseAuth.instance.signOut();
          throw 'Invalid role assigned';
        }
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Login failed');
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 🔙 Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: lightBgBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: primaryBlue,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // ✨ Animation (Replaced Logo)
                const SizedBox(height: 10),
                const AuthAnimation(type: 'login', height: 280),
                const SizedBox(height: 10),

                Text(
                  'Management Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Secure access for hostel authorities',
                  style: TextStyle(fontSize: 15, color: textGrey),
                ),

                const SizedBox(height: 35),

                // 👤 Admin Email
                _inputField(
                  controller: adminController,
                  label: 'Enter Email',
                  icon: Icons.admin_panel_settings_outlined,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 20),

                // 🔐 Password
                _inputField(
                  controller: passwordController,
                  label: 'Enter Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: accentBlue,
                    ),
                    onPressed: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 25),

                // 🔒 Security Hint
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: lightBgBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security_rounded, color: accentBlue, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Authorized management access only.',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // 🚀 Login Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        loginManagement();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 🔁 Sign Up Link
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManagementSignUp(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Not registered? ",
                      style: TextStyle(color: textGrey, fontSize: 15),
                      children: [
                        TextSpan(
                          text: "Sign up now",
                          style: TextStyle(
                            color: accentBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: accentBlue, size: 22),
        suffixIcon: suffix,
        filled: true,
        fillColor: lightBgBlue,
        hintStyle: TextStyle(color: textGrey.withValues(alpha: 0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentBlue, width: 1.5),
        ),
      ),
    );
  }
}
