import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/top_snackbar.dart';

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

                    MouseRegion(
                      onEnter: (_) => setState(() => hoverSignupButton = true),
                      onExit: (_) => setState(() => hoverSignupButton = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          boxShadow:
                              hoverSignupButton
                                  ? [
                                    BoxShadow(
                                      color: Colors.brown.withOpacity(0.5),
                                      blurRadius: 25,
                                    ),
                                  ]
                                  : [],
                        ),
                        child: GestureDetector(
                          onTap: _signupUser,
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
                                          color: Colors.brown.withOpacity(0.7),
                                          blurRadius: 12,
                                        ),
                                      ]
                                      : [],
                            ),
                            child: const Text("Already have an account? Login"),
                          ),
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

  Future<void> _signupUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      TopSnackBar.show(
        context,
        "Account Created Successfully 🎉",
        color: Colors.green,
        icon: Icons.verified,
      );

      Navigator.pushReplacementNamed(context, "/login");
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Signup failed";

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
