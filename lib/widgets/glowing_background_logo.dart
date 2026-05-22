import 'package:flutter/material.dart';

class GlowingBackgroundLogo extends StatelessWidget {
  final bool isDark;
  final double widthFactor;

  const GlowingBackgroundLogo({
    super.key,
    required this.isDark,
    this.widthFactor = 0.42,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * widthFactor;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isDark)
          Container(
            width: width * 1.16,
            height: width * 1.16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD7B6A4).withValues(alpha: 0.20),
                  blurRadius: 90,
                  spreadRadius: 14,
                ),
              ],
            ),
          ),
        Opacity(
          opacity: isDark ? 0.20 : 0.10,
          child: Image.asset(
            "assets/Icon-512.png",
            width: width,
            color: isDark ? Colors.white.withValues(alpha: 0.80) : null,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
