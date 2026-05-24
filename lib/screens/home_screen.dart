import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart'
    show
        FlutterMap,
        MapController,
        MapOptions,
        Marker,
        MarkerLayer,
        Polygon,
        PolygonLayer,
        RichAttributionWidget,
        TextSourceAttribution,
        TileLayer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:civicconnect/screens/profile_screen.dart';
import '../services/firestore_services.dart';
import '../services/gemini_service.dart';
import '../utils/top_snackbar.dart';
import '../widgets/glowing_background_logo.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/pulse_loader.dart';
import '../widgets/scroll_to_top_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ScrollController _feedScrollController = ScrollController();

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      FeedScreen(scrollController: _feedScrollController),
      const ZoneMapScreen(),
      const SearchScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _feedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF0EDE5),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );

              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.02, 0.025),
                    end: Offset.zero,
                  ).animate(curved),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
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
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            bottom: keyboardOpen ? -110 : 14 + bottomInset,
            left: 14,
            right: 14,
            child: IgnorePointer(
              ignoring: keyboardOpen,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 140),
                opacity: keyboardOpen ? 0 : 1,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: _bottomNavBar(isDark),
                  ),
                ),
              ),
            ),
          ),
          if (!keyboardOpen)
            Positioned(
              right: 18,
              bottom: 108 + bottomInset,
              child: _civicMateHoverButton(isDark),
            ),
          if (!keyboardOpen && _selectedIndex == 0)
            ScrollToTopButton(
              controller: _feedScrollController,
              isDark: isDark,
              heroTag: "home_go_top",
              bottom: 174 + bottomInset,
              right: 22,
            ),
        ],
      ),
    );
  }

  Widget _civicMateHoverButton(bool isDark) {
    return _RainbowTapButton(isDark: isDark, onTap: _openCivicMate);
  }

  void _openCivicMate() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 140),
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const Scaffold(body: AiChatScreen()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _bottomNavBar(bool isDark) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
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
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    left: visualIndex * itemWidth + 5,
                    top: 10,
                    width: itemWidth - 10,
                    height: 58,
                    child: _liquidNavHighlight(isDark),
                  ),
                  Row(
                    children: [
                      _dockItem(Icons.home_rounded, "Home", 0, isDark),
                      _dockItem(Icons.map_outlined, "Map", 1, isDark),
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
    return DecoratedBox(
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
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.52),
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
        glow: selected,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          scale: selected ? 1.05 : 1,
          child: Container(
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
        glow: false,
        child: Center(
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
                  color: Colors.brown.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}

class _RainbowTapButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _RainbowTapButton({required this.isDark, required this.onTap});

  @override
  State<_RainbowTapButton> createState() => _RainbowTapButtonState();
}

class _RainbowTapButtonState extends State<_RainbowTapButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tap() {
    _controller
      ..reset()
      ..forward();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_controller.value);
        final glowAlpha = 0.18 + (0.44 * (1 - t));

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: glowAlpha),
                blurRadius: 14 + (22 * (1 - t)),
                offset: const Offset(-4, 0),
              ),
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: glowAlpha),
                blurRadius: 14 + (22 * (1 - t)),
                offset: const Offset(4, 0),
              ),
              BoxShadow(
                color: Colors.purpleAccent.withValues(alpha: glowAlpha * 0.8),
                blurRadius: 18 + (18 * (1 - t)),
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: _tap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color:
                isDark
                    ? const Color(0xFF151515).withValues(alpha: 0.94)
                    : const Color(0xFFFFFCF5).withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.16)
                      : Colors.brown.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.brown),
              const SizedBox(width: 7),
              Text(
                "CivicMate",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.brown.shade900,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeedScreen extends StatefulWidget {
  final ScrollController scrollController;

  const FeedScreen({super.key, required this.scrollController});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 380 ? 12.0 : 18.0;

    return Stack(
      children: [
        Positioned.fill(
          child: Center(child: GlowingBackgroundLogo(isDark: isDark)),
        ),
        SafeArea(
          bottom: false,
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
                return RefreshIndicator(
                  color: Colors.brown,
                  onRefresh: _refreshFeed,
                  child: ListView(
                    controller: widget.scrollController,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      18,
                      horizontalPadding,
                      108,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 860),
                          child: _HomeHeader(
                            totalCount: 0,
                            inProgressCount: 0,
                            resolvedCount: 0,
                            isDark: isDark,
                          ),
                        ),
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
                  ),
                );
              }

              return RefreshIndicator(
                color: Colors.brown,
                onRefresh: _refreshFeed,
                child: ListView.builder(
                  controller: widget.scrollController,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    108,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: docs.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 860),
                          child: _HomeHeader(
                            totalCount: docs.length,
                            inProgressCount: inProgressCount,
                            resolvedCount: resolvedCount,
                            isDark: isDark,
                          ),
                        ),
                      );
                    }

                    final postIndex = i - 1;
                    final data = docs[postIndex].data() as Map<String, dynamic>;

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: PostCard(
                          index: postIndex,
                          postId: docs[postIndex].id,
                          user: data["userName"] ?? "Unknown User",
                          ownerId: data["userId"] ?? "",
                          text: data["text"] ?? "",
                          location: data["location"] ?? "",
                          category: data["category"] ?? "General",
                          urgency: data["urgency"] ?? "Medium",
                          imageUrl: data["imageUrl"],
                          imageUrls: _imageUrlsFromData(data),
                          imagePath: data["imagePath"],
                          status: data["status"] ?? "Pending",
                          editedOnce: data["editedOnce"] ?? false,
                          createdAt: data["createdAt"],
                          likes: (data["likedBy"] ?? []).length,
                          likedBy: List<String>.from(
                            data["likedBy"] as List? ?? [],
                          ),
                          commentsCount: data["commentsCount"] ?? 0,
                          isLikedByMe: FirestoreService().isLikedByMe(data),
                          isDark: isDark,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _refreshFeed() async {
    setState(() {});
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }
}

