import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/theme_controller.dart';
import '../utils/top_snackbar.dart';
import '../widgets/glowing_background_logo.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/pulse_loader.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool hoverLogin = false;
  bool hoverSignup = false;
  bool hoverForgot = false;
  bool isLoading = false;
  String focusedField = "";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF0EDE5),
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(child: GlowingBackgroundLogo(isDark: isDark)),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 28 * (1 - value)),
                    child: Transform.scale(
                      scale: 0.96 + (0.04 * value),
                      child: child,
                    ),
                  ),
                );
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? const Color(
                                  0xFF101010,
                                ).withValues(alpha: 0.62)
                                : Colors.white.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: isDark ? 0.12 : 0.36,
                          ),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.20 : 0.08,
                            ),
                            blurRadius: 22,
                            spreadRadius: 1,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: _startThemeButton(isDark),
                          ),
                          const SizedBox(height: 10),
                          _logoBadge(isDark),
                          const SizedBox(height: 12),
                          Text(
                            "CivicConnect",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark
                                      ? Colors.white
                                      : const Color(0xFF4B1E18),
                            ),
                          ),
                          const SizedBox(height: 35),
                          _label("Email", isDark),
                          _glassInput(
                            controller: emailController,
                            hint: "Enter your email",
                            icon: Icons.email_outlined,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 20),
                          _label("Password", isDark),
                          _glassInput(
                            controller: passwordController,
                            hint: "Enter password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 30),
                          _loginButton(),
                          const SizedBox(height: 20),
                          _linkText(
                            text: "Don't have an account? Sign Up",
                            isHovered: hoverSignup,
                            onEnter: () => setState(() => hoverSignup = true),
                            onExit: () => setState(() => hoverSignup = false),
                            onTap:
                                () => Navigator.pushNamed(context, "/signup"),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          _linkText(
                            text: "Forgot Password?",
                            isHovered: hoverForgot,
                            activeColor: Colors.black,
                            inactiveColor:
                                isDark ? Colors.white70 : Colors.black87,
                            onEnter: () => setState(() => hoverForgot = true),
                            onExit: () => setState(() => hoverForgot = false),
                            onTap:
                                () => Navigator.pushNamed(context, "/forgot"),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => hoverLogin = true),
      onExit: (_) => setState(() => hoverLogin = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          boxShadow:
              hoverLogin
                  ? [
                    BoxShadow(
                      color: Colors.brown.withValues(alpha: 0.36),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ]
                  : [],
        ),
        child: PressableScale(
          onTap: isLoading ? () {} : _loginUser,
          pressedScale: isLoading ? 1 : 0.97,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            scale: hoverLogin ? 1.015 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.brown.withValues(alpha: hoverLogin ? 0.88 : 0.76),
                    const Color(
                      0xFF6F4A3E,
                    ).withValues(alpha: hoverLogin ? 0.86 : 0.72),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.34)),
              ),
              child: Center(
                child:
                    isLoading
                        ? const PulseLoader(
                          size: 28,
                          color: Colors.white,
                          showLogo: false,
                        )
                        : const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _startThemeButton(bool isDark) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, child) {
        final enabled = isDark;

        return PressableScale(
          onTap: () {
            appThemeMode.value = enabled ? ThemeMode.light : ThemeMode.dark;
            HapticFeedback.selectionClick();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 92,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFFFFBF2).withValues(alpha: 0.72),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withValues(alpha: 0.18)
                        : const Color(0xFF5A332B).withValues(alpha: 0.34),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.36 : 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  enabled ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  size: 16,
                  color: enabled ? const Color(0xFFD7B6A4) : Colors.brown,
                ),
                const SizedBox(width: 6),
                Text(
                  enabled ? "Dark" : "Light",
                  style: TextStyle(
                    color:
                        isDark
                            ? const Color(0xFFF2E7DE)
                            : const Color(0xFF4B1E18),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _logoBadge(bool isDark) {
    return Container(
      width: 78,
      height: 78,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xFFFFFBF2).withValues(alpha: 0.62),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : const Color(0xFF5A332B).withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset("assets/Icon-512.png", fit: BoxFit.contain),
    );
  }

  Widget _linkText({
    required String text,
    required bool isHovered,
    required VoidCallback onEnter,
    required VoidCallback onExit,
    required VoidCallback onTap,
    Color? activeColor,
    Color? inactiveColor,
    bool isDark = false,
  }) {
    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: PressableScale(
        onTap: onTap,
        pressedScale: 0.96,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color:
                isHovered
                    ? activeColor ?? Colors.brown.shade900
                    : inactiveColor ??
                        (isDark ? Colors.white70 : Colors.brown.shade700),
            shadows:
                isHovered
                    ? [
                      Shadow(
                        color: activeColor ?? Colors.brown,
                        blurRadius: 12,
                      ),
                    ]
                    : [],
          ),
          child: Text(text),
        ),
      ),
    );
  }

  Future<void> _loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      TopSnackBar.show(
        context,
        "Please fill all fields",
        color: Colors.redAccent,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      TopSnackBar.show(
        context,
        "Login Successful",
        color: Colors.green,
        icon: Icons.check_circle,
      );
      Navigator.pushReplacementNamed(context, "/home");
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message =
          e.code == "user-not-found"
              ? "User not found"
              : e.code == "wrong-password"
              ? "Incorrect password"
              : "Login failed";

      TopSnackBar.show(
        context,
        message,
        color: Colors.redAccent,
        icon: Icons.error_outline,
      );
    }

    if (mounted) setState(() => isLoading = false);
  }

  Widget _label(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF4B1E18),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _glassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required bool isDark,
  }) {
    final focused = focusedField == hint;

    return Focus(
      onFocusChange: (value) {
        setState(() => focusedField = value ? hint : "");
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.white.withValues(alpha: focused ? 0.12 : 0.07)
                  : const Color(0xFFFFFBF2).withValues(
                    alpha: focused ? 0.82 : 0.66,
                  ),
          borderRadius: BorderRadius.circular(focused ? 18 : 14),
          border: Border.all(
            width: focused ? 1.7 : 1.25,
            color:
                focused
                    ? (isDark
                        ? const Color(0xFFD7B6A4).withValues(alpha: 0.72)
                        : const Color(0xFF5A332B).withValues(alpha: 0.78))
                    : isDark
                    ? Colors.white.withValues(alpha: 0.22)
                    : const Color(0xFF5A332B).withValues(alpha: 0.46),
          ),
          boxShadow:
              focused || !isDark
                  ? [
                    BoxShadow(
                      color: Colors.brown.withValues(
                        alpha: focused ? (isDark ? 0.22 : 0.16) : 0.08,
                      ),
                      blurRadius: focused ? 22 : 14,
                      offset: Offset(0, focused ? 8 : 5),
                    ),
                  ]
                  : [],
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword ? !isPasswordVisible : false,
          cursorColor: Colors.brown,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF2F211D),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            hintText: hint,
            hintStyle: TextStyle(
              color:
                  isDark
                      ? Colors.white54
                      : const Color(0xFF6B5650).withValues(alpha: 0.72),
            ),
            prefixIcon: Icon(icon, color: Colors.brown),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.brown,
                      ),
                      onPressed:
                          () => setState(
                            () => isPasswordVisible = !isPasswordVisible,
                          ),
                    )
                    : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
