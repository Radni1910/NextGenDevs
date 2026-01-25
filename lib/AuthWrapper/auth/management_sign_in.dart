import 'package:flutter/material.dart';
import '../../widgets/dormtrack_logo.dart';
import 'management_sign_up.dart';

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
  bool rememberMe = false;

  String selectedRole = 'Warden';

  final List<String> roles = ['Warden', 'Maintenance Staff', 'Super Admin'];

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

                // ✅ Branding
                const DormTrackLogo(iconSize: 56),

                const SizedBox(height: 18),
                const Text(
                  'Management Login',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14532D),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Secure access for hostel authorities',
                  style: TextStyle(fontSize: 14, color: Color(0xFF4D7C0F)),
                ),

                const SizedBox(height: 36),

                // 👤 Admin Email / Username
                _inputField(
                  controller: adminController,
                  label: 'Admin Email / Username',
                  icon: Icons.admin_panel_settings_rounded,
                  validator: (v) => v!.isEmpty ? 'Admin ID is required' : null,
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

                const SizedBox(height: 18),

                // 🎭 Role Selection
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF22C55E)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedRole,
                      icon: const Icon(Icons.arrow_drop_down),
                      isExpanded: true,
                      items: roles.map((role) {
                        return DropdownMenuItem(value: role, child: Text(role));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔒 Optional 2FA hint
                Row(
                  children: const [
                    Icon(Icons.security, color: Color(0xFF16A34A), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Two-Factor Authentication may be required for this role',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4D7C0F),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ☑ Remember Me
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
                      'Remember me',
                      style: TextStyle(color: Color(0xFF14532D)),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // 🚀 Login Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // 🔐 Firebase + Role + 2FA logic comes next
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
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

                // 🔁 Go to Management Sign Up
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManagementSignUp(),
                      ),
                    );
                  },
                  child: const Text(
                    "Not registered? Sign up now",
                    style: TextStyle(
                      color: Color(0xFF15803D), // matches management theme
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

  // 🔧 Reusable input field
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
