import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/firestore_services.dart';
import '../utils/top_snackbar.dart';
import '../utils/theme_controller.dart';
import '../widgets/glowing_background_logo.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/pulse_loader.dart';

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
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .get();

    if (!mounted) return;

    if (doc.exists) {
      setState(() {
        name = doc.data()?["name"] ?? "User";
        photoUrl = doc.data()?["photoUrl"] ?? "";
      });
    } else {
      setState(() => name = user!.email?.split("@")[0] ?? "User");
    }
  }

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "My Profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _profileCard(isDark),
                  const SizedBox(height: 18),
                  _statsSection(isDark),
                  const SizedBox(height: 24),
                  _darkModeOption(isDark),
                  const SizedBox(height: 12),
                  buildButton(
                    icon: Icons.article_outlined,
                    text: "My Reported Issues",
                    color: Colors.brown,
                    onTap: () => _showMyIssuesSheet(context),
                  ),
                  const SizedBox(height: 12),
                  buildButton(
                    icon: Icons.refresh_rounded,
                    text: "Refresh Profile Data",
                    color: Colors.brown,
                    onTap: () async {
                      await loadUserData();
                      if (!context.mounted) return;
                      TopSnackBar.show(
                        context,
                        "Profile refreshed",
                        color: Colors.green,
                        icon: Icons.check_circle_outline,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  buildButton(
                    icon: Icons.lightbulb_outline,
                    text: "Civic Tips",
                    color: Colors.brown,
                    onTap: () => _showTipsSheet(context),
                  ),
                  const SizedBox(height: 12),
                  buildButton(
                    icon: Icons.logout,
                    text: "Logout",
                    color: Colors.redAccent,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, "/login");
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Color _accentColor(bool isDark) =>
      isDark ? const Color(0xFFD7B6A4) : Colors.brown;

  Widget _darkModeOption(bool isDark) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, child) {
        final enabled = mode == ThemeMode.dark;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.055)
                    : Colors.white.withValues(alpha: 0.20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dark Mode",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      enabled ? "Enabled across app" : "Light theme active",
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PressableScale(
                onTap: () {
                  final next = enabled ? ThemeMode.light : ThemeMode.dark;
                  appThemeMode.value = next;
                  HapticFeedback.selectionClick();
                  TopSnackBar.show(
                    context,
                    next == ThemeMode.dark
                        ? "Dark mode enabled"
                        : "Light mode enabled",
                    color: _accentColor(isDark),
                    icon:
                        next == ThemeMode.dark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: 54,
                  height: 34,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color:
                        isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : Colors.white.withValues(alpha: 0.36),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: isDark ? 0.14 : 0.42,
                      ),
                    ),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    alignment:
                        enabled ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            enabled
                                ? const Color(0xFFD7B6A4)
                                : Colors.brown,
                      ),
                      child: Icon(
                        enabled
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _profileCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.055)
                : Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 25),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: isDark ? Colors.white12 : Colors.brown.shade200,
            backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child:
                photoUrl.isEmpty
                    ? Icon(
                      Icons.person,
                      size: 55,
                      color: _accentColor(isDark),
                    )
                    : null,
          ),
          const SizedBox(height: 16),
          Text(
            name.isEmpty ? "User" : name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.brown.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user?.email ?? "",
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.brown.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsSection(bool isDark) {
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("posts")
              .where("userId", isEqualTo: user!.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: PulseLoader(size: 42));
        }

        final docs = snapshot.data?.docs ?? [];
        final total = docs.length;
        final resolved =
            docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data["status"] == "Resolved";
            }).length;
        final inProgress =
            docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data["status"] == "In Progress";
            }).length;

        return Row(
          children: [
            _statCard("Total", total.toString(), Icons.list_alt, isDark),
            const SizedBox(width: 10),
            _statCard("Active", inProgress.toString(), Icons.timelapse, isDark),
            const SizedBox(width: 10),
            _statCard(
              "Resolved",
              resolved.toString(),
              Icons.check_circle_outline,
              isDark,
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.32),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        ),
        child: Column(
          children: [
            Icon(icon, color: _accentColor(isDark), size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.brown.shade900,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMyIssuesSheet(BuildContext context) {
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          height: MediaQuery.of(context).size.height * 0.70,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF101010) : const Color(0xFFFFFCF5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "My Reported Issues",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.brown.shade900,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection("posts")
                          .where("userId", isEqualTo: user!.uid)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: PulseLoader(size: 42));
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          "You have not reported any issues yet",
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: docs.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final status = data["status"] ?? "Pending";

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap:
                              () => _showIssueDetailSheet(
                                context,
                                docs[index].id,
                                data,
                              ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.brown.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.report_problem_outlined,
                                  color: _accentColor(isDark),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data["text"] ?? "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatPostedTime(data["createdAt"]),
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.white54
                                                  : Colors.black45,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  status,
                                  style: TextStyle(
                                    color: _statusColor(status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color:
                                      isDark ? Colors.white38 : Colors.black38,
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
            ],
          ),
        );
      },
    );
  }

  void _showIssueDetailSheet(
    BuildContext context,
    String postId,
    Map<String, dynamic> data,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final status = data["status"] ?? "Pending";
        final imageUrl = data["imageUrl"] as String? ?? "";

        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF101010) : const Color(0xFFFFFCF5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data["userName"] ?? name,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.brown.shade900,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatPostedTime(data["createdAt"]),
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: "Delete post",
                    onPressed: () => _confirmDeletePost(
                      context,
                      postId,
                      data["imagePath"] as String?,
                    ),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _statusBadge(status),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["text"] ?? "",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18,
                          height: 1.35,
                        ),
                      ),
                      if (imageUrl.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeletePost(
    BuildContext context,
    String postId,
    String? imagePath,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor:
              isDark ? const Color(0xFF151515) : const Color(0xFFFFFCF5),
          title: Text(
            "Delete post?",
            style: TextStyle(color: isDark ? Colors.white : Colors.brown),
          ),
          content: Text(
            "This will remove the post, its photo, and its comments.",
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
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
      Navigator.of(context).pop();
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

  Widget _statusBadge(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "In Progress":
        return Colors.orange.shade700;
      case "Resolved":
        return Colors.green.shade700;
      case "Pending":
      default:
        return Colors.red.shade600;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
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

  void _showTipsSheet(BuildContext context) {
    final tips = [
      "Add a clear photo so others can verify the issue quickly.",
      "Use location and hashtags to make reports easier to find.",
      "Update the issue status when work starts or gets resolved.",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF101010) : const Color(0xFFFFFCF5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Civic Tips",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.brown.shade900,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              ...tips.map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.brown,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            height: 1.3,
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
      },
    );
  }

  Widget buildButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayColor =
        color == Colors.brown && isDark ? _accentColor(true) : color;

    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.055)
                  : Colors.white.withValues(alpha: 0.20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: displayColor, size: 26),
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: displayColor,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: displayColor),
          ],
        ),
      ),
    );
  }
}
