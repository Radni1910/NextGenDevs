import 'package:flutter/material.dart';
import '../../widgets/dormtrack_logo.dart';
import 'student_sign_up.dart';

class StudentSignIn extends StatefulWidget {
  const StudentSignIn({super.key});

  @override
  State<StudentSignIn> createState() => _StudentSignInState();
}

class _StudentSignInState extends State<StudentSignIn> {
  final _formKey = GlobalKey<FormState>();

  final studentIdController = TextEditingController(); // ✅ added
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool rememberMe = false; // ✅ added

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔙 Back Arrow
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF14532D),
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.pop(
                        context,
                      ); // goes back to RoleSelectionMobile
                    },
                  ),
                ),
                const SizedBox(height: 10),

                const SizedBox(height: 20),

                // ✅ App Logo
                const DormTrackLogo(iconSize: 56),

                const SizedBox(height: 18),
                const Text(
                  'Student Login',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14532D),
                  ),
                ),

                const SizedBox(height: 6),
                const Text(
                  'Login to manage your hostel issues',
                  style: TextStyle(fontSize: 14, color: Color(0xFF4D7C0F)),
                ),

                const SizedBox(height: 36),

                // 🆔 Student ID / Roll Number
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
                  validator: (v) => v!.isEmpty ? 'Password is required' : null,
                ),

                const SizedBox(height: 10),

                // ✅ Remember Me
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      activeColor: const Color(0xFF22C55E),
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),
                    const Text(
                      'Remember Me',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF14532D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🚀 Login Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              // 🔗 Firebase login comes next
                              // studentIdController.text
                              // emailController.text
                              // passwordController.text
                              // rememberMe
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
                                'Login',
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

                const SizedBox(height: 20),

                // 🔁 Go to Sign Up
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentSignUp(),
                      ),
                    );
                  },
                  child: const Text(
                    "Not Registered? Sign Up Now",
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

  // 🔧 Reusable input field (unchanged)
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
