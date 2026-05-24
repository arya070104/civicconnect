import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/theme_controller.dart';
import '../utils/top_snackbar.dart';
import '../widgets/glowing_background_logo.dart';
import '../widgets/pulse_loader.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool hoverLogin = false;
  bool hoverSignupButton = false;
  bool isLoading = false;
  String focusedField = "";

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
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
                                ).withValues(alpha: 0.74)
                                : Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: isDark ? 0.12 : 0.36,
                          ),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 25,
                            spreadRadius: 2,
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
                            "Create Account",
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
                          _label("Full Name", isDark),
                          _glassInput(
                            controller: nameController,
                            hint: "Enter your full name",
                            icon: Icons.person_outline,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 20),
                          _label("Username", isDark),
                          _glassInput(
                            controller: usernameController,
                            hint: "Choose a username",
                            icon: Icons.alternate_email_rounded,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 20),
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
                          _signupButton(),
                          const SizedBox(height: 20),
                          MouseRegion(
                            onEnter: (_) => setState(() => hoverLogin = true),
                            onExit: (_) => setState(() => hoverLogin = false),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.pop(context),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color:
                                          hoverLogin
                                              ? Colors.brown
                                              : Colors.transparent,
                                      width: 1.6,
                                    ),
                                  ),
                                ),
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color:
                                        hoverLogin
                                            ? isDark
                                                ? Colors.white
                                                : Colors.brown.shade900
                                            : isDark
                                            ? Colors.white70
                                            : Colors.brown.shade700,
                                    fontWeight: FontWeight.w600,
                                    shadows:
                                        hoverLogin
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
                                  child: const Text(
                                    "Already have an account? Login",
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }

  Widget _signupButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => hoverSignupButton = true),
      onExit: (_) => setState(() => hoverSignupButton = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          boxShadow:
              hoverSignupButton
                  ? [
                    BoxShadow(
                      color: Colors.brown.withValues(alpha: 0.36),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ]
                  : [],
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          scale: hoverSignupButton ? 1.015 : 1,
          child: GestureDetector(
            onTap: isLoading ? null : _signupUser,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.brown.withValues(
                      alpha: hoverSignupButton ? 0.88 : 0.76,
                    ),
                    const Color(
                      0xFF6F4A3E,
                    ).withValues(alpha: hoverSignupButton ? 0.86 : 0.72),
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
                          "Sign Up",
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

  Future<void> _signupUser() async {
    final name = nameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      TopSnackBar.show(
        context,
        "Please fill all fields",
        color: Colors.redAccent,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    if (name.split(RegExp(r'\s+')).length < 2) {
      TopSnackBar.show(
        context,
        "Please enter your full name",
        color: Colors.redAccent,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username)) {
      TopSnackBar.show(
        context,
        "Username must be 3-20 letters, numbers, or underscores",
        color: Colors.redAccent,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final existingUsername =
          await FirebaseFirestore.instance
              .collection("users")
              .where("userName", isEqualTo: username)
              .limit(1)
              .get();
      if (existingUsername.docs.isNotEmpty) {
        if (!mounted) return;
        TopSnackBar.show(
          context,
          "Username is already taken",
          color: Colors.redAccent,
          icon: Icons.error,
        );
        setState(() => isLoading = false);
        return;
      }

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user;

      if (user != null) {
        await user.updateDisplayName(username);
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": name,
          "fullName": name,
          "userName": username,
          "displayName": username,
          "email": email,
          "photoUrl": "",
          "createdAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      TopSnackBar.show(
        context,
        "Account Created Successfully",
        color: Colors.green,
        icon: Icons.verified,
      );
      Navigator.pushReplacementNamed(context, "/login");
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      var errorMessage = "Signup failed";
      if (e.code == "email-already-in-use") {
        errorMessage = "Email already in use";
      } else if (e.code == "weak-password") {
        errorMessage = "Password must be at least 6 characters";
      } else if (e.code == "invalid-email") {
        errorMessage = "Invalid email";
      }

      TopSnackBar.show(
        context,
        errorMessage,
        color: Colors.redAccent,
        icon: Icons.error,
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
      width: 82,
      height: 82,
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
            color:
                focused
                    ? (isDark
                        ? const Color(0xFFD7B6A4).withValues(alpha: 0.62)
                        : const Color(0xFF5A332B).withValues(alpha: 0.78))
                    : isDark
                    ? Colors.white.withValues(alpha: 0.22)
                    : const Color(0xFF5A332B).withValues(alpha: 0.46),
            width: focused ? 1.7 : 1.25,
          ),
          boxShadow:
              focused || !isDark
                  ? [
                    BoxShadow(
                      color: Colors.brown.withValues(
                        alpha: focused ? 0.16 : 0.08,
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
