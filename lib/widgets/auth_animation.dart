import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AuthAnimation extends StatelessWidget {
  final String type;
  final double height;

  const AuthAnimation({
    super.key,
    required this.type,
    this.height = 250, // ✅ Set a larger default (e.g., 250 instead of 150)
  });

  @override
  Widget build(BuildContext context) {
    String assetPath = type == 'login'
        ? 'assets/animations/login_animation.json'
        : 'assets/animations/signup_animation.json';

    return SizedBox(
      height: height, // ✅ Use the height here
      width: double.infinity,
      child: Lottie.asset(assetPath, fit: BoxFit.contain),
    );
  }
}
