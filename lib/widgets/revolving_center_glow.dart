import 'dart:math' as math;

import 'package:flutter/material.dart';

class RevolvingCenterGlow extends StatefulWidget {
  final bool isDark;

  const RevolvingCenterGlow({super.key, required this.isDark});

  @override
  State<RevolvingCenterGlow> createState() => _RevolvingCenterGlowState();
}

class _RevolvingCenterGlowState extends State<RevolvingCenterGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;

          return CustomPaint(
            painter: _RevolvingGlowPainter(
              progress: progress,
              isDark: widget.isDark,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _RevolvingGlowPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  const _RevolvingGlowPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final shortestSide = math.min(size.width, size.height);
    final radius = shortestSide * 0.13;
    final angleA = progress * math.pi * 2 * 6;
    final angleB = progress * math.pi * 2 * 5;
    final angleC = progress * math.pi * 2 * 7;
    final angleD = progress * math.pi * 2 * 4;

    final redOrbit = Offset(
      center.dx + math.cos(angleA) * radius * 1.20,
      center.dy + math.sin(angleA) * radius * 0.38,
    );
    final greenOrbit = Offset(
      center.dx + math.cos(-angleB + math.pi / 3) * radius * 0.48,
      center.dy + math.sin(-angleB + math.pi / 3) * radius * 1.14,
    );
    final blueOrbit = Offset(
      center.dx + math.cos(angleC + math.pi) * radius * 0.86,
      center.dy + math.sin(angleC + math.pi) * radius * 0.86,
    );
    final violetOrbit = Offset(
      center.dx + math.cos(-angleD - math.pi / 4) * radius * 1.34,
      center.dy + math.sin(-angleD - math.pi / 4) * radius * 0.58,
    );

    _paintGlow(
      canvas,
      center,
      shortestSide * 0.16,
      const Color(0xFF00D1FF).withValues(alpha: isDark ? 0.08 : 0.05),
    );
    _paintGlow(
      canvas,
      redOrbit,
      shortestSide * (isDark ? 0.060 : 0.042),
      (isDark ? Colors.redAccent : const Color(0xFFFF8A80)).withValues(
        alpha: isDark ? 0.78 : 0.24,
      ),
    );
    _paintGlow(
      canvas,
      greenOrbit,
      shortestSide * (isDark ? 0.055 : 0.038),
      (isDark ? Colors.greenAccent : const Color(0xFF80CBC4)).withValues(
        alpha: isDark ? 0.72 : 0.22,
      ),
    );
    _paintGlow(
      canvas,
      blueOrbit,
      shortestSide * (isDark ? 0.062 : 0.044),
      (isDark ? Colors.cyanAccent : const Color(0xFF90CAF9)).withValues(
        alpha: isDark ? 0.80 : 0.24,
      ),
    );
    _paintGlow(
      canvas,
      violetOrbit,
      shortestSide * (isDark ? 0.052 : 0.036),
      (isDark ? Colors.purpleAccent : const Color(0xFFCE93D8)).withValues(
        alpha: isDark ? 0.68 : 0.18,
      ),
    );
  }

  void _paintGlow(Canvas canvas, Offset center, double radius, Color color) {
    final paint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: math.min(1.0, color.a * 1.15)),
              color.withValues(alpha: color.a * 0.70),
              color.withValues(alpha: 0),
            ],
            stops: const [0, 0.28, 1],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..blendMode = BlendMode.plus;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RevolvingGlowPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