class _HomeHeader extends StatefulWidget {
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
  State<_HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<_HomeHeader> {
  late DateTime _now;
  Timer? _clockTimer;
  String _temperature = "--";

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _loadTemperature();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTemperature() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final uri = Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current_weather=true",
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final weather = data["current_weather"] as Map<String, dynamic>?;
      final temp = weather?["temperature"];
      if (temp == null || !mounted) return;

      setState(() => _temperature = "${(temp as num).round()}");
    } catch (_) {
      // Weather should never block the dashboard.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 350;
        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: EdgeInsets.all(compact ? 14 : 18),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.045)
                    : Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.22)
                      : Colors.brown.withValues(alpha: 0.16),
            ),
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
              Center(
                child: Column(
                  children: [
                    _RgbGlowText(
                      "CivicConnect",
                      fontSize: compact ? 23 : 28,
                      fontWeight: FontWeight.w900,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _headerMetaText(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: compact ? 12 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (compact)
                Column(
                  children: [
                    _miniStat(
                      "Reports",
                      widget.totalCount.toString(),
                      Icons.campaign,
                    ),
                    const SizedBox(height: 8),
                    _miniStat(
                      "Working",
                      widget.inProgressCount.toString(),
                      Icons.timelapse,
                    ),
                    const SizedBox(height: 8),
                    _miniStat(
                      "Resolved",
                      widget.resolvedCount.toString(),
                      Icons.check_circle_outline,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _miniStat(
                        "Reports",
                        widget.totalCount.toString(),
                        Icons.campaign,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _miniStat(
                        "Working",
                        widget.inProgressCount.toString(),
                        Icons.timelapse,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _miniStat(
                        "Resolved",
                        widget.resolvedCount.toString(),
                        Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  String _headerMetaText() {
    final hour = _now.hour > 12 ? _now.hour - 12 : _now.hour;
    final displayHour = hour == 0 ? 12 : hour;
    final minute = _now.minute.toString().padLeft(2, "0");
    final period = _now.hour >= 12 ? "PM" : "AM";
    final date = "${_now.day}/${_now.month}/${_now.year}";

    return "$displayHour:$minute $period  |  $date  |  $_temperature C";
  }

  Widget _miniStat(String label, String value, IconData icon) {
    final isDark = widget.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 9),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.16),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    );
  }
}

class ZoneArea {
  final String name;
  final String subtitle;
  final double latitude;
  final double longitude;

  const ZoneArea({
    required this.name,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
  });
}

const zoneAreas = [
  ZoneArea(
    name: "Zone 1",
    subtitle: "North civic zone",
    latitude: 28.5029,
    longitude: 77.0492,
  ),
  ZoneArea(
    name: "Zone 2",
    subtitle: "Market and school belt",
    latitude: 28.5081,
    longitude: 77.0551,
  ),
  ZoneArea(
    name: "Zone 3",
    subtitle: "Residential core",
    latitude: 28.4977,
    longitude: 77.0576,
  ),
  ZoneArea(
    name: "Zone 4",
    subtitle: "Main road stretch",
    latitude: 28.4944,
    longitude: 77.0461,
  ),
  ZoneArea(
    name: "Zone 5",
    subtitle: "South civic zone",
    latitude: 28.4889,
    longitude: 77.0524,
  ),
];

class ZoneMapScreen extends StatefulWidget {
  const ZoneMapScreen({super.key});

  @override
  State<ZoneMapScreen> createState() => _ZoneMapScreenState();
}

class _ZoneMapScreenState extends State<ZoneMapScreen> {
  final MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _zoomBy(double delta) {
    final camera = _mapController.camera;
    final nextZoom = (camera.zoom + delta).clamp(12.0, 18.0).toDouble();
    _mapController.move(camera.center, nextZoom);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 380 ? 12.0 : 18.0;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(child: GlowingBackgroundLogo(isDark: isDark)),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirestoreService().getPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: PulseLoader(size: 52));
              }

              final docs = snapshot.data?.docs ?? [];
              final issueCounts = <String, int>{
                for (final zone in zoneAreas) zone.name: 0,
              };
              final activeCounts = <String, int>{
                for (final zone in zoneAreas) zone.name: 0,
              };

              for (final doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final location = _zoneLabel(data["location"]?.toString() ?? "");
                if (!issueCounts.containsKey(location)) continue;

                issueCounts[location] = issueCounts[location]! + 1;
                if (data["status"] != "Resolved") {
                  activeCounts[location] = activeCounts[location]! + 1;
                }
              }

              return ListView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  keyboardOpen ? 24 : 108,
                ),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _RgbGlowText(
                            "Zone Map",
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          _mapPreview(isDark, issueCounts, activeCounts),
                          const SizedBox(height: 16),
                          ...zoneAreas.map(
                            (zone) => _zoneTile(
                              context,
                              zone,
                              isDark,
                              total: issueCounts[zone.name] ?? 0,
                              active: activeCounts[zone.name] ?? 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (!keyboardOpen)
            ScrollToTopButton(
              controller: _scrollController,
              isDark: isDark,
              heroTag: "zone_map_go_top",
              bottom: 112,
              right: 22,
            ),
        ],
      ),
    );
  }

  Widget _mapPreview(
    bool isDark,
    Map<String, int> issueCounts,
    Map<String, int> activeCounts,
  ) {
    return Container(
      height: 310,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.055)
                : const Color(0xFFFFFCF5).withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.brown.withValues(alpha: 0.14),
        ),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(28.4988, 77.0521),
              initialZoom: 13.4,
              minZoom: 12,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.civicconnect.app",
              ),
              PolygonLayer(
                polygons:
                    zoneAreas.map((zone) {
                      final active = activeCounts[zone.name] ?? 0;
                      final hot = active > 0;

                      return Polygon(
                        points: _zoneBounds(zone),
                        color: (hot ? Colors.redAccent : Colors.green)
                            .withValues(alpha: isDark ? 0.18 : 0.14),
                        borderColor:
                            hot
                                ? Colors.redAccent.withValues(alpha: 0.78)
                                : Colors.green.withValues(alpha: 0.70),
                        borderStrokeWidth: 2,
                      );
                    }).toList(),
              ),
              MarkerLayer(
                markers:
                    zoneAreas.map((zone) {
                      return Marker(
                        point: LatLng(zone.latitude, zone.longitude),
                        width: 118,
                        height: 48,
                        child: _zoneMarker(
                          zone,
                          isDark,
                          total: issueCounts[zone.name] ?? 0,
                          active: activeCounts[zone.name] ?? 0,
                        ),
                      );
                    }).toList(),
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    "OpenStreetMap contributors",
                    onTap:
                        () => launchUrl(
                          Uri.parse("https://www.openstreetmap.org/copyright"),
                        ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Column(
              children: [
                _mapZoomButton(Icons.add_rounded, () => _zoomBy(1)),
                const SizedBox(height: 8),
                _mapZoomButton(Icons.remove_rounded, () => _zoomBy(-1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapZoomButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black.withValues(alpha: 0.68),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  List<LatLng> _zoneBounds(ZoneArea zone) {
    const latDelta = 0.0032;
    const lngDelta = 0.0038;

    return [
      LatLng(zone.latitude - latDelta, zone.longitude - lngDelta),
      LatLng(zone.latitude - latDelta, zone.longitude + lngDelta),
      LatLng(zone.latitude + latDelta, zone.longitude + lngDelta),
      LatLng(zone.latitude + latDelta, zone.longitude - lngDelta),
    ];
  }

  Widget _zoneMarker(
    ZoneArea zone,
    bool isDark, {
    required int total,
    required int active,
  }) {
    final hot = active > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color:
            hot
                ? Colors.redAccent.withValues(alpha: isDark ? 0.22 : 0.14)
                : Colors.green.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              hot
                  ? Colors.redAccent.withValues(alpha: 0.50)
                  : Colors.green.withValues(alpha: 0.42),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hot ? Icons.location_on_rounded : Icons.check_circle_outline,
            color: hot ? Colors.redAccent : Colors.green,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(
            "${zone.name}  $total",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _zoneTile(
    BuildContext context,
    ZoneArea zone,
    bool isDark, {
    required int total,
    required int active,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xFF101010).withValues(alpha: 0.78)
                : const Color(0xFFFFFCF5).withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.brown.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.brown.withValues(alpha: 0.14),
            ),
            child: const Icon(Icons.location_on_outlined, color: Colors.brown),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.brown.shade900,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "${zone.subtitle}  |  $active active / $total total",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: "Open in Maps",
            onPressed: () => _openZoneInMaps(context, zone),
            icon: const Icon(Icons.near_me_rounded, color: Colors.brown),
          ),
        ],
      ),
    );
  }

  Future<void> _openZoneInMaps(BuildContext context, ZoneArea zone) async {
    final uri = Uri.parse(
      "https://www.openstreetmap.org/?mlat=${zone.latitude}&mlon=${zone.longitude}#map=16/${zone.latitude}/${zone.longitude}",
    );

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened || !context.mounted) return;

    TopSnackBar.show(
      context,
      "Could not open Maps",
      color: Colors.redAccent,
      icon: Icons.error_outline,
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
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late final Stream<QuerySnapshot> _postsStream;
  String query = "";

  @override
  void initState() {
    super.initState();
    _postsStream = FirestoreService().getPosts();
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 380 ? 12.0 : 18.0;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(child: GlowingBackgroundLogo(isDark: isDark)),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _postsStream,
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
                          data["category"] ?? "",
                          data["urgency"] ?? "",
                          hashtags,
                        ].join(" ").toLowerCase();

                    return searchable.contains(query);
                  }).toList();

              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  keyboardOpen ? 24 : 108,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: filteredDocs.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _RgbGlowText(
                              "Search Issues",
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : const Color(
                                          0xFFFFFBF2,
                                        ).withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  width: 1.15,
                                  color:
                                      isDark
                                          ? Colors.white.withValues(alpha: 0.20)
                                          : const Color(
                                            0xFF5A332B,
                                          ).withValues(alpha: 0.28),
                                ),
                                boxShadow: [
                                  if (!isDark)
                                    BoxShadow(
                                      color: Colors.brown.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: TextField(
                                key: const ValueKey("issue-search-field"),
                                controller: searchController,
                                focusNode: _searchFocusNode,
                                cursorColor: Colors.brown,
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? Colors.white
                                          : const Color(0xFF2F211D),
                                  fontWeight: FontWeight.w600,
                                ),
                                onChanged: (value) {
                                  setState(
                                    () => query = value.trim().toLowerCase(),
                                  );
                                },
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: "Search issues, user, zone...",
                                  hintStyle: TextStyle(
                                    color:
                                        isDark
                                            ? Colors.white54
                                            : const Color(
                                              0xFF6B5650,
                                            ).withValues(alpha: 0.72),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color:
                                        isDark
                                            ? const Color(0xFFD7B6A4)
                                            : Colors.brown,
                                    size: 22,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 42,
                                    minHeight: 44,
                                  ),
                                  suffixIcon:
                                      query.isNotEmpty
                                          ? IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 40,
                                              minHeight: 44,
                                            ),
                                            onPressed: () {
                                              searchController.clear();
                                              setState(() => query = "");
                                            },
                                            icon: Icon(
                                              Icons.close_rounded,
                                              color:
                                                  isDark
                                                      ? const Color(0xFFD7B6A4)
                                                      : Colors.brown,
                                              size: 21,
                                            ),
                                          )
                                          : null,
                                  suffixIconConstraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 44,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (filteredDocs.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 80),
                                child: Center(
                                  child: Text(
                                    query.isEmpty
                                        ? "Start typing to search issues"
                                        : "No matching issues found",
                                    style: TextStyle(
                                      color:
                                          isDark
                                              ? Colors.white60
                                              : Colors.black54,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }

                  final doc = filteredDocs[index - 1];
                  final data = doc.data() as Map<String, dynamic>;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: PostCard(
                        index: index - 1,
                        postId: doc.id,
                        user: data["userName"] ?? "Unknown User",
                        ownerId: data["userId"] ?? "",
                        text: data["text"] ?? "",
                        location: data["location"] ?? "",
                        category: data["category"] ?? "General",
                        urgency: data["urgency"] ?? "Medium",
                        imageUrl: data["imageUrl"],
                        imageUrls: _imageUrlsFromData(data),
                        imagePath: data["imagePath"],
                        status: data["status"] ?? "Pending",
                        editedOnce: data["editedOnce"] ?? false,
                        createdAt: data["createdAt"],
                        likes: (data["likedBy"] ?? []).length,
                        likedBy: List<String>.from(
                          data["likedBy"] as List? ?? [],
                        ),
                        commentsCount: data["commentsCount"] ?? 0,
                        isLikedByMe: FirestoreService().isLikedByMe(data),
                        isDark: isDark,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (!keyboardOpen)
            ScrollToTopButton(
              controller: _scrollController,
              isDark: isDark,
              heroTag: "search_go_top",
              bottom: 112,
              right: 22,
            ),
        ],
      ),
    );
  }
}

String _zoneLabel(String value) {
  return value.replaceFirst("Sector", "Zone");
}

List<String> _imageUrlsFromData(Map<String, dynamic> data) {
  final urls =
      (data["imageUrls"] as List? ?? [])
          .map((value) => value.toString())
          .where((value) => value.trim().isNotEmpty)
          .toList();
  final single = data["imageUrl"]?.toString() ?? "";
  if (urls.isEmpty && single.trim().isNotEmpty) return [single];
  return urls;
}

class PostCard extends StatelessWidget {
  final int index;
  final String postId;
  final String user;
  final String ownerId;
  final String text;
  final String location;
  final String category;
  final String urgency;
  final String? imageUrl;
  final List<String> imageUrls;
  final String? imagePath;
  final String status;
  final bool editedOnce;
  final dynamic createdAt;
  final int likes;
  final List<String> likedBy;
  final int commentsCount;
  final bool isLikedByMe;
  final bool isDark;
  final VoidCallback? onCommentTap;

  const PostCard({
    super.key,
    required this.index,
    required this.postId,
    required this.user,
    required this.ownerId,
    required this.text,
    required this.location,
    required this.category,
    required this.urgency,
    required this.imageUrl,
    required this.imageUrls,
    required this.imagePath,
    required this.status,
    required this.editedOnce,
    required this.createdAt,
    required this.likes,
    required this.likedBy,
    required this.commentsCount,
    required this.isLikedByMe,
    required this.isDark,
    this.onCommentTap,
  });

  static const List<String> statusOptions = [
    "Pending",
    "In Progress",
    "Resolved",
  ];

  String get displayLocation => _zoneLabel(location);

  List<String> get displayImageUrls {
    if (imageUrls.isNotEmpty) return imageUrls;
    final single = imageUrl?.trim() ?? "";
    return single.isEmpty ? const [] : [single];
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);

    return TweenAnimationBuilder<double>(
      key: ValueKey("post-card-$postId"),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + (index.clamp(0, 8) * 42)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final opacity = value.clamp(0.0, 1.0).toDouble();
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - value)),
            child: Transform.scale(
              scale: 0.975 + (0.025 * value),
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _showPostPreview(context),
        child: RepaintBoundary(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? const Color(0xFF101010).withValues(alpha: 0.78)
                      : const Color(0xFFFFFCF5).withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.white.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _postContent(context, statusColor),
          ),
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
                  if (location.trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 15,
                          color: Colors.brown,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            displayLocation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _statusMenu(context, statusColor),
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _infoChip(_categoryIcon(category), category, Colors.blueGrey),
            _infoChip(
              Icons.priority_high_rounded,
              "$urgency urgency",
              _urgencyColor(urgency),
            ),
            if (_mentionsCivicMate)
              _infoChip(
                Icons.auto_awesome_rounded,
                "CivicMate tagged",
                Colors.purple,
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
        if (displayImageUrls.isNotEmpty) ...[
          _imageGallery(context, displayImageUrls, previewHeight: 220),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            PressableScale(
              glow: false,
              onTap: () async {
                HapticFeedback.selectionClick();
                await FirestoreService().toggleLike(postId);
              },
              child: Row(
                children: [
                  TweenAnimationBuilder<double>(
                    key: ValueKey("$postId-like-$isLikedByMe-$likes"),
                    tween: Tween(begin: isLikedByMe ? 1.25 : 0.92, end: 1),
                    duration: const Duration(milliseconds: 230),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Icon(
                      isLikedByMe ? Icons.favorite : Icons.favorite_border,
                      color: isLikedByMe ? Colors.red : Colors.brown,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _showLikedBySheet(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      child: Text(
                        likes.toString(),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w700,
                          decoration:
                              likes > 0
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                          decorationColor:
                              isDark ? Colors.white54 : Colors.brown,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PressableScale(
              glow: false,
              onTap: () {
                HapticFeedback.selectionClick();
                if (onCommentTap != null) {
                  onCommentTap!();
                } else {
                  _showCommentsSheet(context);
                }
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
              glow: false,
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
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _statusBadge(statusColor),
                                _infoChip(
                                  _categoryIcon(category),
                                  category,
                                  Colors.blueGrey,
                                ),
                                _infoChip(
                                  Icons.priority_high_rounded,
                                  "$urgency urgency",
                                  _urgencyColor(urgency),
                                ),
                              ],
                            ),
                            if (location.trim().isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.place_outlined,
                                    color: Colors.brown,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      displayLocation,
                                      style: TextStyle(
                                        color:
                                            isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.35,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (displayImageUrls.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              _imageGallery(
                                context,
                                displayImageUrls,
                                previewHeight: 260,
                                contain: true,
                              ),
                            ],
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _openFullPost(context);
                                    },
                                    icon: const Icon(
                                      Icons.open_in_full_rounded,
                                    ),
                                    label: const Text("Open full post"),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  onPressed: () => _showLikedBySheet(context),
                                  icon: const Icon(Icons.favorite_rounded),
                                  label: Text("$likes"),
                                ),
                              ],
                            ),
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
          case "open":
            _openFullPost(context);
            break;
          case "likes":
            _showLikedBySheet(context);
            break;
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
            value: "open",
            child: Row(
              children: [
                const Icon(
                  Icons.open_in_full_rounded,
                  size: 20,
                  color: Colors.brown,
                ),
                const SizedBox(width: 10),
                Text("Open full post", style: TextStyle(color: textColor)),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: "likes",
            child: Row(
              children: [
                const Icon(
                  Icons.favorite_border_rounded,
                  size: 20,
                  color: Colors.brown,
                ),
                const SizedBox(width: 10),
                Text("Liked by", style: TextStyle(color: textColor)),
              ],
            ),
          ),
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
            cursorColor: Colors.brown,
            style: TextStyle(
              color: dialogIsDark ? Colors.white : const Color(0xFF2F211D),
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: "Update your post",
              hintStyle: TextStyle(
                color:
                    dialogIsDark
                        ? Colors.white54
                        : const Color(0xFF6B5650).withValues(alpha: 0.72),
              ),
              filled: true,
              fillColor:
                  dialogIsDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFFFFBF2).withValues(alpha: 0.78),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      dialogIsDark
                          ? Colors.white.withValues(alpha: 0.18)
                          : const Color(0xFF5A332B).withValues(alpha: 0.46),
                  width: 1.25,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      dialogIsDark
                          ? Colors.white.withValues(alpha: 0.18)
                          : const Color(0xFF5A332B).withValues(alpha: 0.46),
                  width: 1.25,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      dialogIsDark
                          ? const Color(0xFFD7B6A4).withValues(alpha: 0.62)
                          : const Color(0xFF5A332B).withValues(alpha: 0.78),
                  width: 1.7,
                ),
              ),
            ),
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
    String? replyToCommentId;
    String? replyToUserName;
    final commentImages = <Uint8List>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final showCivicMateSuggestion = _shouldShowCivicMateSuggestion(
              controller,
            );

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
                              final repliedTo =
                                  (data["replyToUserName"] ?? "").toString();
                              final commentImageUrls = _imageUrlsFromData(data);
                              final canDeleteComment =
                                  FirebaseAuth.instance.currentUser?.uid ==
                                  data["userId"];

                              return TweenAnimationBuilder<double>(
                                key: ValueKey(commentId),
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(
                                  milliseconds: 180 + (index * 18),
                                ),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  final opacity =
                                      value.clamp(0.0, 1.0).toDouble();
                                  return Opacity(
                                    opacity: opacity,
                                    child: Transform.translate(
                                      offset: Offset(0, 8 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? Colors.white.withValues(
                                              alpha: 0.05,
                                            )
                                            : Colors.brown.withValues(
                                              alpha: 0.08,
                                            ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                                : Colors
                                                                    .black45,
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
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
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
                                                          : Icons
                                                              .favorite_border,
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
                                                                : Colors
                                                                    .black87,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (canDeleteComment) ...[
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  tooltip: "Delete comment",
                                                  onPressed: () async {
                                                    final ok =
                                                        await FirestoreService()
                                                            .deleteComment(
                                                              postId,
                                                              commentId,
                                                            );
                                                    if (!ok &&
                                                        context.mounted) {
                                                      TopSnackBar.show(
                                                        context,
                                                        FirestoreService
                                                                .lastError ??
                                                            "Could not delete comment",
                                                        color: Colors.redAccent,
                                                        icon:
                                                            Icons.error_outline,
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.brown,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (repliedTo.isNotEmpty) ...[
                                        Text(
                                          "Replying to $repliedTo",
                                          style: TextStyle(
                                            color:
                                                isDark
                                                    ? const Color(0xFFD7B6A4)
                                                    : Colors.brown.shade600,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                      ],
                                      Text(
                                        data["text"] ?? "",
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                        ),
                                      ),
                                      if (commentImageUrls.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        _imageGallery(
                                          context,
                                          commentImageUrls,
                                          previewHeight: 140,
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                            visualDensity:
                                                VisualDensity.compact,
                                            foregroundColor: Colors.brown,
                                          ),
                                          onPressed: () {
                                            final name =
                                                (data["userName"] ?? "User")
                                                    .toString();
                                            replyToCommentId = commentId;
                                            replyToUserName = name;
                                            if (controller.text
                                                .trim()
                                                .isEmpty) {
                                              controller.text = "@$name ";
                                              controller.selection =
                                                  TextSelection.collapsed(
                                                    offset:
                                                        controller.text.length,
                                                  );
                                            }
                                            setSheetState(() {});
                                          },
                                          icon: const Icon(
                                            Icons.reply_rounded,
                                            size: 17,
                                          ),
                                          label: const Text("Reply"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (replyToUserName != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.brown.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.reply_rounded,
                              size: 18,
                              color: Colors.brown,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Replying to $replyToUserName",
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? Colors.white70
                                          : Colors.brown.shade900,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                replyToCommentId = null;
                                replyToUserName = null;
                                setSheetState(() {});
                              },
                              icon: const Icon(Icons.close_rounded, size: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (showCivicMateSuggestion) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _civicMateCommentSuggestion(isDark, () {
                          _insertCivicMateMention(controller);
                          setSheetState(() {});
                        }),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (commentImages.isNotEmpty) ...[
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: commentImages.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    commentImages[index],
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap:
                                        () => setSheetState(
                                          () => commentImages.removeAt(index),
                                        ),
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.65,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        IconButton(
                          tooltip: "Attach images",
                          onPressed: () async {
                            final picked = await ImagePicker().pickMultiImage(
                              imageQuality: 78,
                              maxWidth: 1600,
                            );
                            if (picked.isEmpty) return;
                            for (final image in picked) {
                              commentImages.add(await image.readAsBytes());
                            }
                            setSheetState(() {});
                          },
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            color: Colors.brown,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            minLines: 1,
                            maxLines: 3,
                            cursorColor: Colors.brown,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? Colors.white
                                      : const Color(0xFF2F211D),
                              fontWeight: FontWeight.w600,
                            ),
                            onChanged: (_) => setSheetState(() {}),
                            decoration: InputDecoration(
                              hintText: "Add a comment...",
                              hintStyle: TextStyle(
                                color:
                                    isDark
                                        ? Colors.white54
                                        : const Color(
                                          0xFF6B5650,
                                        ).withValues(alpha: 0.72),
                              ),
                              filled: true,
                              fillColor:
                                  isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : const Color(
                                        0xFFFFFBF2,
                                      ).withValues(alpha: 0.74),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color:
                                      isDark
                                          ? Colors.white.withValues(alpha: 0.16)
                                          : const Color(
                                            0xFF5A332B,
                                          ).withValues(alpha: 0.44),
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color:
                                      isDark
                                          ? Colors.white.withValues(alpha: 0.16)
                                          : const Color(
                                            0xFF5A332B,
                                          ).withValues(alpha: 0.44),
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color:
                                      isDark
                                          ? const Color(
                                            0xFFD7B6A4,
                                          ).withValues(alpha: 0.62)
                                          : const Color(
                                            0xFF5A332B,
                                          ).withValues(alpha: 0.78),
                                  width: 1.7,
                                ),
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
                                    if (comment.isEmpty &&
                                        commentImages.isEmpty) {
                                      return;
                                    }

                                    setSheetState(() => isSending = true);
                                    final success = await FirestoreService()
                                        .addComment(
                                          postId,
                                          comment,
                                          replyToCommentId: replyToCommentId,
                                          replyToUserName: replyToUserName,
                                          imageBytesList: commentImages,
                                        );

                                    if (success) {
                                      controller.clear();
                                      commentImages.clear();
                                      replyToCommentId = null;
                                      replyToUserName = null;
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
          ..writeln("Category: $category")
          ..writeln("Urgency: $urgency")
          ..writeln("Post link: civicconnect://post/$postId")
          ..writeln(
            "Location: ${displayLocation.isEmpty ? "Not specified" : displayLocation}",
          )
          ..writeln("Posted: ${_formatPostedTime(createdAt)}")
          ..writeln()
          ..writeln(text);

    if (displayImageUrls.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln("Photos:")
        ..writeln(displayImageUrls.join("\n"));
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

  void _showImageFullScreen(BuildContext context, String url) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close image",
      barrierColor: Colors.black,
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _imageGallery(
    BuildContext context,
    List<String> urls, {
    required double previewHeight,
    bool contain = false,
  }) {
    if (urls.length == 1) {
      return GestureDetector(
        onTap: () => _showImageFullScreen(context, urls.first),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.network(
            urls.first,
            width: double.infinity,
            height: previewHeight,
            fit: contain ? BoxFit.contain : BoxFit.cover,
            filterQuality: FilterQuality.low,
            cacheWidth: 900,
          ),
        ),
      );
    }

    return SizedBox(
      height: previewHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: urls.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final url = urls[index];
          return GestureDetector(
            onTap: () => _showImageFullScreen(context, url),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                url,
                width: 220,
                height: previewHeight,
                fit: contain ? BoxFit.contain : BoxFit.cover,
                filterQuality: FilterQuality.low,
                cacheWidth: 700,
              ),
            ),
          );
        },
      ),
    );
  }

  void _openFullPost(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 240),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                _FullPostScreen(postId: postId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.025),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _showLikedBySheet(BuildContext context) async {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final sheetIsDark =
            Theme.of(sheetContext).brightness == Brightness.dark;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.72,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
          decoration: BoxDecoration(
            color:
                sheetIsDark ? const Color(0xFF111111) : const Color(0xFFFFFCF5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(
              color:
                  sheetIsDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.brown.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        sheetIsDark
                            ? Colors.white24
                            : Colors.brown.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Liked by",
                style: TextStyle(
                  color: sheetIsDark ? Colors.white : Colors.brown.shade900,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (likedBy.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Text(
                      "No likes yet",
                      style: TextStyle(
                        color: sheetIsDark ? Colors.white54 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: likedBy.length,
                    separatorBuilder:
                        (_, __) => Divider(
                          color:
                              sheetIsDark
                                  ? Colors.white10
                                  : Colors.brown.withValues(alpha: 0.10),
                        ),
                    itemBuilder:
                        (context, index) =>
                            _likedUserTile(likedBy[index], sheetIsDark),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _likedUserTile(String uid, bool sheetIsDark) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection("users").doc(uid).get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final name =
            (data?["displayName"] ?? data?["name"] ?? data?["userName"])
                ?.toString()
                .trim();
        final email = data?["email"]?.toString().trim();
        final title = (name != null && name.isNotEmpty) ? name : "Civic user";

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.brown.withValues(alpha: 0.16),
            child: const Icon(Icons.person_rounded, color: Colors.brown),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: sheetIsDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle:
              email == null || email.isEmpty
                  ? null
                  : Text(
                    email,
                    style: TextStyle(
                      color: sheetIsDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
        );
      },
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _urgencyColor(String value) {
    switch (value.toLowerCase()) {
      case "high":
        return Colors.red.shade700;
      case "medium":
        return Colors.orange.shade800;
      case "low":
      default:
        return Colors.green.shade700;
    }
  }

  bool get _mentionsCivicMate {
    final value = text.toLowerCase();
    return value.contains("@civicmate") || value.contains("@civicconnect");
  }

  IconData _categoryIcon(String value) {
    switch (value.toLowerCase()) {
      case "road":
        return Icons.add_road_rounded;
      case "garbage":
        return Icons.delete_outline_rounded;
      case "water":
        return Icons.water_drop_outlined;
      case "electricity":
        return Icons.bolt_outlined;
      case "safety":
        return Icons.health_and_safety_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Widget _statusMenu(BuildContext context, Color statusColor) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUserId != null && currentUserId == ownerId;

    if (status == "Resolved") {
      return Tooltip(
        message: "Resolved posts are locked",
        child: _statusBadge(statusColor),
      );
    }

    if (!isOwner) {
      return Tooltip(
        message: "Only the post owner can change status",
        child: _statusBadge(statusColor),
      );
    }

    return PopupMenuButton<String>(
      tooltip: "Change status",
      initialValue: status,
      onSelected: (value) async {
        bool success;
        if (value == "Resolved") {
          success = await _askResolutionProofAndResolve(context);
        } else {
          success = await FirestoreService().updatePostStatus(postId, value);
        }

        if (!success) {
          if (!context.mounted) return;
          TopSnackBar.show(
            context,
            FirestoreService.lastError ?? "Could not update status",
            color: Colors.redAccent,
            icon: Icons.error_outline,
          );
        }
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

  Future<bool> _askResolutionProofAndResolve(BuildContext context) async {
    final controller = TextEditingController();
    final proofImages = <Uint8List>[];

    final proof = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final dialogIsDark =
            Theme.of(dialogContext).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor:
                  dialogIsDark
                      ? const Color(0xFF151515)
                      : const Color(0xFFFFFCF5),
              title: Text(
                "Add resolution proof",
                style: TextStyle(
                  color: dialogIsDark ? Colors.white : Colors.brown,
                ),
              ),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      minLines: 3,
                      maxLines: 5,
                      cursorColor: Colors.brown,
                      style: TextStyle(
                        color:
                            dialogIsDark
                                ? Colors.white
                                : const Color(0xFF2F211D),
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            "Write what was fixed, or mention photo proof/details",
                        hintStyle: TextStyle(
                          color:
                              dialogIsDark
                                  ? Colors.white54
                                  : const Color(
                                    0xFF6B5650,
                                  ).withValues(alpha: 0.72),
                        ),
                        filled: true,
                        fillColor:
                            dialogIsDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(
                                  0xFFFFFBF2,
                                ).withValues(alpha: 0.78),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color:
                                dialogIsDark
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : Colors.brown.withValues(alpha: 0.22),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await ImagePicker().pickMultiImage(
                            imageQuality: 78,
                            maxWidth: 1600,
                          );
                          if (picked.isEmpty) return;
                          for (final image in picked) {
                            proofImages.add(await image.readAsBytes());
                          }
                          setDialogState(() {});
                        },
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text("Add proof photos"),
                      ),
                    ),
                    if (proofImages.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 70,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: proofImages.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(width: 8),
                          itemBuilder:
                              (context, index) => Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      proofImages[index],
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap:
                                          () => setDialogState(
                                            () => proofImages.removeAt(index),
                                          ),
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.65,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                FilledButton.icon(
                  onPressed: () {
                    final value = controller.text.trim();
                    if (value.length < 6 && proofImages.isEmpty) return;
                    Navigator.of(dialogContext).pop(value);
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Resolve"),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    if (proof == null) return true;

    return FirestoreService().resolvePostWithProof(
      postId,
      proof.trim().isEmpty ? "Photo proof attached" : proof.trim(),
      proofImages: proofImages,
    );
  }

  Widget _statusBadge(Color statusColor, {bool showArrow = false}) {
    return TweenAnimationBuilder<double>(
      key: ValueKey("$postId-status-$status"),
      tween: Tween(begin: 1.08, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
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

class _FullPostScreen extends StatefulWidget {
  final String postId;

  const _FullPostScreen({required this.postId});

  @override
  State<_FullPostScreen> createState() => _FullPostScreenState();
}

class _FullPostScreenState extends State<_FullPostScreen> {
  bool showComments = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF0EDE5),
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(child: GlowingBackgroundLogo(isDark: isDark)),
          ),
          SafeArea(
            bottom: false,
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance
                      .collection("posts")
                      .doc(widget.postId)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: PulseLoader(size: 52));
                }

                final data = snapshot.data?.data();
                if (data == null) {
                  return Center(
                    child: Text(
                      "Post not found",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: Row(
                          children: [
                            IconButton.filledTonal(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: _RgbGlowText(
                                "Full Post",
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: PostCard(
                          index: 0,
                          postId: widget.postId,
                          user: data["userName"] ?? "Unknown User",
                          ownerId: data["userId"] ?? "",
                          text: data["text"] ?? "",
                          location: data["location"] ?? "",
                          category: data["category"] ?? "General",
                          urgency: data["urgency"] ?? "Medium",
                          imageUrl: data["imageUrl"],
                          imageUrls: _imageUrlsFromData(data),
                          imagePath: data["imagePath"],
                          status: data["status"] ?? "Pending",
                          editedOnce: data["editedOnce"] ?? false,
                          createdAt: data["createdAt"],
                          likes: (data["likedBy"] ?? []).length,
                          likedBy: List<String>.from(
                            data["likedBy"] as List? ?? [],
                          ),
                          commentsCount: data["commentsCount"] ?? 0,
                          isLikedByMe: FirestoreService().isLikedByMe(data),
                          isDark: isDark,
                          onCommentTap:
                              () => setState(() {
                                showComments = !showComments;
                              }),
                        ),
                      ),
                    ),
                    if (showComments) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 860),
                          child: _InlineCommentsSection(
                            postId: widget.postId,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineCommentsSection extends StatefulWidget {
  final String postId;
  final bool isDark;

  const _InlineCommentsSection({required this.postId, required this.isDark});

  @override
  State<_InlineCommentsSection> createState() => _InlineCommentsSectionState();
}

class _InlineCommentsSectionState extends State<_InlineCommentsSection> {
  final controller = TextEditingController();
  final commentImages = <Uint8List>[];
  bool sending = false;
  String? replyToCommentId;
  String? replyToUserName;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = controller.text.trim();
    if ((text.isEmpty && commentImages.isEmpty) || sending) return;

    setState(() => sending = true);
    final ok = await FirestoreService().addComment(
      widget.postId,
      text,
      replyToCommentId: replyToCommentId,
      replyToUserName: replyToUserName,
      imageBytesList: commentImages,
    );
    if (!mounted) return;
    if (ok) {
      controller.clear();
      commentImages.clear();
      replyToCommentId = null;
      replyToUserName = null;
    }
    setState(() => sending = false);
  }

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage(
      imageQuality: 78,
      maxWidth: 1600,
    );
    if (picked.isEmpty) return;

    for (final image in picked) {
      commentImages.add(await image.readAsBytes());
    }
    if (mounted) setState(() {});
  }

  void _showInlineImageFullScreen(BuildContext context, String url) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close image",
      barrierColor: Colors.black,
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final showCivicMateSuggestion = _shouldShowCivicMateSuggestion(controller);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xFF101010).withValues(alpha: 0.78)
                : const Color(0xFFFFFCF5).withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.brown.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Comments",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.brown.shade900,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirestoreService().getComments(widget.postId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(child: PulseLoader(size: 36)),
                );
              }

              final comments = snapshot.data?.docs ?? [];
              if (comments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "No comments yet",
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              return Column(
                children:
                    comments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final doc = entry.value;
                      final data = doc.data() as Map<String, dynamic>;
                      final repliedTo =
                          (data["replyToUserName"] ?? "").toString();
                      final commentImageUrls = _imageUrlsFromData(data);
                      final canDeleteComment =
                          FirebaseAuth.instance.currentUser?.uid ==
                          data["userId"];
                      return TweenAnimationBuilder<double>(
                        key: ValueKey(doc.id),
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 180 + (index * 18)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          final opacity = value.clamp(0.0, 1.0).toDouble();
                          return Opacity(
                            opacity: opacity,
                            child: Transform.translate(
                              offset: Offset(0, 8 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Colors.white.withValues(alpha: 0.045)
                                    : Colors.white.withValues(alpha: 0.42),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data["userName"] ?? "User",
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? Colors.white
                                          : Colors.brown.shade800,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (repliedTo.isNotEmpty) ...[
                                Text(
                                  "Replying to $repliedTo",
                                  style: TextStyle(
                                    color:
                                        isDark
                                            ? const Color(0xFFD7B6A4)
                                            : Colors.brown.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                data["text"] ?? "",
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                              if (commentImageUrls.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 110,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: commentImageUrls.length,
                                    separatorBuilder:
                                        (context, index) =>
                                            const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      final url = commentImageUrls[index];
                                      return GestureDetector(
                                        onTap:
                                            () => _showInlineImageFullScreen(
                                              context,
                                              url,
                                            ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            url,
                                            width: 120,
                                            height: 110,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      foregroundColor: Colors.brown,
                                    ),
                                    onPressed: () {
                                      final name =
                                          (data["userName"] ?? "User")
                                              .toString();
                                      replyToCommentId = doc.id;
                                      replyToUserName = name;
                                      if (controller.text.trim().isEmpty) {
                                        controller.text = "@$name ";
                                        controller.selection =
                                            TextSelection.collapsed(
                                              offset: controller.text.length,
                                            );
                                      }
                                      setState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.reply_rounded,
                                      size: 17,
                                    ),
                                    label: const Text("Reply"),
                                  ),
                                  if (canDeleteComment)
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      tooltip: "Delete comment",
                                      onPressed: () async {
                                        final ok = await FirestoreService()
                                            .deleteComment(
                                              widget.postId,
                                              doc.id,
                                            );
                                        if (!ok && context.mounted) {
                                          TopSnackBar.show(
                                            context,
                                            FirestoreService.lastError ??
                                                "Could not delete comment",
                                            color: Colors.redAccent,
                                            icon: Icons.error_outline,
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.brown,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          if (replyToUserName != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.brown.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.reply_rounded,
                    size: 18,
                    color: Colors.brown,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Replying to $replyToUserName",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.brown.shade900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      replyToCommentId = null;
                      replyToUserName = null;
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (showCivicMateSuggestion) ...[
            _civicMateCommentSuggestion(isDark, () {
              _insertCivicMateMention(controller);
              setState(() {});
            }),
            const SizedBox(height: 8),
          ],
          if (commentImages.isNotEmpty) ...[
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: commentImages.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          commentImages[index],
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap:
                              () =>
                                  setState(() => commentImages.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              IconButton(
                tooltip: "Attach images",
                onPressed: _pickImages,
                icon: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.brown,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 3,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF2F211D),
                    fontWeight: FontWeight.w600,
                  ),
                  cursorColor: Colors.brown,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Add a comment",
                    hintStyle: TextStyle(
                      color:
                          isDark
                              ? Colors.white54
                              : const Color(0xFF6B5650).withValues(alpha: 0.72),
                    ),
                    filled: true,
                    fillColor:
                        isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFFFFBF2).withValues(alpha: 0.74),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color:
                            isDark
                                ? Colors.white.withValues(alpha: 0.16)
                                : Colors.brown.withValues(alpha: 0.20),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color:
                            isDark
                                ? Colors.white.withValues(alpha: 0.16)
                                : Colors.brown.withValues(alpha: 0.20),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color:
                            isDark
                                ? const Color(
                                  0xFFD7B6A4,
                                ).withValues(alpha: 0.62)
                                : Colors.brown.withValues(alpha: 0.52),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: sending ? null : _send,
                style: IconButton.styleFrom(backgroundColor: Colors.brown),
                icon:
                    sending
                        ? const PulseLoader(
                          size: 18,
                          color: Colors.white,
                          showLogo: false,
                        )
                        : const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

bool _shouldShowCivicMateSuggestion(TextEditingController controller) {
  final text = controller.text.toLowerCase();
  return text.contains("@") && !text.contains("@civicmate");
}

void _insertCivicMateMention(TextEditingController controller) {
  final text = controller.text;
  final lastAt = text.lastIndexOf("@");
  final replacement =
      lastAt >= 0
          ? "${text.substring(0, lastAt)}@CivicMate "
          : "$text @CivicMate ";

  controller.value = TextEditingValue(
    text: replacement,
    selection: TextSelection.collapsed(offset: replacement.length),
  );
}

Widget _civicMateCommentSuggestion(bool isDark, VoidCallback onTap) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.brown.withValues(alpha: 0.18)
                  : const Color(0xFFFFFBF2).withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                isDark
                    ? const Color(0xFFD7B6A4).withValues(alpha: 0.32)
                    : const Color(0xFF5A332B).withValues(alpha: 0.34),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.brown),
            SizedBox(width: 6),
            Text(
              "@CivicMate",
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RgbGlowText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  const _RgbGlowText(
    this.text, {
    required this.fontSize,
    required this.fontWeight,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFF2E7DE) : Colors.brown.shade900;
    final glowColor =
        isDark ? const Color(0x77D7B6A4) : Colors.brown.withValues(alpha: 0.24);

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        shadows: [
          Shadow(color: glowColor, blurRadius: 14),
          Shadow(color: glowColor.withValues(alpha: 0.55), blurRadius: 24),
        ],
      ),
    );
  }
}

class _RgbScreenEdgeGlow extends StatefulWidget {
  final Widget child;

  const _RgbScreenEdgeGlow({required this.child});

  @override
  State<_RgbScreenEdgeGlow> createState() => _RgbScreenEdgeGlowState();
}

class _RgbScreenEdgeGlowState extends State<_RgbScreenEdgeGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(child: child!),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _RgbEdgeGlowPainter(
                    progress: _controller.value,
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _RgbEdgeGlowPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  const _RgbEdgeGlowPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(12),
      const Radius.circular(32),
    );
    final pulse = 0.62 + (0.16 * math.sin(progress * math.pi * 2).abs());

    final edge =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..color =
              isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.brown.withValues(alpha: 0.10);

    canvas.drawRRect(rrect, edge);

    final borderPath = ui.Path()..addRRect(rrect);
    final sweepPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            startAngle: 0,
            endAngle: math.pi * 2,
            transform: GradientRotation(progress * math.pi * 2),
            colors: [
              Colors.transparent,
              (isDark ? const Color(0xFFD7B6A4) : Colors.brown).withValues(
                alpha: 0.00,
              ),
              (isDark ? const Color(0xFFD7B6A4) : Colors.brown).withValues(
                alpha: 0.24 * pulse,
              ),
              Colors.transparent,
            ],
            stops: const [0.0, 0.42, 0.50, 0.62],
          ).createShader(rect);

    final softPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
          ..shader = sweepPaint.shader;

    canvas.drawPath(borderPath, softPaint);
    canvas.drawPath(borderPath, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _RgbEdgeGlowPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatMessage {
  final String text;
  final bool fromUser;

  const _AiChatMessage({required this.text, required this.fromUser});
}

class _AiChatScreenState extends State<AiChatScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  final gemini = GeminiService();
  final messages = <_AiChatMessage>[
    const _AiChatMessage(
      text:
          "Hi, I am CivicMate. I can help you write better reports, summarize civic issues, and suggest what details to include.",
      fromUser: false,
    ),
  ];

  bool isSending = false;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? quickPrompt]) async {
    final text = (quickPrompt ?? controller.text).trim();
    if (text.isEmpty || isSending) return;

    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);

    setState(() {
      isSending = true;
      messages.add(_AiChatMessage(text: text, fromUser: true));
      controller.clear();
    });
    _scrollToBottom();

    final reply = await gemini.ask(text);

    if (!mounted) return;
    setState(() {
      isSending = false;
      messages.add(_AiChatMessage(text: reply, fromUser: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final quickPrompts = [
      "Help me write a clear road damage report",
      "What details should I add to a garbage complaint?",
      "Summarize my issue in one formal sentence",
      "Decide urgency for this civic issue",
      "Draft a polite complaint message",
      "Make my report title clearer",
    ];

    return _RgbScreenEdgeGlow(
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(child: GlowingBackgroundLogo(isDark: isDark)),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 20, 18, keyboardOpen ? 14 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (Navigator.of(context).canPop())
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton.filledTonal(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                            ),
                          const _RgbGlowText(
                            "CivicMate",
                            fontSize: 31,
                            fontWeight: FontWeight.w900,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!keyboardOpen && messages.length == 1 && !isSending) ...[
                    const SizedBox(height: 14),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 640;
                            final chipWidth =
                                compact
                                    ? constraints.maxWidth < 380
                                        ? constraints.maxWidth
                                        : (constraints.maxWidth - 8) / 2
                                    : (constraints.maxWidth - 16) / 3;

                            final promptChips =
                                quickPrompts.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final prompt = entry.value;
                                  return SizedBox(
                                    width: chipWidth,
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0, end: 1),
                                      duration: Duration(
                                        milliseconds: 260 + (index * 42),
                                      ),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, child) {
                                        final opacity =
                                            value.clamp(0.0, 1.0).toDouble();
                                        return Opacity(
                                          opacity: opacity,
                                          child: Transform.translate(
                                            offset: Offset(0, 8 * (1 - value)),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: PressableScale(
                                        onTap: () => _send(prompt),
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            minHeight: 44,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 13,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isDark
                                                    ? Colors.white.withValues(
                                                      alpha: 0.055,
                                                    )
                                                    : const Color(
                                                      0xFFFFFBF2,
                                                    ).withValues(alpha: 0.72),
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              width: 1.1,
                                              color:
                                                  isDark
                                                      ? Colors.white.withValues(
                                                        alpha: 0.20,
                                                      )
                                                      : const Color(
                                                        0xFF5A332B,
                                                      ).withValues(alpha: 0.34),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: isDark ? 0.12 : 0.05,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            prompt,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:
                                                  isDark
                                                      ? Colors.white70
                                                      : const Color(0xFF2F211D),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              height: 1.18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList();

                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: promptChips,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: keyboardOpen ? 8 : 12),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final introOnly =
                                messages.length == 1 && !isSending;

                            return ListView.builder(
                              controller: scrollController,
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: EdgeInsets.only(
                                top:
                                    introOnly
                                        ? constraints.maxHeight * 0.36
                                        : 0,
                                bottom: 8,
                              ),
                              itemCount: messages.length + (isSending ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == messages.length) {
                                  return _messageBubble(
                                    "Thinking...",
                                    false,
                                    isDark,
                                    loading: true,
                                  );
                                }

                                final message = messages[index];
                                return _messageBubble(
                                  message.text,
                                  message.fromUser,
                                  isDark,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Colors.white.withValues(alpha: 0.055)
                                    : const Color(
                                      0xFFFFFBF2,
                                    ).withValues(alpha: 0.66),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              width: 1.35,
                              color:
                                  isDark
                                      ? Colors.white.withValues(alpha: 0.22)
                                      : const Color(
                                        0xFF5A332B,
                                      ).withValues(alpha: 0.50),
                            ),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.brown.withValues(alpha: 0.08),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  minLines: 1,
                                  maxLines: 4,
                                  cursorColor: Colors.brown,
                                  style: TextStyle(
                                    color:
                                        isDark
                                            ? Colors.white
                                            : const Color(0xFF2F211D),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: "Ask CivicMate",
                                    hintStyle: TextStyle(
                                      color:
                                          isDark
                                              ? Colors.white54
                                              : const Color(
                                                0xFF6B5650,
                                              ).withValues(alpha: 0.72),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 14,
                                    ),
                                  ),
                                  onSubmitted: (_) => _send(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(22),
                                    onTap: isSending ? null : () => _send(),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 160,
                                      ),
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.brown.withValues(
                                          alpha: isSending ? 0.46 : 0.88,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.brown.withValues(
                                              alpha: isDark ? 0.26 : 0.16,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child:
                                          isSending
                                              ? const Center(
                                                child: PulseLoader(
                                                  size: 20,
                                                  color: Colors.white,
                                                  showLogo: false,
                                                ),
                                              )
                                              : const Icon(
                                                Icons.send_rounded,
                                                color: Colors.white,
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(
    String text,
    bool fromUser,
    bool isDark, {
    bool loading = false,
  }) {
    return TweenAnimationBuilder<double>(
      key: ValueKey("message-${fromUser ? 'me' : 'ai'}-$text-$loading"),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final opacity = value.clamp(0.0, 1.0).toDouble();
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: 0.96 + (0.04 * value),
            alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(
                (fromUser ? 18 : -18) * (1 - value),
                10 * (1 - value),
              ),
              child: child,
            ),
          ),
        );
      },
      child: Align(
        alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color:
                fromUser
                    ? Colors.brown.withValues(alpha: 0.86)
                    : isDark
                    ? const Color(0xFF141414).withValues(alpha: 0.92)
                    : const Color(0xFFFFFCF5).withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              width: 1.15,
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.16)
                      : const Color(0xFF5A332B).withValues(alpha: 0.32),
            ),
          ),
          child:
              loading
                  ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PulseLoader(
                        size: 18,
                        color: Colors.brown,
                        showLogo: false,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        text,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                  : Text(
                    fromUser ? text : _cleanAiDisplayText(text),
                    style: TextStyle(
                      color:
                          fromUser
                              ? Colors.white
                              : isDark
                              ? Colors.white70
                              : const Color(0xFF2F211D),
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
        ),
      ),
    );
  }

  String _cleanAiDisplayText(String value) {
    return value
        .replaceAllMapped(
          RegExp(r'\*\*(.*?)\*\*'),
          (match) => match.group(1) ?? "",
        )
        .replaceAll(RegExp(r'#{1,6}\s*'), '')
        .replaceAll('**', '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
