import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/theme_controller.dart';
import '../utils/top_snackbar.dart';
import '../widgets/glowing_background_logo.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool hoverSend = false;
  bool hoverBack = false;

  @override
  void dispose() {
    emailController.dispose();
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? const Color(0xFF101010).withValues(alpha: 0.74)
                              : Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: isDark ? 0.12 : 0.36,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: _themeButton(isDark),
                        ),
                        const SizedBox(height: 10),
                        _logoBadge(isDark),
                        const SizedBox(height: 10),

                        Text(
                          "Forgot Password",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF4B1E18),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Enter your email to receive a password reset link.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 30),

                        _label("Email", isDark),

                        _glassInput(
                          controller: emailController,
                          hint: "Enter your email",
                          icon: Icons.email_outlined,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 30),

                        MouseRegion(
                          onEnter: (_) => setState(() => hoverSend = true),
                          onExit: (_) => setState(() => hoverSend = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              boxShadow:
                                  hoverSend
                                      ? [
                                        BoxShadow(
                                          color: Colors.brown.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 25,
                                        ),
                                      ]
                                      : [],
                            ),
                            child: GestureDetector(
                              onTap: _resetPassword,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.brown,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Send Reset Email",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        MouseRegion(
                          onEnter: (_) => setState(() => hoverBack = true),
                          onExit: (_) => setState(() => hoverBack = false),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    hoverBack
                                        ? isDark
                                            ? Colors.white
                                            : Colors.brown.shade900
                                        : isDark
                                        ? Colors.white70
                                        : Colors.brown.shade700,
                                shadows:
                                    hoverBack
                                        ? [
                                          Shadow(
                                            color: Colors.brown.withValues(
                                              alpha: 0.7,
                                            ),
                                            blurRadius: 12,
                                          ),
                                        ]
                                        : [],
                              ),
                              child: const Text("Back to Login"),
                            ),
                          ),
                        ),
                      ],
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

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      TopSnackBar.show(
        context,
        "Please enter your email",
        color: Colors.redAccent,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;

      TopSnackBar.show(
        context,
        "Password reset link sent",
        color: Colors.green,
        icon: Icons.mark_email_read,
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = "Error occurred";

      if (e.code == "user-not-found") {
        msg = "No account found for this email";
      } else if (e.code == "invalid-email") {
        msg = "Invalid email format";
      }

      TopSnackBar.show(
        context,
        msg,
        color: Colors.redAccent,
        icon: Icons.error,
      );
    }
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
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xFFFFFBF2).withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          width: 1.25,
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.22)
                  : const Color(0xFF5A332B).withValues(alpha: 0.46),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.brown.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
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
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _themeButton(bool isDark) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, child) {
        return GestureDetector(
          onTap: () {
            appThemeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 92,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFFFFBF2).withValues(alpha: 0.78),
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
                  isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFFD7B6A4) : Colors.brown,
                ),
                const SizedBox(width: 6),
                Text(
                  isDark ? "Dark" : "Light",
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
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xFFFFFBF2).withValues(alpha: 0.92),
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
}
