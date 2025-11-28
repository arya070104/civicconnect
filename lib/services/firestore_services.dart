import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ----------------------------------------------------
  /// ⭐ CHECK IF CURRENT USER LIKED A POST
  /// ----------------------------------------------------
  bool isLikedByMe(Map<String, dynamic> data) {
    final user = _auth.currentUser;
    if (user == null) return false;

    if (data["likedBy"] == null) return false;

    return (data["likedBy"] as List).contains(user.uid);
  }

  /// ----------------------------------------------------
  /// ⭐ Extract Hashtags (#road #issue #crime)
  /// ----------------------------------------------------
  List<String> extractHashtags(String text) {
    final regex = RegExp(r'\B#\w+');
    return regex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  /// ----------------------------------------------------
  /// ⭐ Create Post (Mobile + Web Image Support)
  /// ----------------------------------------------------
  Future<bool> createPost({
    required String text,
    required String location,
    File? imageFile,
    Uint8List? webImage, // Web image support
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) return false;

      String? imageUrl;

      // ⭐ IMAGE UPLOAD
      if (imageFile != null || webImage != null) {
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

        final ref = FirebaseStorage.instance
            .ref()
            .child("post_images")
            .child(fileName);

        if (kIsWeb && webImage != null) {
          // ⭐ WEB IMAGE UPLOAD
          await ref.putData(
            webImage,
            SettableMetadata(contentType: "image/jpeg"),
          );
        } else if (imageFile != null) {
          // ⭐ MOBILE IMAGE UPLOAD
          await ref.putFile(imageFile);
        }

        imageUrl = await ref.getDownloadURL();
      }

      // ⭐ Extract hashtags
      final hashtags = extractHashtags(text);

      // ⭐ Create Post document
      final postDoc = _db.collection("posts").doc();

      await postDoc.set({
        "postId": postDoc.id,
        "userId": user.uid,
        "userName": user.email!.split('@')[0],
        "text": text,
        "hashtags": hashtags,
        "location": location,
        "imageUrl": imageUrl,
        "likes": 0,
        "likedBy": [],
        "createdAt": FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print("Post error: $e");
      return false;
    }
  }

  /// ----------------------------------------------------
  /// ⭐ Like / Unlike Post
  /// ----------------------------------------------------
  Future<void> toggleLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final postRef = _db.collection("posts").doc(postId);
    final post = await postRef.get();

    List likedBy = post["likedBy"];

    if (likedBy.contains(user.uid)) {
      // ⭐ Unlike
      await postRef.update({
        "likedBy": FieldValue.arrayRemove([user.uid]),
        "likes": FieldValue.increment(-1),
      });
    } else {
      // ⭐ Like
      await postRef.update({
        "likedBy": FieldValue.arrayUnion([user.uid]),
        "likes": FieldValue.increment(1),
      });
    }
  }

  /// ----------------------------------------------------
  /// ⭐ Real-time Posts Stream
  /// ----------------------------------------------------
  Stream<QuerySnapshot> getPosts() {
    return _db
        .collection("posts")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}
