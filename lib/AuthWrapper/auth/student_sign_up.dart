import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../StudentScreens/dashboard.dart';
import '../../widgets/auth_animation.dart'; // ✅ Using animations instead of logo

class StudentSignUp extends StatefulWidget {
  const StudentSignUp({super.key});

  @override
  State<StudentSignUp> createState() => _StudentSignUpState();
}

class _StudentSignUpState extends State<StudentSignUp> {
  final _formKey = GlobalKey<FormState>();
  int currentStep = 1; // 👈 Tracks Step 1 or Step 2

  // Controllers
  final nameController = TextEditingController();
  final studentIdController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final hostelController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  String? selectedHostelType;

  // Modern Blue Theme Colors
  final Color primaryBlue = const Color(0xFF0D47A1);
  final Color accentBlue = const Color(0xFF2196F3);
  final Color lightBgBlue = const Color(0xFFF1F7FF);
  final Color textGrey = const Color(0xFF64748B);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ PRESERVED LOGIC: Check for duplicate IDs
  Future<bool> isStudentIdAlreadyUsed(String studentId) async {
    final query = await _firestore
        .collection('users')
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // ✅ PRESERVED LOGIC: Register Student
  Future<void> registerStudent() async {
    setState(() => isLoading = true);

    final hostelInput = hostelController.text.trim();
    final separator = hostelInput.contains('-') ? '-' : '/';
    final parts = hostelInput.split(separator);
    final studentId = studentIdController.text.trim();

    UserCredential? credential;

    try {
      // 1. Create the Auth account first to get "request.auth != null" status
      credential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2. NOW we can check for duplicate ID because we are authenticated
      if (await isStudentIdAlreadyUsed(studentId)) {
        _showSnack("Student ID already registered");

        // Clean up: Delete the newly created auth user since their ID is a duplicate
        await credential.user?.delete();
        setState(() => isLoading = false);
        return;
      }

      // 3. Save to Firestore (Path: /users/{uid})
      await _firestore.collection('users').doc(credential.user!.uid).set({
        "uid": credential.user!.uid,
        "name": nameController.text.trim(),
        "studentId": studentId,
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "block": parts[0].trim(),
        "room": parts[1].trim(),
        "hostel": hostelInput,
        "hostelType": selectedHostelType,
        "role": "student", // Matches your logic
        "createdAt": FieldValue.serverTimestamp(),
      });

      await credential.user!.sendEmailVerification();

      if (mounted) {
        _showSnack("Account created! Verification email sent.", isError: false);

        // Using pushAndRemoveUntil to clear login stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboard()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? "Signup failed");
    } catch (e) {
      // If something fails here, we might want to delete the auth user
      await credential?.user?.delete();
      _showSnack("An error occurred: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Updated Snackbar helper to support Success colors
  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
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
                  child: GestureDetector(
                    onTap: () {
                      if (currentStep == 2) {
                        setState(() => currentStep = 1);
                      } else {
                        Navigator.pop(context);
                      }
                    },
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

                const AuthAnimation(type: 'signup', height: 240),

                Text(
                  currentStep == 1 ? 'Student Identity' : 'Hostel Details',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentStep == 1
                      ? 'Tell us who you are'
                      : 'Where are you staying?',
                  style: TextStyle(fontSize: 16, color: textGrey),
                ),

                const SizedBox(height: 30),

                // 🚦 Step Switcher
                if (currentStep == 1) _buildStep1() else _buildStep2(),

                const SizedBox(height: 32),

                // 🚀 Action Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      if (currentStep == 1) {
                        // Basic validation for Step 1
                        if (nameController.text.isNotEmpty &&
                            studentIdController.text.isNotEmpty &&
                            emailController.text.contains('@')) {
                          setState(() => currentStep = 2);
                        } else {
                          _showSnack(
                            "Please fill identity details correctly",
                          );
                        }
                      } else {
                        if (_formKey.currentState!.validate()) {
                          registerStudent();
                        }
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
                        : Text(
                      currentStep == 1 ? 'Next Step' : 'Create Account',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildStep1() {
    return Column(
      children: [
        _inputField(
          controller: nameController,
          label: 'Full Name',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 18),
        _inputField(
          controller: studentIdController,
          label: 'Student ID',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 18),
        _inputField(
          controller: emailController,
          label: 'University Email',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        _inputField(
          controller: phoneController,
          label: 'Phone Number',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        _inputField(
          controller: hostelController,
          label: 'Hostel & Room (e.g., A/304)',
          icon: Icons.apartment_rounded,
          validator: (v) =>
          (v == null ||
              !RegExp(r'^[A-Za-z0-9]+[/-]\d+$').hasMatch(v.trim()))
              ? 'Use A/304 format'
              : null,
        ),
        const SizedBox(height: 18),
        _hostelTypeDropdown(),
        const SizedBox(height: 18),
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
            onPressed: () => setState(() => obscurePassword = !obscurePassword),
          ),
          validator: (v) => v!.length < 8 ? 'Min 8 characters' : null,
        ),
        const SizedBox(height: 18),
        _inputField(
          controller: confirmPasswordController,
          label: 'Confirm Password',
          icon: Icons.lock_reset_rounded,
          obscure: obscureConfirmPassword,
          validator: (v) =>
          v != passwordController.text ? 'Passwords do not match' : null,
        ),
      ],
    );
  }

  Widget _hostelTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedHostelType,
      items: const [
        DropdownMenuItem(value: 'Girls', child: Text('Girls Hostel')),
        DropdownMenuItem(value: 'Boys', child: Text('Boys Hostel')),
      ],
      onChanged: (v) => setState(() => selectedHostelType = v),
      validator: (v) => v == null ? 'Required' : null,
      decoration: InputDecoration(
        hintText: 'Hostel Type',
        prefixIcon: Icon(Icons.hotel_class_rounded, color: accentBlue),
        filled: true,
        fillColor: lightBgBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
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
