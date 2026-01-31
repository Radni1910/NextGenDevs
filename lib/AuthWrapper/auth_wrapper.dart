import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Services/auth_service.dart';
import '../AuthWrapper/splash_screen.dart';
import '../AuthWrapper/StudentScreens/dashboard.dart';
import '../AuthWrapper/adminScreen/dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // User is logged in, determine where to route based on role
          return const RoleBasedRouter();
        } else {
          // User is not logged in, show splash screen
          return const SplashScreen();
        }
      },
    );
  }
}

class RoleBasedRouter extends StatefulWidget {
  const RoleBasedRouter({super.key});

  @override
  State<RoleBasedRouter> createState() => _RoleBasedRouterState();
}

class _RoleBasedRouterState extends State<RoleBasedRouter> {
  bool _isLoading = true;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      String? role = await AuthService.getUserRole();
      bool isApproved = await AuthService.isAccountApproved();

      // For management accounts, check if approved
      if ((role == 'management' ||
          role == 'admin' ||
          role == 'warden' ||
          role == 'maintenance' ||
          role == 'super_admin') &&
          !isApproved) {
        // Show pending approval message and redirect to login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your account is pending approval by Super Admin.'),
              backgroundColor: Colors.orange,
            ),
          );

          // Sign out user since account is not approved
          await AuthService.signOut();
          return;
        }
      }

      setState(() {
        _userRole = role;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking user role: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Determine which dashboard to show based on user role
    if (_userRole == 'management' ||
        _userRole == 'admin' ||
        _userRole == 'warden' ||
        _userRole == 'maintenance' ||
        _userRole == 'super_admin') {
      return const AdminDashboard();
    } else {
      // Default to student dashboard for undefined roles or 'student'
      return const StudentDashboard();
    }
  }
}
