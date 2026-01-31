import 'package:dormtrack/AuthWrapper/StudentScreens/student_welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_sign_up.dart';
import '../StudentScreens/student_welcome_screen.dart';
import '../../widgets/auth_animation.dart'; // ✅ Added for modern UI

class StudentSignIn extends StatefulWidget {
  const StudentSignIn({super.key});

  @override
  State<StudentSignIn> createState() => _StudentSignInState();
}

class _StudentSignInState extends State<StudentSignIn> {
  final _formKey = GlobalKey<FormState>();

  final studentIdController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  // Modern Blue Theme Colors
  final Color primaryBlue = const Color(0xFF0D47A1);
  final Color accentBlue = const Color(0xFF2196F3);
  final Color lightBgBlue = const Color(0xFFF1F7FF);
  final Color textGrey = const Color(0xFF64748B);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ PRESERVED LOGIC: Login Student with Role Check
  Future<void> loginStudent() async {
    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User user = userCredential.user!;

      // 🔒 1. Check email verification
      if (!user.emailVerified) {
        await _auth.signOut();
        _showSnack("Please verify your email before logging in", isError: true);
        return;
      }

      // 📄 2. Fetch user profile
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        _showSnack("User profile not found", isError: true);
        return;
      }

      // 🧠 3. Role check (Strictly students only)
      if (userDoc['role'] == 'student') {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentWelcomeScreen()),
          );
        }
      } else {
        await _auth.signOut();
        _showSnack("Access denied: Not a student account", isError: true);
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? "Login failed", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : primaryBlue,
      ),
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
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryBlue,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const AuthAnimation(type: 'login', height: 260),

                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to manage your hostel issues',
                  style: TextStyle(fontSize: 16, color: textGrey),
                ),

                const SizedBox(height: 32),

                // 🆔 Student ID
                _inputField(
                  controller: studentIdController,
                  label: 'Student ID / Roll Number',
                  icon: Icons.badge_outlined,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 18),

                // 📧 Email
                _inputField(
                  controller: emailController,
                  label: 'University Email',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 18),

                // 🔐 Password
                _inputField(
                  controller: passwordController,
                  label: 'Password',
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

                const SizedBox(height: 40),

                // 🚀 Login Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        loginStudent();
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

                // 🔁 Go to Sign Up
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentSignUp()),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: textGrey),
                      children: [
                        TextSpan(
                          text: "Sign Up Now",
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
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
