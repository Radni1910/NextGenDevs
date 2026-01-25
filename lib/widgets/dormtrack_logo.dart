import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // ✅ added

class DormTrackLogo extends StatelessWidget {
  final double iconSize;
  final double padding;
  final double borderRadius;
  final bool showText;

  const DormTrackLogo({
    super.key,
    this.iconSize = 64,
    this.padding = 22,
    this.borderRadius = 26,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF57CC99), Color(0xFF80ED99), Color(0xFFC7F9CC)],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.domain_rounded,
            size: iconSize,
            color: Colors.white,
          ),
        ),

        if (showText) ...[
          const SizedBox(height: 20),

          // ✨ SHIMMER TITLE
          Shimmer.fromColors(
            baseColor: const Color(0xFF14532D),
            highlightColor: const Color(0xFF22C55E),
            period: const Duration(milliseconds: 1600),
            child: const Text(
              'DormTrack',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Color(0xFF14532D),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ✨ SHIMMER SUBTITLE
          Shimmer.fromColors(
            baseColor: const Color(0xFF4D7C0F),
            highlightColor: const Color(0xFF86EFAC),
            period: const Duration(milliseconds: 1800),
            child: const Text(
              'Smart Hostel Issue Tracking System',
              style: TextStyle(fontSize: 14, color: Color(0xFF4D7C0F)),
            ),
          ),
        ],
      ],
    );
  }
}
