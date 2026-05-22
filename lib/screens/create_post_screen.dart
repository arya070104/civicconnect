import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/top_snackbar.dart';
import '../services/firestore_services.dart';
import '../widgets/glowing_background_logo.dart';
import '../widgets/pulse_loader.dart';

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
  bool hoverBack = false;
  String focusedField = "";

  final locations = [
    "Sector 1",
    "Sector 2",
    "Sector 3",
    "Sector 4",
    "Sector 5",
  ];

  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 78,
        maxWidth: 1600,
      );
      if (picked == null) return;

      webImage = await picked.readAsBytes();

      if (kIsWeb) {
        selectedImage = null;
      } else {
        selectedImage = File(picked.path);
      }

      if (!mounted) return;
      setState(() {});
      TopSnackBar.show(
        context,
        "Image attached and ready to upload",
        color: Colors.green,
        icon: Icons.image_outlined,
      );
    } catch (e) {
      if (!mounted) return;
      TopSnackBar.show(
        context,
        "Image selection failed",
        color: Colors.redAccent,
      );
    }
  }

  void submitPost() async {
    final text = postController.text.trim();

    if (text.isEmpty || selectedLocation == null) {
      TopSnackBar.show(
        context,
        "Please fill all required fields",
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

    if (!mounted) return;

    if (success) {
      TopSnackBar.show(context, "Post uploaded", color: Colors.green);
      Navigator.pushReplacementNamed(context, "/home");
      return;
    }

    TopSnackBar.show(
      context,
      FirestoreService.lastError ?? "Failed to create post",
      color: Colors.redAccent,
    );
    setState(() => isPosting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? Colors.black : const Color(0xFFF0EDE5),

      body: SafeArea(
        child: Stack(
          children: [
            /// Background Logo
            Positioned.fill(
              child: Opacity(
                opacity: 1,
                child: Center(
                  child: GlowingBackgroundLogo(isDark: isDark),
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
                    color:
                        isDark
                            ? Colors.white.withValues(alpha: 0.045)
                            : Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.34),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
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
                        child: MouseRegion(
                          onEnter: (_) => setState(() => hoverBack = true),
                          onExit: (_) => setState(() => hoverBack = false),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 160),
                            curve: Curves.easeOutCubic,
                            scale: hoverBack ? 1.08 : 1,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pushReplacementNamed(
                                  context,
                                  "/home",
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      isDark
                                          ? Colors.white.withValues(
                                            alpha: hoverBack ? 0.16 : 0.09,
                                          )
                                          : Colors.white.withValues(
                                            alpha: hoverBack ? 0.42 : 0.25,
                                          ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: hoverBack ? 0.22 : 0.14,
                                      ),
                                      blurRadius: hoverBack ? 18 : 12,
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
                            Text(
                              "Create Post",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark
                                        ? Colors.white
                                        : const Color(0xFF4B1E18),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// Description
                      _label(
                        "Post Description (hashtags allowed #road #issue)",
                        isDark,
                      ),
                      _glassInputField(isDark),
                      const SizedBox(height: 20),

                      /// Location
                      _label("Location (required)", isDark),
                      _dropdown(
                        locations,
                        selectedLocation,
                        (value) => setState(() => selectedLocation = value),
                        isDark,
                      ),
                      const SizedBox(height: 20),

                      /// Add Image
                      _label("Add Image", isDark),
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
                                          color: Colors.brown.withValues(
                                            alpha: 0.34,
                                          ),
                                          blurRadius: 28,
                                          offset: const Offset(0, 10),
                                        ),
                                      ]
                                    : [],
                          ),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 160),
                            curve: Curves.easeOutCubic,
                            scale: hoverPost ? 1.015 : 1,
                            child: GestureDetector(
                              onTap: isPosting ? null : submitPost,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.brown.withValues(
                                        alpha: hoverPost ? 0.88 : 0.76,
                                      ),
                                      const Color(0xFF6F4A3E).withValues(
                                        alpha: hoverPost ? 0.86 : 0.72,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.34),
                                  ),
                                ),
                                child: Center(
                                  child:
                                      isPosting
                                          ? const PulseLoader(
                                            size: 30,
                                            color: Colors.white,
                                            showLogo: false,
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

  Widget _label(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF4B1E18),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _glassInputField(bool isDark) {
    final focused = focusedField == "post";

    return Focus(
      onFocusChange: (value) {
        setState(() => focusedField = value ? "post" : "");
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.white.withValues(alpha: focused ? 0.11 : 0.055)
                  : Colors.white.withValues(alpha: focused ? 0.56 : 0.34),
          borderRadius: BorderRadius.circular(focused ? 18 : 14),
          border: Border.all(
            color:
                focused
                    ? Colors.brown.withValues(alpha: 0.48)
                    : Colors.white.withValues(alpha: 0.50),
          ),
          boxShadow:
              focused
                  ? [
                    BoxShadow(
                      color: Colors.brown.withValues(
                        alpha: isDark ? 0.18 : 0.14,
                      ),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ]
                  : [],
        ),
        child: TextField(
          controller: postController,
          maxLines: 5,
          cursorColor: Colors.brown,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16),
            hintText: "Write something... (#hashtags allowed)",
            hintStyle: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    List<String> items,
    String? selected,
    Function(String?) onChanged,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.055)
                : Colors.white.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.50)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
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
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.brown.withValues(alpha: 0.78),
                const Color(0xFF6F4A3E).withValues(alpha: 0.72),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withValues(alpha: 0.30),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
