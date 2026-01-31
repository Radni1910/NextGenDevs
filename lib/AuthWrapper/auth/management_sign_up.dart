import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/auth_animation.dart';

class ManagementSignUp extends StatefulWidget {
  const ManagementSignUp({super.key});

  @override
  State<ManagementSignUp> createState() => _ManagementSignUpState();
}

class _ManagementSignUpState extends State<ManagementSignUp> {
  final _formKey = GlobalKey<FormState>();
  int currentStep = 1; // 👈 Track current page

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool enable2FA = false;
  bool isLoading = false;

  // Modern Blue Theme Colors
  final Color primaryBlue = const Color(0xFF0D47A1);
  final Color accentBlue = const Color(0xFF2196F3);
  final Color lightBgBlue = const Color(0xFFF1F7FF);
  final Color textGrey = const Color(0xFF64748B);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, String> roles = {
    'warden': 'Hostel Warden',
    'superadmin': 'Super Admin',
  };

  String selectedRole = 'warden';

  Future<void> registerManagement() async {
    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User user = userCredential.user!;

      await _firestore.collection('management').doc(user.uid).set({
        'uid': user.uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'role': selectedRole,
        'approved': false,
        'twoFactorEnabled': enable2FA,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account requested! Awaiting Admin approval.'),
            backgroundColor: Color(0xFF0D47A1),
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Registration failed');
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
                // 🔙 Smart Back Button
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

                const AuthAnimation(type: 'signup', height: 260),

                // 🏷️ Dynamic Title based on step
                Text(
                  currentStep == 1 ? 'Staff Registration' : 'Security Setup',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 6),
                _stepIndicator(),

                const SizedBox(height: 30),

                // 📄 Step Content
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: currentStep == 1 ? _buildStepOne() : _buildStepTwo(),
                ),

                const SizedBox(height: 30),

                // 🚀 Action Button
                _actionButton(),

                if (currentStep == 2) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Your account will be pending until verified by the system administrator.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: textGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepOne() {
    return Column(
      key: const ValueKey(1),
      children: [
        _inputField(
          controller: nameController,
          label: 'Full Name',
          icon: Icons.person_outline_rounded,
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _inputField(
          controller: emailController,
          label: 'Official Email',
          icon: Icons.business_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
        ),
        const SizedBox(height: 16),
        _inputField(
          controller: phoneController,
          label: 'Contact Number',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      key: const ValueKey(2),
      children: [
        _roleDropdown(),
        const SizedBox(height: 16),
        _inputField(
          controller: passwordController,
          label: 'Password',
          icon: Icons.lock_open_rounded,
          obscure: obscurePassword,
          suffix: _eyeButton(
                () => setState(() => obscurePassword = !obscurePassword),
            obscurePassword,
          ),
          validator: (v) => v!.length < 8 ? 'Min 8 characters' : null,
        ),
        const SizedBox(height: 16),
        _inputField(
          controller: confirmPasswordController,
          label: 'Confirm Password',
          icon: Icons.lock_outline_rounded,
          obscure: obscureConfirmPassword,
          suffix: _eyeButton(
                () => setState(
                  () => obscureConfirmPassword = !obscureConfirmPassword,
            ),
            obscureConfirmPassword,
          ),
          validator: (v) => v != passwordController.text ? 'Mismatch' : null,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: enable2FA,
          activeColor: accentBlue,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Enable 2FA',
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Recommended for Admin roles',
            style: TextStyle(fontSize: 12, color: textGrey),
          ),
          onChanged: (v) => setState(() => enable2FA = v),
        ),
      ],
    );
  }

  Widget _roleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: lightBgBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedRole,
          isExpanded: true,
          icon: Icon(Icons.expand_more_rounded, color: accentBlue),
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          items: roles.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) => setState(() => selectedRole = v!),
        ),
      ),
    );
  }

  Widget _stepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Step $currentStep of 2",
          style: TextStyle(color: textGrey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        _dot(currentStep >= 1),
        const SizedBox(width: 4),
        _dot(currentStep == 2),
      ],
    );
  }

  Widget _dot(bool active) => Container(
    height: 6,
    width: active ? 18 : 6,
    decoration: BoxDecoration(
      color: active ? accentBlue : lightBgBlue,
      borderRadius: BorderRadius.circular(3),
    ),
  );

  Widget _actionButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
          if (currentStep == 1) {
            // Check only step 1 fields before proceeding
            if (nameController.text.isNotEmpty &&
                emailController.text.contains('@')) {
              setState(() => currentStep = 2);
            } else {
              _showSnack("Please fill in basic details correctly");
            }
          } else {
            if (_formKey.currentState!.validate()) {
              registerManagement();
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
          currentStep == 1 ? 'Continue' : 'Create Staff Account',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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

  Widget _eyeButton(VoidCallback onTap, bool obscured) {
    return IconButton(
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: accentBlue,
      ),
      onPressed: onTap,
    );
  }
}
