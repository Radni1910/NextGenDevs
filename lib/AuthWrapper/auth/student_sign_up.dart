import 'package:flutter/material.dart';
import '../../widgets/dormtrack_logo.dart';

class StudentSignUp extends StatefulWidget {
  const StudentSignUp({super.key});

  @override
  State<StudentSignUp> createState() => _StudentSignUpState();
}

class _StudentSignUpState extends State<StudentSignUp> {
  final _formKey = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),

                // ✅ Logo
                const DormTrackLogo(iconSize: 56),

                const SizedBox(height: 18),
                const Text(
                  'Student Registration',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14532D),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Create your DormTrack account',
                  style: TextStyle(fontSize: 14, color: Color(0xFF4D7C0F)),
                ),

                const SizedBox(height: 36),

                // 👤 Full Name
                _inputField(
                  controller: nameController,
                  label: 'Full Name',
                  icon: Icons.person_rounded,
                  validator: (v) => v!.isEmpty ? 'Full name is required' : null,
                ),

                const SizedBox(height: 18),

                // 🆔 Student ID
                _inputField(
                  controller: studentIdController,
                  label: 'Student ID / Roll Number',
                  icon: Icons.badge_rounded,
                  validator: (v) =>
                      v!.isEmpty ? 'Student ID is required' : null,
                ),

                const SizedBox(height: 18),

                // 📧 Email
                _inputField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Email is required' : null,
                ),

                const SizedBox(height: 18),

                // 📱 Phone (Optional)
                _inputField(
                  controller: phoneController,
                  label: 'Phone Number (optional)',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 18),

                // 🏢 Hostel Block / Room
                _inputField(
                  controller: hostelController,
                  label: 'Hostel Block / Room Number',
                  icon: Icons.home_work_rounded,
                  validator: (v) =>
                      v!.isEmpty ? 'Hostel details required' : null,
                ),

                const SizedBox(height: 18),

                // 🔐 Password
                _inputField(
                  controller: passwordController,
                  label: 'Password',
                  icon: Icons.lock_rounded,
                  obscure: obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF16A34A),
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  validator: (v) {
                    if (v!.isEmpty) return 'Password is required';
                    if (v.length < 8) {
                      return 'Minimum 8 characters required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // 🔐 Confirm Password
                _inputField(
                  controller: confirmPasswordController,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: obscureConfirmPassword,
                  suffix: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF16A34A),
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (v) {
                    if (v!.isEmpty) return 'Confirm your password';
                    if (v != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // 🚀 Register Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              // 🔥 Firebase Sign Up logic goes here
                            }
                          },
                    style:
                        ElevatedButton.styleFrom(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.transparent,
                          shadowColor: const Color(0xFF22C55E).withOpacity(0.4),
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 🔁 Go back to login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: Color(0xFF15803D),
                      fontWeight: FontWeight.w600,
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

  // 🔧 Reusable input field (same as Sign-In)
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF16A34A)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF0FDF4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.5),
        ),
      ),
    );
  }
}
