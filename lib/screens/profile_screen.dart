import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String name = "";
  String photoUrl = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .get();

    if (doc.exists) {
      setState(() {
        name = doc.data()!["name"] ?? "User";
        photoUrl = doc.data()!["photoUrl"] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF0EDE5),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              /// PAGE TITLE
              const Text(
                "My Profile",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 25),

              /// GLASS CARD FOR USER INFO
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 25,
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    /// Profile Image
                    CircleAvatar(
                      radius: 55,
                      backgroundColor:
                          isDark ? Colors.white12 : Colors.brown.shade200,
                      backgroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child:
                          photoUrl.isEmpty
                              ? const Icon(
                                Icons.person,
                                size: 55,
                                color: Colors.brown,
                              )
                              : null,
                    ),

                    const SizedBox(height: 16),

                    /// USERNAME
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.brown.shade800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// EMAIL
                    Text(
                      user!.email!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.brown.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              /// BUTTONS
              buildButton(
                icon: Icons.edit,
                text: "Edit Profile",
                color: Colors.brown,
                onTap: () {},
              ),

              const SizedBox(height: 15),

              buildButton(
                icon: Icons.article,
                text: "My Posts",
                color: Colors.brown,
                onTap: () {
                  Navigator.pushNamed(context, "/myPosts");
                },
              ),

              const SizedBox(height: 15),

              buildButton(
                icon: Icons.logout,
                text: "Logout",
                color: Colors.redAccent,
                onTap: () async {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, "/login");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// BUTTON WIDGET
  Widget buildButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withOpacity(0.20),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}
