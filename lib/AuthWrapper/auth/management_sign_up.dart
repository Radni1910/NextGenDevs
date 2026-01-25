import 'package:flutter/material.dart';
import '../../widgets/dormtrack_logo.dart';

class ManagementSignUp extends StatefulWidget {
  const ManagementSignUp({super.key});

  @override
  State<ManagementSignUp> createState() => _ManagementSignUpState();
}

class _ManagementSignUpState extends State<ManagementSignUp> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool enable2FA = false;

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
                const SizedBox(height: 20),

                // ✅ Branding
                const DormTrackLogo(iconSize: 56),

                const SizedBox(height: 18),
                const Text(
                  'Management Sign Up',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14532D),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Accounts require Super Admin approval',
                  style: TextStyle(fontSize: 14, color: Color(0xFF4D7C0F)),
                ),

                const SizedBox(height: 36),

                // 👤 Full Name
                _inputField(
                  controller: nameController,
                  label: 'Full Name',
                  icon: Icons.person_rounded,
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),

                const SizedBox(height: 18),

                // 📧 Official Email
                _inputField(
                  controller: emailController,
                  label: 'Official Email',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v!.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // 📞 Phone (optional)
                _inputField(
                  controller: phoneController,
                  label: 'Phone Number (optional)',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
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
                  validator: (v) =>
                      v!.length < 6 ? 'Minimum 6 characters' : null,
                ),

                const SizedBox(height: 18),

                // 🔐 Confirm Password
                _inputField(
                  controller: confirmPasswordController,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: obscurePassword,
                  validator: (v) => v != passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),

                const SizedBox(height: 16),

                // 🔒 Enable 2FA
                SwitchListTile(
                  value: enable2FA,
                  activeColor: const Color(0xFF22C55E),
                  title: const Text(
                    'Enable Two-Factor Authentication',
                    style: TextStyle(
                      color: Color(0xFF14532D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Recommended for admins',
                    style: TextStyle(fontSize: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      enable2FA = value;
                    });
                  },
                ),

                const SizedBox(height: 22),

                // 🚀 Register Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        /*
                          🔐 Firebase Logic (later):
                          - accountType = "management"
                          - approved = false
                          - role = selectedRole
                          - twoFactorEnabled = enable2FA
                        */
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
                          'Request Access',
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

                // ⛔ Approval Notice
                const Text(
                  'Your account will be activated after Super Admin approval.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF4D7C0F)),
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
