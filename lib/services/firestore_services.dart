import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'cloudinary_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryService _cloudinary = CloudinaryService();

  static String? lastError;

  bool isLikedByMe(Map<String, dynamic> data) {
    final user = _auth.currentUser;
    if (user == null) return false;

    return (data["likedBy"] as List? ?? []).contains(user.uid);
  }

  List<String> extractHashtags(String text) {
    final regex = RegExp(r'\B#\w+');
    return regex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  Future<bool> createPost({
    required String text,
    required String location,
    required String category,
    required String urgency,
    File? imageFile,
    Uint8List? webImage,
    List<Uint8List>? imageBytesList,
  }) async {
    lastError = null;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        lastError = "You must be logged in to post";
        return false;
      }
      final userName = _displayNameFor(user);

      final postDoc = _db.collection("posts").doc();
      var imageUrl = "";
      var imagePath = "";
      final imageUrls = <String>[];
      final imagePaths = <String>[];

      final images = imageBytesList ?? [];
      if (images.isNotEmpty) {
        for (var i = 0; i < images.length; i++) {
          final upload = await _cloudinary.uploadPostImage(
            userId: user.uid,
            postId: postDoc.id,
            imageBytes: images[i],
            publicIdSuffix: "post_$i",
          );

          imageUrls.add(upload.secureUrl);
          imagePaths.add(upload.publicId);
        }
        imageUrl = imageUrls.first;
        imagePath = imagePaths.first;
      } else if (imageFile != null || webImage != null) {
        final imageBytes = webImage ?? await imageFile!.readAsBytes();
        final upload = await _cloudinary.uploadPostImage(
          userId: user.uid,
          postId: postDoc.id,
          imageFile: kIsWeb ? null : imageFile,
          imageBytes: imageBytes,
        );

        imageUrl = upload.secureUrl;
        imagePath = upload.publicId;
        imageUrls.add(imageUrl);
        imagePaths.add(imagePath);
      }

      await postDoc.set({
        "postId": postDoc.id,
        "userId": user.uid,
        "userName": userName,
        "text": text,
        "hashtags": extractHashtags(text),
        "location": location,
        "category": category,
        "urgency": urgency,
        "imageUrl": imageUrl,
        "imagePath": imagePath,
        "imageUrls": imageUrls,
        "imagePaths": imagePaths,
        "imageProvider": imageUrl.isEmpty ? "" : "cloudinary",
        "hasImage": imageUrl.isNotEmpty,
        "likes": 0,
        "likedBy": [],
        "status": "Pending",
        "editedOnce": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseException catch (e) {
      lastError = _friendlyFirebaseError(e);
      debugPrint("Post Firebase error: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      lastError = e.toString();
      debugPrint("Post error: $e");
      return false;
    }
  }

  Future<void> toggleLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final postRef = _db.collection("posts").doc(postId);
    final post = await postRef.get();
    final data = post.data();
    if (data == null) return;

    final likedBy = data["likedBy"] as List? ?? [];

    if (likedBy.contains(user.uid)) {
      await postRef.update({
        "likedBy": FieldValue.arrayRemove([user.uid]),
        "likes": FieldValue.increment(-1),
      });
    } else {
      await postRef.update({
        "likedBy": FieldValue.arrayUnion([user.uid]),
        "likes": FieldValue.increment(1),
      });
    }
  }

  Future<bool> updatePostStatus(String postId, String status) async {
    lastError = null;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        lastError = "You must be logged in to change status";
        return false;
      }

      final postRef = _db.collection("posts").doc(postId);
      final post = await postRef.get();
      final data = post.data();

      if (data == null) {
        lastError = "Post not found";
        return false;
      }

      if (data["userId"] != user.uid) {
        lastError = "Only the post owner can update this issue";
        return false;
      }

      if (data["status"] == "Resolved") {
        lastError = "Resolved posts cannot be changed again";
        return false;
      }

      await postRef.update({"status": status});
      return true;
    } on FirebaseException catch (e) {
      lastError = e.message ?? e.code;
      return false;
    }
  }

  Future<bool> resolvePostWithProof(
    String postId,
    String proof, {
    List<Uint8List>? proofImages,
  }) async {
    lastError = null;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        lastError = "You must be logged in to resolve a post";
        return false;
      }

      final postRef = _db.collection("posts").doc(postId);
      final commentRef = postRef.collection("comments").doc();
      final userName = _displayNameFor(user);
      final proofImageUrls = <String>[];
      final proofImagePaths = <String>[];

      final images = proofImages ?? [];
      for (var i = 0; i < images.length; i++) {
        final upload = await _cloudinary.uploadPostImage(
          userId: user.uid,
          postId: postId,
          imageBytes: images[i],
          publicIdSuffix: "resolution_${commentRef.id}_$i",
        );
        proofImageUrls.add(upload.secureUrl);
        proofImagePaths.add(upload.publicId);
      }

      await _db.runTransaction((transaction) async {
        final post = await transaction.get(postRef);
        final data = post.data();

        if (data == null) {
          throw FirebaseException(
            plugin: "cloud_firestore",
            code: "not-found",
            message: "Post not found",
          );
        }

        if (data["status"] == "Resolved") {
          throw FirebaseException(
            plugin: "cloud_firestore",
            code: "failed-precondition",
            message: "Resolved posts cannot be changed again",
          );
        }

        if (data["userId"] != user.uid) {
          throw FirebaseException(
            plugin: "cloud_firestore",
            code: "permission-denied",
            message: "Only the post owner can resolve this issue",
          );
        }

        transaction.set(commentRef, {
          "commentId": commentRef.id,
          "userId": user.uid,
          "userName": userName,
          "text": "Resolution proof: $proof",
          "imageUrls": proofImageUrls,
          "imagePaths": proofImagePaths,
          "likes": 0,
          "likedBy": [],
          "createdAt": FieldValue.serverTimestamp(),
        });
        transaction.update(postRef, {
          "status": "Resolved",
          "resolvedAt": FieldValue.serverTimestamp(),
          "resolvedBy": user.uid,
          "resolutionProof": proof,
          "resolutionProofImageUrls": proofImageUrls,
          "resolutionProofImagePaths": proofImagePaths,
          "commentsCount": FieldValue.increment(1),
        });
      });

      return true;
    } on FirebaseException catch (e) {
      lastError = e.message ?? e.code;
      return false;
    }
  }

  Future<bool> editPostOnce(String postId, String updatedText) async {
    lastError = null;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        lastError = "You must be logged in to edit a post";
        return false;
      }

      final postRef = _db.collection("posts").doc(postId);

      await _db.runTransaction((transaction) async {
        final post = await transaction.get(postRef);
        final data = post.data();

        if (data == null) {
          throw FirebaseException(
            plugin: "cloud_firestore",
            code: "not-found",
            message: "Post not found",
          );
        }

        if (data["userId"] != user.uid) {
          throw FirebaseException(
            plugin: "cloud_firestore",
            code: "permission-denied",
            message: "You can edit only your own posts",
          );
        }

        if (data["editedOnce"] == true) {
          throw FirebaseException(
            plugin: "cloud_firestore",
            code: "failed-precondition",
            message: "This post has already been edited once",
          );
        }

        transaction.update(postRef, {
          "text": updatedText,
          "hashtags": extractHashtags(updatedText),
          "editedOnce": true,
          "editedAt": FieldValue.serverTimestamp(),
        });
      });

      return true;
    } on FirebaseException catch (e) {
      lastError = e.message ?? e.code;
      debugPrint("Edit post Firebase error: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      lastError = e.toString();
      debugPrint("Edit post error: $e");
      return false;
    }
  }

  Future<bool> deletePost(String postId, {String? imagePath}) async {
    lastError = null;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        lastError = "You must be logged in to delete a post";
        return false;
      }

      final postRef = _db.collection("posts").doc(postId);
      final post = await postRef.get();
      final data = post.data();

      if (data == null) {
        lastError = "Post not found";
        return false;
      }

      if (data["userId"] != user.uid) {
        lastError = "You can delete only your own posts";
        return false;
      }

      final comments = await postRef.collection("comments").get();
      final batch = _db.batch();
      for (final comment in comments.docs) {
        batch.delete(comment.reference);
      }
      batch.delete(postRef);
      await batch.commit();

      return true;
    } on FirebaseException catch (e) {
      lastError = e.message ?? e.code;
      debugPrint("Delete post Firebase error: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      lastError = e.toString();
      debugPrint("Delete post error: $e");
      return false;
    }
  }

  Future<bool> addComment(
    String postId,
    String text, {
    String? replyToCommentId,
    String? replyToUserName,
    List<Uint8List>? imageBytesList,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      final userName = _displayNameFor(user);

      final postRef = _db.collection("posts").doc(postId);
      final commentRef = postRef.collection("comments").doc();
      final batch = _db.batch();
      final imageUrls = <String>[];
      final imagePaths = <String>[];

      final images = imageBytesList ?? [];
      for (var i = 0; i < images.length; i++) {
        final upload = await _cloudinary.uploadPostImage(
          userId: user.uid,
          postId: postId,
          imageBytes: images[i],
          publicIdSuffix: "comment_${commentRef.id}_$i",
        );
        imageUrls.add(upload.secureUrl);
        imagePaths.add(upload.publicId);
      }

      batch.set(commentRef, {
        "commentId": commentRef.id,
        "userId": user.uid,
        "userName": userName,
        "text": text,
        "likes": 0,
        "likedBy": [],
        "replyToCommentId": replyToCommentId ?? "",
        "replyToUserName": replyToUserName ?? "",
        "imageUrls": imageUrls,
        "imagePaths": imagePaths,
        "createdAt": FieldValue.serverTimestamp(),
      });

      batch.update(postRef, {"commentsCount": FieldValue.increment(1)});
      await batch.commit();

      return true;
    } on FirebaseException catch (e) {
      debugPrint("Comment Firebase error: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      debugPrint("Comment error: $e");
      return false;
    }
  }

  Stream<QuerySnapshot> getComments(String postId) {
    return _db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .orderBy("createdAt", descending: false)
        .snapshots();
  }

  Future<bool> deleteComment(String postId, String commentId) async {
    lastError = null;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        lastError = "You must be logged in to delete a comment";
        return false;
      }

      final postRef = _db.collection("posts").doc(postId);
      final commentRef = postRef.collection("comments").doc(commentId);
      final comment = await commentRef.get();
      final data = comment.data();

      if (data == null) {
        lastError = "Comment not found";
        return false;
      }

      if (data["userId"] != user.uid) {
        lastError = "You can delete only your own comments";
        return false;
      }

      final batch = _db.batch();
      batch.delete(commentRef);
      batch.update(postRef, {"commentsCount": FieldValue.increment(-1)});
      await batch.commit();

      return true;
    } on FirebaseException catch (e) {
      lastError = e.message ?? e.code;
      debugPrint("Delete comment Firebase error: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      lastError = e.toString();
      debugPrint("Delete comment error: $e");
      return false;
    }
  }

  Future<void> toggleCommentLike(String postId, String commentId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final commentRef = _db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(commentId);
    final comment = await commentRef.get();
    final data = comment.data();
    if (data == null) return;

    final likedBy = List<String>.from(data["likedBy"] ?? []);

    if (likedBy.contains(user.uid)) {
      await commentRef.update({
        "likedBy": FieldValue.arrayRemove([user.uid]),
        "likes": FieldValue.increment(-1),
      });
    } else {
      await commentRef.update({
        "likedBy": FieldValue.arrayUnion([user.uid]),
        "likes": FieldValue.increment(1),
      });
    }
  }

  bool isCommentLikedByMe(Map<String, dynamic> data) {
    final user = _auth.currentUser;
    if (user == null) return false;

    return (data["likedBy"] as List? ?? []).contains(user.uid);
  }

  Stream<QuerySnapshot> getPosts() {
    return _db
        .collection("posts")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  String _friendlyFirebaseError(FirebaseException e) => e.message ?? e.code;

  String _displayNameFor(User user) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    return user.email?.split('@')[0] ?? "User";
  }
}
