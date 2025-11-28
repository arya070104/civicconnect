import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TopSnackBar {
  static OverlayEntry? _currentEntry; // prevents stacking multiple snackbars

  static void show(
    BuildContext context,
    String message, {
    Color? color,
    Duration duration = const Duration(seconds: 2),
    bool vibrate = true,
    IconData? icon,
  }) {
    // Remove any old active snackbar
    _currentEntry?.remove();
    _currentEntry = null;

    final brightness = Theme.of(context).brightness;

    // Auto color based on theme with translucent blur
    final bgColor =
        color ??
        (brightness == Brightness.dark
            ? Colors.white.withOpacity(0.10)
            : Colors.black.withOpacity(0.45));

    // Vibration feedback
    if (vibrate) HapticFeedback.mediumImpact();

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => _TopSnackBarWidget(
            message: message,
            color: bgColor,
            textColor: Colors.white,
            icon: icon,
          ),
    );

    _currentEntry = overlayEntry;
    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
      if (_currentEntry == overlayEntry) _currentEntry = null;
    });
  }
}

class _TopSnackBarWidget extends StatefulWidget {
  final String message;
  final Color color;
  final Color textColor;
  final IconData? icon;

  const _TopSnackBarWidget({
    required this.message,
    required this.color,
    required this.textColor,
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

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.4),
      end: const Offset(0, 0.1),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

    fadeAnimation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    controller.forward();
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.20),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(widget.icon, color: Colors.white, size: 20),
                      ),
                    Flexible(
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
