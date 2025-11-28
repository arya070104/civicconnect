import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =========================
  // SIGN UP WITH EMAIL
  // =========================
  Future<User?> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      // Create the user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;

      if (user != null) {
        // Save user profile to Firestore
        await _db.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": name,
          "email": email,
          "phone": "", // added later if user enters
          "created_at": DateTime.now(),
        });
      }

      return user;
    } catch (e) {
      throw Exception("Signup error: $e");
    }
  }

  // =========================
  // SAVE PHONE NUMBER EXTRA
  // =========================
  Future<void> saveExtraPhoneNumber(String uid, String phone) async {
    if (phone.isEmpty) return;

    await _db.collection("users").doc(uid).update({"phone": phone});
  }

  // =========================
  // LOGIN WITH EMAIL
  // =========================
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      throw Exception("Login error: $e");
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await _auth.signOut();
  }
}
