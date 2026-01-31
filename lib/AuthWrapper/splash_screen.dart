import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart' hide DormTrackLogo;
import '../widgets/dormtrack_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _logoController;
  late AnimationController _borderController;

  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // 1. Waves loop
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // 2. Border "racing" loop
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // 3. Logo entrance (plays once)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _logoController.forward();
    HapticFeedback.mediumImpact();

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelectionMobile()),
        );
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _logoController.dispose();
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildWaves(isTop: true),
          _buildWaves(isTop: false),
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: DormTrackLogo(
                  showText: true,
                  borderAnimation: _borderController,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaves({required bool isTop}) {
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 240,
        child: AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) => CustomPaint(
            painter: MultiWavePainter(
              animationValue: _waveController.value,
              isTop: isTop,
            ),
          ),
        ),
      ),
    );
  }
}

class MultiWavePainter extends CustomPainter {
  final double animationValue;
  final bool isTop;

  MultiWavePainter({required this.animationValue, required this.isTop});

  @override
  void paint(Canvas canvas, Size size) {
    final List<Color> palette = [
      const Color(0xFF0D47A1), // Deep Blue
      const Color(0xFF00ACC1), // Vibrant Teal
      const Color(0xFF80CBC4), // Soft Mint
    ];

    for (int i = 0; i < palette.length; i++) {
      final paint = Paint()..color = palette[i].withValues(alpha: 0.5);
      final path = Path();
      double phase = (i * math.pi / 2.5);
      double speed = (i + 1) * 0.4;

      for (double x = 0; x <= size.width; x++) {
        double relativeX = x / size.width;
        double waveHeight =
            math.sin(
              (relativeX * 1.2 * math.pi) +
                  (animationValue * 2 * math.pi * speed) +
                  phase,
            ) *
                18;

        double yPos = isTop
            ? (size.height * 0.35) + (i * 18) + waveHeight
            : (size.height * 0.65) - (i * 18) + waveHeight;

        if (x == 0) path.moveTo(x, isTop ? 0 : size.height);
        path.lineTo(x, yPos);
      }

      if (isTop) {
        path.lineTo(size.width, 0);
        path.lineTo(0, 0);
      } else {
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
