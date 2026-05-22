import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudinaryUploadResult {
  final String secureUrl;
  final String publicId;

  const CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
  });
}

class CloudinaryUploadException implements Exception {
  final String message;

  const CloudinaryUploadException(this.message);

  @override
  String toString() => message;
}

class CloudinaryService {
  static const String cloudName = "dxfgny5c9";
  static const String uploadPreset = "civicconnect_posts";
  static const String uploadFolder = "civicconnect/posts";

  bool get isConfigured =>
      cloudName.isNotEmpty &&
      uploadPreset.isNotEmpty &&
      !cloudName.startsWith("YOUR_") &&
      !uploadPreset.startsWith("YOUR_");

  Future<CloudinaryUploadResult> uploadPostImage({
    required String userId,
    required String postId,
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    if (!isConfigured) {
      throw const CloudinaryUploadException(
        "Add your Cloudinary cloud name and upload preset",
      );
    }

    if (imageFile == null && imageBytes == null) {
      throw const CloudinaryUploadException("No image selected");
    }

    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );
    final publicId = "${userId}_$postId";
    final request =
        http.MultipartRequest("POST", uri)
          ..fields["upload_preset"] = uploadPreset
          ..fields["folder"] = uploadFolder
          ..fields["public_id"] = publicId;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath("file", imageFile.path),
      );
    } else {
      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          imageBytes!,
          filename: "$publicId.jpg",
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final jsonBody = jsonDecode(responseBody) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      final error = jsonBody["error"];
      final message =
          error is Map<String, dynamic>
              ? error["message"] as String?
              : "Image upload failed";
      throw CloudinaryUploadException(message ?? "Image upload failed");
    }

    final secureUrl = jsonBody["secure_url"] as String?;
    final uploadedPublicId = jsonBody["public_id"] as String?;

    if (secureUrl == null || uploadedPublicId == null) {
      throw const CloudinaryUploadException(
        "Cloudinary did not return an image URL",
      );
    }

    return CloudinaryUploadResult(
      secureUrl: secureUrl,
      publicId: uploadedPublicId,
    );
  }
}
