import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:civicconnect/screens/profile_screen.dart';
import '../utils/top_snackbar.dart';
import '../services/firestore_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      const FeedScreen(),
      const PlaceholderScreen(title: "Chat - Under Progress"),
      const PlaceholderScreen(title: "Search - Under Progress"),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF0EDE5),

      body: Stack(
        children: [
          /// Active Page
          pages[_selectedIndex],

          /// Floating Create Button (only on Home)
          if (_selectedIndex == 0)
            Positioned(
              bottom: 65,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, "/createPost");
                  },
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.brown,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.45),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, size: 32, color: Colors.white),
                  ),
                ),
              ),
            ),

          /// Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _bottomNavBar(isDark),
          ),
        ],
      ),
    );
  }

  /// ⭐ Bottom Navigation Bar (fixed icon colors)
  Widget _bottomNavBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withOpacity(0.10)
                : Colors.white.withOpacity(0.35),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.brown.withOpacity(0.6),

        /// ⭐ These two lines FIX the black profile icon issue
        selectedIconTheme: const IconThemeData(color: Colors.brown),
        unselectedIconTheme: IconThemeData(
          color: Colors.brown.withOpacity(0.6),
        ),

        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chat",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////
/// FEED SCREEN
///////////////////////////////////////////////////////////

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        /// Background Logo
        Positioned.fill(
          child: Opacity(
            opacity: 0.09,
            child: Center(
              child: Image.asset(
                "assets/Icon-512.png",
                width: MediaQuery.of(context).size.width * 0.40,
                color: isDark ? Colors.white10 : null,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        /// Firestore Posts
        Padding(
          padding: const EdgeInsets.only(bottom: 120),
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection("posts")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.brown),
                );
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No posts yet 👀",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 18,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  return PostCard(
                    postId: docs[i].id,
                    user: data["userName"] ?? "Unknown User",
                    text: data["text"] ?? "",
                    imageUrl: data["imageUrl"],
                    likes: (data["likedBy"] ?? []).length,
                    isLikedByMe: FirestoreService().isLikedByMe(data),
                    isDark: isDark,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

///////////////////////////////////////////////////////////
/// POST CARD UI
///////////////////////////////////////////////////////////

class PostCard extends StatelessWidget {
  final String postId;
  final String user;
  final String text;
  final String? imageUrl;
  final int likes;
  final bool isLikedByMe;
  final bool isDark;

  const PostCard({
    super.key,
    required this.postId,
    required this.user,
    required this.text,
    required this.imageUrl,
    required this.likes,
    required this.isLikedByMe,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Username
          Text(
            user,
            style: TextStyle(
              color: Colors.brown.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 6),

          /// Text
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          /// Image
          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                imageUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ],

          /// Icons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () async {
                  await FirestoreService().toggleLike(postId);
                },
                child: Row(
                  children: [
                    Icon(
                      isLikedByMe ? Icons.favorite : Icons.favorite_border,
                      color: isLikedByMe ? Colors.red : Colors.brown,
                      size: 28,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      likes.toString(),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () {
                  TopSnackBar.show(
                    context,
                    "Comments coming soon 💬",
                    color: Colors.blueAccent,
                  );
                },
                child: const Icon(
                  Icons.mode_comment_outlined,
                  color: Colors.brown,
                  size: 28,
                ),
              ),

              GestureDetector(
                onTap: () {
                  TopSnackBar.show(
                    context,
                    "Post shared 🔗",
                    color: Colors.green,
                  );
                },
                child: const Icon(
                  Icons.share_outlined,
                  color: Colors.brown,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////
/// PLACEHOLDER SCREEN
///////////////////////////////////////////////////////////

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.brown,
        ),
      ),
    );
  }
}
