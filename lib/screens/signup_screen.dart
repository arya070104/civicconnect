import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/top_snackbar.dart';
import '../widgets/pulse_loader.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDE5),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Center(
                child: Image.asset(
                  "assets/Icon-512.png",
                  width: MediaQuery.of(context).size.width * 0.40,
                  fit: BoxFit.contain,
                ),
              ),
            ),
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
                child: Container(
                  padding: const EdgeInsets.all(25),
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.36),
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
                      Image.asset("assets/Icon-512.png", height: 70, width: 70),
                      const SizedBox(height: 10),
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B1E18),
                        ),
                      ),
                      const SizedBox(height: 35),
                      _label("Full Name"),
                      _glassInput(
                        controller: nameController,
                        hint: "Enter your full name",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 20),
                      _label("Email"),
                      _glassInput(
                        controller: emailController,
                        hint: "Enter your email",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 20),
                      _label("Password"),
                      _glassInput(
                        controller: passwordController,
                        hint: "Enter password",
                        icon: Icons.lock_outline,
                        isPassword: true,
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
                            padding: const EdgeInsets.symmetric(vertical: 6),
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
                                        ? Colors.brown.shade900
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
                    const Color(0xFF6F4A3E).withValues(
                      alpha: hoverSignupButton ? 0.86 : 0.72,
                    ),
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
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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

  Widget _label(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF4B1E18),
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
          color: Colors.white.withValues(alpha: focused ? 0.55 : 0.30),
          borderRadius: BorderRadius.circular(focused ? 18 : 14),
          border: Border.all(
            color:
                focused
                    ? Colors.brown.withValues(alpha: 0.48)
                    : Colors.white.withValues(alpha: 0.48),
          ),
          boxShadow:
              focused
                  ? [
                    BoxShadow(
                      color: Colors.brown.withValues(alpha: 0.16),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ]
                  : [],
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword ? !isPasswordVisible : false,
          cursorColor: Colors.brown,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black54),
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
          ),
        ),
      ),
    );
  }
}
