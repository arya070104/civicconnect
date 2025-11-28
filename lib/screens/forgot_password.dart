import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/top_snackbar.dart';

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
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(25),
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Image.asset("assets/Icon-512.png", height: 60, width: 60),
                    const SizedBox(height: 10),

                    const Text(
                      "Forgot Password",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B1E18),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Enter your email to receive a password reset link.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    ),

                    const SizedBox(height: 30),

                    _label("Email"),

                    _glassInput(
                      controller: emailController,
                      hint: "Enter your email",
                      icon: Icons.email_outlined,
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
                                      color: Colors.brown.withOpacity(0.4),
                                      blurRadius: 25,
                                    ),
                                  ]
                                  : [],
                        ),
                        child: GestureDetector(
                          onTap: _resetPassword,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                                    ? Colors.brown.shade900
                                    : Colors.brown.shade700,
                            shadows:
                                hoverBack
                                    ? [
                                      Shadow(
                                        color: Colors.brown.withOpacity(0.7),
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

      TopSnackBar.show(
        context,
        "Password reset link sent 📩",
        color: Colors.green,
        icon: Icons.mark_email_read,
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.40),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54),
          prefixIcon: Icon(icon, color: Colors.brown),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
