import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/top_snackbar.dart';
import '../services/firestore_services.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final postController = TextEditingController();

  File? selectedImage;
  Uint8List? webImage;
  String? selectedLocation;

  bool isPosting = false;
  bool hoverPost = false;

  final locations = [
    "Sector 1",
    "Sector 2",
    "Sector 3",
    "Sector 4",
    "Sector 5",
  ];

  /// 📌 Pick image (supports Web + Mobile)
  Future pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(source: source);
      if (picked == null) return;

      if (kIsWeb) {
        webImage = await picked.readAsBytes();
      } else {
        selectedImage = File(picked.path);
      }

      setState(() {});
    } catch (e) {
      TopSnackBar.show(
        context,
        "Image selection failed ❌",
        color: Colors.redAccent,
      );
    }
  }

  /// 📌 Submit post → Firebase
  void submitPost() async {
    final text = postController.text.trim();

    if (text.isEmpty || selectedLocation == null) {
      TopSnackBar.show(
        context,
        "Please fill all required fields ⚠️",
        color: Colors.redAccent,
      );
      return;
    }

    setState(() => isPosting = true);

    final success = await FirestoreService().createPost(
      text: text,
      location: selectedLocation!,
      imageFile: selectedImage,
      webImage: webImage,
    );

    if (success) {
      TopSnackBar.show(context, "Post Uploaded ✔️", color: Colors.green);
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      TopSnackBar.show(
        context,
        "Failed to create post ❌",
        color: Colors.redAccent,
      );
    }

    setState(() => isPosting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDE5),

      body: SafeArea(
        child: Stack(
          children: [
            /// Background Logo
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

            /// MAIN CONTENT
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 30,
                  ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ⭐ BACK BUTTON (INSIDE THE CARD)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pushReplacementNamed(context, "/home");
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.brown,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Title
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/Icon-512.png",
                              height: 70,
                              width: 70,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Create Post",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4B1E18),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// Description
                      _label(
                        "Post Description (hashtags allowed #road #issue)",
                      ),
                      _glassInputField(),
                      const SizedBox(height: 20),

                      /// Location
                      _label("Location (required)"),
                      _dropdown(
                        locations,
                        selectedLocation,
                        (value) => setState(() => selectedLocation = value),
                      ),
                      const SizedBox(height: 20),

                      /// Add Image
                      _label("Add Image"),
                      Row(
                        children: [
                          _iconButton(
                            Icons.camera_alt,
                            () => pickImage(ImageSource.camera),
                          ),
                          const SizedBox(width: 15),
                          _iconButton(
                            Icons.photo,
                            () => pickImage(ImageSource.gallery),
                          ),
                        ],
                      ),

                      if (selectedImage != null || webImage != null) ...[
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child:
                              kIsWeb
                                  ? Image.memory(
                                    webImage!,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.file(
                                    selectedImage!,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      /// Post button
                      MouseRegion(
                        onEnter: (_) => setState(() => hoverPost = true),
                        onExit: (_) => setState(() => hoverPost = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            boxShadow:
                                hoverPost
                                    ? [
                                      BoxShadow(
                                        color: Colors.brown.withOpacity(0.4),
                                        blurRadius: 25,
                                      ),
                                    ]
                                    : [],
                          ),
                          child: GestureDetector(
                            onTap: isPosting ? null : submitPost,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.brown,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child:
                                    isPosting
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : const Text(
                                          "Post",
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------
  // COMPONENT WIDGETS
  // ----------------------------------------

  Widget _label(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF4B1E18),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _glassInputField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: TextField(
        controller: postController,
        maxLines: 5,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(16),
          hintText: "Write something... (#hashtags allowed)",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _dropdown(
    List<String> items,
    String? selected,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.brown,
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}
