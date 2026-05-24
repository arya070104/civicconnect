import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _titleSlideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curvedAnimation);
    _titleSlideAnimation = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 1150), () {
      if (!mounted) return;
      final route =
          FirebaseAuth.instance.currentUser == null ? "/login" : "/home";
      Navigator.pushReplacementNamed(context, route);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFFFF5E1),
      body: Stack(
        children: [
          if (isDark)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  final glow = _glowAnimation.value;

                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.46 + (0.12 * glow),
                        colors: [
                          const Color(0xFFD7B6A4).withValues(
                            alpha: 0.22 * glow,
                          ),
                          Colors.brown.withValues(alpha: 0.10 * glow),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.34, 1],
                      ),
                    ),
                  );
                },
              ),
            ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compactHeight = constraints.maxHeight < 520;
                final logoSize = compactHeight ? 78.0 : 104.0;
                final titleSize = compactHeight ? 24.0 : 28.0;

                return Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  final glow = _glowAnimation.value;

                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: logoSize * 2.45,
                                        height: logoSize * 1.25,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            logoSize,
                                          ),
                                          gradient: RadialGradient(
                                            colors: [
                                              const Color(0xFFD7B6A4)
                                                  .withValues(
                                                    alpha:
                                                        isDark
                                                            ? 0.22 * glow
                                                            : 0.12 * glow,
                                                  ),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: Offset(
                                          0,
                                          _titleSlideAnimation.value * 0.25,
                                        ),
                                        child: child,
                                      ),
                                    ],
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(
                                        compactHeight ? 8 : 10,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            isDark
                                                ? Colors.white.withValues(
                                                  alpha: 0.05,
                                                )
                                                : Colors.white.withValues(
                                                  alpha: 0.62,
                                                ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF00D6C9,
                                            ).withValues(alpha: 0.20),
                                            blurRadius: 26,
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        'assets/Icon-512.png',
                                        height: logoSize * 0.72,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Transform.translate(
                                      offset: Offset(
                                        -_titleSlideAnimation.value,
                                        0,
                                      ),
                                      child: Text(
                                        "CIVI\nCONNECT",
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? const Color(0xFFF2E7DE)
                                                  : const Color(0xFF111111),
                                          fontSize: compactHeight ? 20 : 24,
                                          height: 0.92,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.2,
                                          shadows: [
                                            Shadow(
                                              color: const Color(
                                                0xFFD7B6A4,
                                              ).withValues(
                                                alpha: isDark ? 0.28 : 0.10,
                                              ),
                                              blurRadius: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: compactHeight ? 18 : 26),
                              Text(
                                "CivicConnect",
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                  shadows:
                                      isDark
                                          ? [
                                            Shadow(
                                              color: const Color(0xFFD7B6A4)
                                                  .withValues(alpha: 0.45),
                                              blurRadius: 18,
                                            ),
                                          ]
                                          : [],
                                ),
                              ),
                              const SizedBox(height: 8),
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Text(
                                  "Report. Track. Resolve.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
