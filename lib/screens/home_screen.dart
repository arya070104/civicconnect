import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:civicconnect/screens/profile_screen.dart';
import '../services/firestore_services.dart';
import '../utils/top_snackbar.dart';
import '../widgets/glowing_background_logo.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/pulse_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      const FeedScreen(),
      const PlaceholderScreen(title: "Chat - Under Progress"),
      const SearchScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF0EDE5),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutQuart,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutQuart,
              );

              return FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.01, 0),
                      end: Offset.zero,
                    ).animate(curved),
                    child: child,
                  ),
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: pages[_selectedIndex],
            ),
          ),
          Positioned(
            bottom: 14 + bottomInset,
            left: 14,
            right: 14,
            child: _bottomNavBar(isDark),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavBar(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDark
                      ? [
                        const Color(0xFF1C1C1C).withValues(alpha: 0.88),
                        const Color(0xFF101010).withValues(alpha: 0.84),
                      ]
                      : [
                        Colors.white.withValues(alpha: 0.58),
                        const Color(0xFFFFF7EA).withValues(alpha: 0.52),
                      ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.24)
                      : Colors.white.withValues(alpha: 0.44),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.10),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color:
                    isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.46),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / 5;
              final visualIndex =
                  _selectedIndex < 2 ? _selectedIndex : _selectedIndex + 1;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutQuart,
                    left: visualIndex * itemWidth + 5,
                    top: 10,
                    width: itemWidth - 10,
                    height: 58,
                    child: _liquidNavHighlight(isDark),
                  ),
                  Row(
                    children: [
                      _dockItem(Icons.home_rounded, "Home", 0, isDark),
                      _dockItem(Icons.chat_bubble_outline, "Chat", 1, isDark),
                      _addPostDockButton(),
                      _dockItem(Icons.search_rounded, "Search", 2, isDark),
                      _dockItem(
                        Icons.person_outline_rounded,
                        "Profile",
                        3,
                        isDark,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _liquidNavHighlight(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDark
                      ? [
                        const Color(0xFFD7B6A4).withValues(alpha: 0.22),
                        Colors.brown.withValues(alpha: 0.16),
                      ]
                      : [
                        Colors.white.withValues(alpha: 0.64),
                        Colors.brown.withValues(alpha: 0.13),
                      ],
            ),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.20)
                      : Colors.white.withValues(alpha: 0.56),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withValues(alpha: isDark ? 0.22 : 0.14),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.42),
                blurRadius: 12,
                offset: const Offset(-3, -4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dockItem(IconData icon, String label, int index, bool isDark) {
    final selected = _selectedIndex == index;

    return Expanded(
      child: PressableScale(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedIndex = index);
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOutCubic,
          scale: selected ? 1.045 : 1,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOutQuart,
            offset: selected ? const Offset(0, -0.025) : Offset.zero,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutQuart,
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color:
                        selected
                            ? isDark
                                ? const Color(0xFFD7B6A4)
                                : Colors.brown
                            : isDark
                            ? Colors.white70
                            : Colors.brown.withValues(alpha: 0.56),
                    size: 24,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          selected
                              ? isDark
                                  ? const Color(0xFFD7B6A4)
                                  : Colors.brown
                              : isDark
                              ? Colors.white60
                              : Colors.brown.withValues(alpha: 0.56),
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _addPostDockButton() {
    return Expanded(
      child: PressableScale(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(context, "/createPost");
        },
        pressedScale: 0.90,
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            scale: 1,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9B6A55), Colors.brown],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.42),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(-2, -3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 1,
            child: Center(child: GlowingBackgroundLogo(isDark: isDark)),
          ),
        ),
        Padding(
          padding: EdgeInsets.zero,
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection("posts")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: PulseLoader(size: 58));
              }

              final docs = snapshot.data?.docs ?? [];
              final resolvedCount =
                  docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data["status"] == "Resolved";
                  }).length;
              final inProgressCount =
                  docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data["status"] == "In Progress";
                  }).length;

              if (docs.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 108),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _HomeHeader(
                      totalCount: 0,
                      inProgressCount: 0,
                      resolvedCount: 0,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 80),
                    const Center(
                      child: Text(
                        "No posts yet",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 108),
                physics: const BouncingScrollPhysics(),
                itemCount: docs.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _HomeHeader(
                      totalCount: docs.length,
                      inProgressCount: inProgressCount,
                      resolvedCount: resolvedCount,
                      isDark: isDark,
                    );
                  }

                  final postIndex = i - 1;
                  final data = docs[postIndex].data() as Map<String, dynamic>;

                  return PostCard(
                    index: postIndex,
                    postId: docs[postIndex].id,
                    user: data["userName"] ?? "Unknown User",
                    ownerId: data["userId"] ?? "",
                    text: data["text"] ?? "",
                    imageUrl: data["imageUrl"],
                    imagePath: data["imagePath"],
                    status: data["status"] ?? "Pending",
                    editedOnce: data["editedOnce"] ?? false,
                    createdAt: data["createdAt"],
                    likes: (data["likedBy"] ?? []).length,
                    commentsCount: data["commentsCount"] ?? 0,
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

class _HomeHeader extends StatelessWidget {
  final int totalCount;
  final int inProgressCount;
  final int resolvedCount;
  final bool isDark;

  const _HomeHeader({
    required this.totalCount,
    required this.inProgressCount,
    required this.resolvedCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.045)
                : Colors.white.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.brown.withValues(alpha: 0.14),
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CivicConnect",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.brown.shade900,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Community issue dashboard",
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.28),
                  ),
                ),
                child: const Text(
                  "Live",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _miniStat("Reports", totalCount.toString(), Icons.campaign),
              const SizedBox(width: 10),
              _miniStat("Working", inProgressCount.toString(), Icons.timelapse),
              const SizedBox(width: 10),
              _miniStat(
                "Resolved",
                resolvedCount.toString(),
                Icons.check_circle_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 9),
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.black.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.brown, size: 19),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.brown.shade900,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();
  String query = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Search Issues",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.brown.shade900,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color:
                    isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.48),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() => query = value.trim().toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: "Search by text, user, status, location, hashtag",
                  prefixIcon: const Icon(Icons.search, color: Colors.brown),
                  suffixIcon:
                      query.isNotEmpty
                          ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() => query = "");
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.brown,
                            ),
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService().getPosts(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: PulseLoader(size: 52));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final filteredDocs =
                      docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        if (query.isEmpty) return true;

                        final hashtags = (data["hashtags"] as List? ?? []).join(
                          " ",
                        );
                        final searchable =
                            [
                              data["text"] ?? "",
                              data["userName"] ?? "",
                              data["status"] ?? "",
                              data["location"] ?? "",
                              hashtags,
                            ].join(" ").toLowerCase();

                        return searchable.contains(query);
                      }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Text(
                        query.isEmpty
                            ? "Start typing to search issues"
                            : "No matching issues found",
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return PostCard(
                        index: index,
                        postId: doc.id,
                        user: data["userName"] ?? "Unknown User",
                        ownerId: data["userId"] ?? "",
                        text: data["text"] ?? "",
                        imageUrl: data["imageUrl"],
                        imagePath: data["imagePath"],
                        status: data["status"] ?? "Pending",
                        editedOnce: data["editedOnce"] ?? false,
                        createdAt: data["createdAt"],
                        likes: (data["likedBy"] ?? []).length,
                        commentsCount: data["commentsCount"] ?? 0,
                        isLikedByMe: FirestoreService().isLikedByMe(data),
                        isDark: isDark,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final int index;
  final String postId;
  final String user;
  final String ownerId;
  final String text;
  final String? imageUrl;
  final String? imagePath;
  final String status;
  final bool editedOnce;
  final dynamic createdAt;
  final int likes;
  final int commentsCount;
  final bool isLikedByMe;
  final bool isDark;

  const PostCard({
    super.key,
    required this.index,
    required this.postId,
    required this.user,
    required this.ownerId,
    required this.text,
    required this.imageUrl,
    required this.imagePath,
    required this.status,
    required this.editedOnce,
    required this.createdAt,
    required this.likes,
    required this.commentsCount,
    required this.isLikedByMe,
    required this.isDark,
  });

  static const List<String> statusOptions = [
    "Pending",
    "In Progress",
    "Resolved",
  ];

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + (index.clamp(0, 6) * 24)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _showPostPreview(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color:
                isDark
                    ? const Color(0xFF101010).withValues(alpha: 0.78)
                    : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _postContent(context, statusColor),
        ),
      ),
    );
  }

  Widget _postContent(BuildContext context, Color statusColor) {
    final canDelete = FirebaseAuth.instance.currentUser?.uid == ownerId;
    final canEdit = canDelete && !editedOnce;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.brown.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 15,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatPostedTime(createdAt),
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _statusMenu(statusColor),
                const SizedBox(width: 4),
                _postActionsMenu(
                  context,
                  canDelete: canDelete,
                  canEdit: canEdit,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            PressableScale(
              onTap: () async {
                HapticFeedback.selectionClick();
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
            PressableScale(
              onTap: () {
                HapticFeedback.selectionClick();
                _showCommentsSheet(context);
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.mode_comment_outlined,
                    color: Colors.brown,
                    size: 28,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    commentsCount.toString(),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            PressableScale(
              onTap: () {
                HapticFeedback.selectionClick();
                _sharePost(context);
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
    );
  }

  void _showPostPreview(BuildContext context) {
    final statusColor = _statusColor(status);
    final canDelete = FirebaseAuth.instance.currentUser?.uid == ownerId;
    final canEdit = canDelete && !editedOnce;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close post preview",
      barrierColor: Colors.black.withValues(alpha: 0.22),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: SafeArea(
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 560),
                  margin: const EdgeInsets.all(18),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? const Color(0xFF101010).withValues(alpha: 0.86)
                            : const Color(0xFFFFFCF5).withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.42),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 35,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user,
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.white
                                                  : Colors.brown.shade800,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 21,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        _formatPostedTime(createdAt),
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.white60
                                                  : Colors.black54,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 84),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _statusBadge(statusColor),
                            const SizedBox(height: 16),
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.35,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  imageUrl!,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _postActionsMenu(
                              context,
                              canDelete: canDelete,
                              canEdit: canEdit,
                              closeAfterDelete: true,
                            ),
                            IconButton(
                              tooltip: "Close",
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.brown,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _deletePostButton(
    BuildContext context, {
    bool closeAfterDelete = false,
  }) {
    return IconButton(
      tooltip: "Delete post",
      visualDensity: VisualDensity.compact,
      onPressed:
          () => _confirmDeletePost(context, closeAfterDelete: closeAfterDelete),
      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
    );
  }

  Widget _postActionsMenu(
    BuildContext context, {
    required bool canDelete,
    required bool canEdit,
    bool closeAfterDelete = false,
  }) {
    return PopupMenuButton<String>(
      tooltip: "Post options",
      icon: Icon(
        Icons.more_vert_rounded,
        color: isDark ? Colors.white70 : Colors.brown,
      ),
      color:
          isDark
              ? const Color(0xFF151515).withValues(alpha: 0.88)
              : const Color(0xFFFFFCF5),
      onSelected: (value) {
        switch (value) {
          case "copy":
            _sharePost(context);
            break;
          case "edit":
            _showEditPostDialog(context);
            break;
          case "delete":
            _confirmDeletePost(context, closeAfterDelete: closeAfterDelete);
            break;
        }
      },
      itemBuilder: (context) {
        final textColor = isDark ? Colors.white : Colors.black87;

        return [
          PopupMenuItem<String>(
            value: "copy",
            child: Row(
              children: [
                const Icon(Icons.copy_rounded, size: 20, color: Colors.brown),
                const SizedBox(width: 10),
                Text("Copy", style: TextStyle(color: textColor)),
              ],
            ),
          ),
          if (canEdit)
            PopupMenuItem<String>(
              value: "edit",
              child: Row(
                children: [
                  const Icon(Icons.edit_rounded, size: 20, color: Colors.brown),
                  const SizedBox(width: 10),
                  Text("Edit post", style: TextStyle(color: textColor)),
                ],
              ),
            )
          else if (FirebaseAuth.instance.currentUser?.uid == ownerId)
            PopupMenuItem<String>(
              enabled: false,
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "Already edited",
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          if (canDelete)
            const PopupMenuItem<String>(
              value: "delete",
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: Colors.redAccent,
                  ),
                  SizedBox(width: 10),
                  Text("Delete", style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
        ];
      },
    );
  }

  Future<void> _showEditPostDialog(BuildContext context) async {
    final controller = TextEditingController(text: text);

    final updatedText = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final dialogIsDark =
            Theme.of(dialogContext).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor:
              dialogIsDark ? const Color(0xFF151515) : const Color(0xFFFFFCF5),
          title: Text(
            "Edit post",
            style: TextStyle(color: dialogIsDark ? Colors.white : Colors.brown),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 5,
            minLines: 3,
            style: TextStyle(
              color: dialogIsDark ? Colors.white : Colors.black87,
            ),
            decoration: const InputDecoration(hintText: "Update your post"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            FilledButton.icon(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty || value == text.trim()) {
                  Navigator.of(dialogContext).pop();
                  return;
                }
                Navigator.of(dialogContext).pop(value);
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text("Save"),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (updatedText == null || updatedText.isEmpty) return;

    final success = await FirestoreService().editPostOnce(postId, updatedText);

    if (!context.mounted) return;

    TopSnackBar.show(
      context,
      success
          ? "Post edited"
          : FirestoreService.lastError ?? "Could not edit post",
      color: success ? Colors.green : Colors.redAccent,
      icon: success ? Icons.check_circle_outline : Icons.error_outline,
    );
  }

  Future<void> _confirmDeletePost(
    BuildContext context, {
    bool closeAfterDelete = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogIsDark =
            Theme.of(dialogContext).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor:
              dialogIsDark ? const Color(0xFF050505) : const Color(0xFFFFFCF5),
          title: Text(
            "Delete post?",
            style: TextStyle(color: dialogIsDark ? Colors.white : Colors.brown),
          ),
          content: Text(
            "This will remove the post, its photo, and its comments.",
            style: TextStyle(
              color: dialogIsDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancel"),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success = await FirestoreService().deletePost(
      postId,
      imagePath: imagePath,
    );

    if (!context.mounted) return;

    if (success) {
      if (closeAfterDelete) {
        Navigator.of(context, rootNavigator: true).maybePop();
      }
      TopSnackBar.show(
        context,
        "Post deleted",
        color: Colors.green,
        icon: Icons.check_circle_outline,
      );
    } else {
      TopSnackBar.show(
        context,
        FirestoreService.lastError ?? "Could not delete post",
        color: Colors.redAccent,
        icon: Icons.error_outline,
      );
    }
  }

  void _showCommentsSheet(BuildContext context) {
    final controller = TextEditingController();
    var isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.72,
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? const Color(0xFF101010).withValues(alpha: 0.90)
                          : const Color(0xFFFFFCF5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.brown.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.mode_comment_outlined,
                          color: Colors.brown,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Comments",
                          style: TextStyle(
                            color:
                                isDark ? Colors.white : Colors.brown.shade900,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirestoreService().getComments(postId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(child: PulseLoader(size: 48));
                          }

                          final comments = snapshot.data?.docs ?? [];

                          if (comments.isEmpty) {
                            return Center(
                              child: Text(
                                "No comments yet",
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white60 : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: comments.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final commentId = comments[index].id;
                              final data =
                                  comments[index].data()
                                      as Map<String, dynamic>;
                              final commentLikes =
                                  (data["likedBy"] ?? []).length;
                              final isCommentLiked = FirestoreService()
                                  .isCommentLikedByMe(data);

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.brown.withValues(
                                            alpha: 0.08,
                                          ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data["userName"] ?? "User",
                                                style: TextStyle(
                                                  color:
                                                      isDark
                                                          ? Colors.white
                                                          : Colors
                                                              .brown
                                                              .shade700,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.schedule,
                                                    size: 13,
                                                    color:
                                                        isDark
                                                            ? Colors.white54
                                                            : Colors.black45,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _formatPostedTime(
                                                      data["createdAt"],
                                                    ),
                                                    style: TextStyle(
                                                      color:
                                                          isDark
                                                              ? Colors.white54
                                                              : Colors.black45,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await FirestoreService()
                                                .toggleCommentLike(
                                                  postId,
                                                  commentId,
                                                );
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                isCommentLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                size: 20,
                                                color:
                                                    isCommentLiked
                                                        ? Colors.red
                                                        : Colors.brown,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                commentLikes.toString(),
                                                style: TextStyle(
                                                  color:
                                                      isDark
                                                          ? Colors.white70
                                                          : Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data["text"] ?? "",
                                      style: TextStyle(
                                        color:
                                            isDark
                                                ? Colors.white70
                                                : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            minLines: 1,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "Add a comment...",
                              filled: true,
                              fillColor:
                                  isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                          ),
                          onPressed:
                              isSending
                                  ? null
                                  : () async {
                                    final comment = controller.text.trim();
                                    if (comment.isEmpty) return;

                                    setSheetState(() => isSending = true);
                                    final success = await FirestoreService()
                                        .addComment(postId, comment);

                                    if (success) {
                                      controller.clear();
                                    } else if (context.mounted) {
                                      TopSnackBar.show(
                                        context,
                                        "Could not add comment",
                                        color: Colors.redAccent,
                                        icon: Icons.error_outline,
                                      );
                                    }

                                    if (context.mounted) {
                                      setSheetState(() => isSending = false);
                                    }
                                  },
                          icon:
                              isSending
                                  ? const PulseLoader(
                                    size: 22,
                                    color: Colors.white,
                                    showLogo: false,
                                  )
                                  : const Icon(Icons.send_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  Future<void> _sharePost(BuildContext context) async {
    final buffer =
        StringBuffer()
          ..writeln("CivicConnect issue")
          ..writeln("By: $user")
          ..writeln("Status: $status")
          ..writeln("Posted: ${_formatPostedTime(createdAt)}")
          ..writeln()
          ..writeln(text);

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln("Photo: $imageUrl");
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString().trim()));

    if (!context.mounted) return;

    TopSnackBar.show(
      context,
      "Post copied to clipboard",
      color: Colors.green,
      icon: Icons.check_circle_outline,
    );
  }

  Widget _statusMenu(Color statusColor) {
    return PopupMenuButton<String>(
      tooltip: "Change status",
      initialValue: status,
      onSelected: (value) async {
        await FirestoreService().updatePostStatus(postId, value);
      },
      itemBuilder:
          (context) =>
              statusOptions
                  .map(
                    (option) => PopupMenuItem<String>(
                      value: option,
                      child: Row(
                        children: [
                          Icon(
                            _statusIcon(option),
                            size: 18,
                            color: _statusColor(option),
                          ),
                          const SizedBox(width: 8),
                          Text(option),
                        ],
                      ),
                    ),
                  )
                  .toList(),
      child: _statusBadge(statusColor, showArrow: true),
    );
  }

  Widget _statusBadge(Color statusColor, {bool showArrow = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 16, color: statusColor),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (showArrow) ...[
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 18, color: statusColor),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String value) {
    switch (value) {
      case "In Progress":
        return Colors.orange.shade800;
      case "Resolved":
        return Colors.green.shade700;
      case "Pending":
      default:
        return Colors.red.shade700;
    }
  }

  IconData _statusIcon(String value) {
    switch (value) {
      case "In Progress":
        return Icons.timelapse;
      case "Resolved":
        return Icons.check_circle_outline;
      case "Pending":
      default:
        return Icons.pending_actions;
    }
  }

  String _formatPostedTime(dynamic value) {
    DateTime? postedAt;

    if (value is Timestamp) {
      postedAt = value.toDate();
    } else if (value is DateTime) {
      postedAt = value;
    }

    if (postedAt == null) return "Posting...";

    final difference = DateTime.now().difference(postedAt);

    if (difference.inSeconds < 60) return "Just now";
    if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
    if (difference.inHours < 24) return "${difference.inHours}h ago";
    if (difference.inDays < 7) return "${difference.inDays}d ago";

    final hour = postedAt.hour > 12 ? postedAt.hour - 12 : postedAt.hour;
    final displayHour = hour == 0 ? 12 : hour;
    final minute = postedAt.minute.toString().padLeft(2, "0");
    final period = postedAt.hour >= 12 ? "PM" : "AM";

    return "${postedAt.day}/${postedAt.month}/${postedAt.year} $displayHour:$minute $period";
  }
}

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
