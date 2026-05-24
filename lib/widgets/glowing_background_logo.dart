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
    final Size size = MediaQuery.of(context).size;

    final double baseWidth = size.width < 700 ? size.width : size.height;

    final double width =
        baseWidth * (isDark ? widthFactor : widthFactor * 0.92);

    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: width * 1.18,
            height: width * 1.18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      isDark
                          ? const Color(0xFFD7B6A4).withValues(alpha: 0.15)
                          : const Color(0xFF8CCBC0).withValues(alpha: 0.08),
                  blurRadius: isDark ? 58 : 46,
                  spreadRadius: isDark ? 8 : 4,
                ),
              ],
            ),
          ),

          Opacity(
            opacity: isDark ? 0.16 : 0.055,
            child: Image.asset(
              "assets/Icon-512.png",
              width: width,
              fit: BoxFit.contain,
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.75)
                      : Colors.brown.withValues(alpha: 0.30),
              filterQuality: FilterQuality.low,
            ),
          ),
        ],
      ),
    );
  }
}
