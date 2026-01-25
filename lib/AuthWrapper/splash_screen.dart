import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart' hide DormTrackLogo;
import '../widgets/dormtrack_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800), // ⏱ more time = more bounce
    );

    _slideAnim =
        Tween<Offset>(
          begin: const Offset(0, -1.4), // higher drop
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.elasticOut, // 🏀 STRONG bounce
          ),
        );

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionMobile()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: const DormTrackLogo(
              iconSize: 64,
              padding: 22,
              borderRadius: 26,
              showText: true,
            ),
          ),
        ),
      ),
    );
  }
}
