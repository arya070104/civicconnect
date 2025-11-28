import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/top_snackbar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDE5),

      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.10,
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 25,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.4,
                  ),
                ),

                child: Column(
                  children: [
                    Image.asset("assets/Icon-512.png", height: 70, width: 70),
                    const SizedBox(height: 12),

                    const Text(
                      "CivicConnect",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B1E18),
                      ),
                    ),

                    const SizedBox(height: 35),

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

                    MouseRegion(
                      onEnter: (_) => setState(() => hoverLogin = true),
                      onExit: (_) => setState(() => hoverLogin = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          boxShadow:
                              hoverLogin
                                  ? [
                                    BoxShadow(
                                      color: Colors.brown.withOpacity(0.5),
                                      blurRadius: 25,
                                    ),
                                  ]
                                  : [],
                        ),
                        child: GestureDetector(
                          onTap: () => _loginUser(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.brown,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child:
                                  isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
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

                    const SizedBox(height: 20),

                    MouseRegion(
                      onEnter: (_) => setState(() => hoverSignup = true),
                      onExit: (_) => setState(() => hoverSignup = false),
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, "/signup"),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color:
                                hoverSignup
                                    ? Colors.brown.shade900
                                    : Colors.brown.shade700,
                            shadows:
                                hoverSignup
                                    ? [
                                      Shadow(
                                        color: Colors.brown,
                                        blurRadius: 12,
                                      ),
                                    ]
                                    : [],
                          ),
                          child: const Text("Don't have an account? Sign Up"),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    MouseRegion(
                      onEnter: (_) => setState(() => hoverForgot = true),
                      onExit: (_) => setState(() => hoverForgot = false),
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, "/forgot"),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: hoverForgot ? Colors.black : Colors.black87,
                            shadows:
                                hoverForgot
                                    ? [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 10,
                                      ),
                                    ]
                                    : [],
                          ),
                          child: const Text("Forgot Password?"),
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

  Future<void> _loginUser(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      TopSnackBar.show(
        context,
        "Please fill all fields ❗",
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

      TopSnackBar.show(
        context,
        "Login Successful 🎉",
        color: Colors.green,
        icon: Icons.check_circle,
      );

      Navigator.pushReplacementNamed(context, "/home");
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        TopSnackBar.show(
          context,
          "User not found 🚫",
          color: Colors.red,
          icon: Icons.error,
        );
      } else if (e.code == "wrong-password") {
        TopSnackBar.show(
          context,
          "Incorrect password ❌",
          color: Colors.redAccent,
          icon: Icons.lock,
        );
      } else {
        TopSnackBar.show(
          context,
          "Login failed ❗",
          color: Colors.red,
          icon: Icons.error_outline,
        );
      }
    }

    setState(() => isLoading = false);
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.40),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !isPasswordVisible : false,
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
    );
  }
}
