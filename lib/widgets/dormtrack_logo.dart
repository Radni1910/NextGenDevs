import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DormTrackLogo extends StatelessWidget {
  final double iconSize;
  final double padding;
  final double borderRadius;
  final bool showText;
  final Animation<double>? borderAnimation; // Controls the border rotation

  const DormTrackLogo({
    super.key,
    this.iconSize = 64,
    this.padding = 22,
    this.borderRadius = 26,
    this.showText = false,
    this.borderAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Icon with AI-style Racing Border ---
        AnimatedBuilder(
          animation: borderAnimation ?? AlwaysStoppedAnimation(0),
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(2.5), // Border thickness
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius + 2),
                gradient: SweepGradient(
                  colors: const [
                    Color(0xFF0D47A1), // Deep Blue
                    Color(0xFF00ACC1), // Teal
                    Color(0xFF80CBC4), // Mint
                    Colors.transparent, // Gap for the "racing" effect
                    Color(0xFF0D47A1),
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  transform: GradientRotation(
                    (borderAnimation?.value ?? 0) * 2 * math.pi,
                  ),
                ),
              ),
              child: child,
            );
          },
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF00ACC1),
                  Color(0xFF80CBC4),
                ],
              ),
            ),
            child: Icon(
              Icons.domain_rounded,
              size: iconSize,
              color: Colors.white,
            ),
          ),
        ),

        if (showText) ...[
          const SizedBox(height: 24),
          // Shimmer Title
          Shimmer.fromColors(
            baseColor: const Color(0xFF0D47A1),
            highlightColor: const Color(0xFF00ACC1),
            period: const Duration(milliseconds: 1600),
            child: const Text(
              'DormTrack',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Color(0xFF0D47A1),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Shimmer Subtitle
          Shimmer.fromColors(
            baseColor: const Color(0xFF006064),
            highlightColor: const Color(0xFF80CBC4),
            period: const Duration(milliseconds: 1800),
            child: const Text(
              'Smart Hostel Issue Tracking System',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF006064),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
