import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TopSnackBar {
  static OverlayEntry? _currentEntry; // prevents stacking multiple snackbars
  static bool _isCurrentEntryMounted = false;

  static void show(
    BuildContext context,
    String message, {
    Color? color,
    Duration duration = const Duration(seconds: 2),
    bool vibrate = true,
    IconData? icon,
  }) {
    // Remove any old active snackbar
    _removeCurrentEntry();
    _currentEntry = null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = color ?? Colors.brown;
    final bgColor =
        isDark
            ? const Color(0xFF151515).withValues(alpha: 0.94)
            : const Color(0xFFFFFCF5).withValues(alpha: 0.92);

    // Vibration feedback
    if (vibrate) HapticFeedback.mediumImpact();

    final overlay = Overlay.of(context);
    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder:
          (context) => _TopSnackBarWidget(
            message: message,
            color: bgColor,
            accentColor: accentColor,
            textColor: isDark ? Colors.white : const Color(0xFF4B1E18),
            icon: icon,
            duration: duration,
            onDismissed: () {
              if (_currentEntry == overlayEntry) {
                _currentEntry?.remove();
                _currentEntry = null;
                _isCurrentEntryMounted = false;
              }
            },
          ),
    );

    _currentEntry = overlayEntry;
    _isCurrentEntryMounted = true;
    overlay.insert(overlayEntry);
  }

  static void _removeCurrentEntry() {
    if (_currentEntry == null || !_isCurrentEntryMounted) return;

    _currentEntry!.remove();
    _currentEntry = null;
    _isCurrentEntryMounted = false;
  }
}

class _TopSnackBarWidget extends StatefulWidget {
  final String message;
  final Color color;
  final Color accentColor;
  final Color textColor;
  final IconData? icon;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopSnackBarWidget({
    required this.message,
    required this.color,
    required this.accentColor,
    required this.textColor,
    required this.duration,
    required this.onDismissed,
    this.icon,
  });

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 220),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    fadeAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    scaleAnimation = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    );

    controller.forward();
    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await controller.reverse();
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 10;

    return Positioned(
      top: top,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: widget.accentColor.withValues(alpha: 0.22),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.18),
                          blurRadius: 24,
                          spreadRadius: 1,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon ?? Icons.notifications_active_outlined,
                            color: widget.accentColor,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.message,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: widget.textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
