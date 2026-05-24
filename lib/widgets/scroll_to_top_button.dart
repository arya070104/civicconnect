import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScrollToTopButton extends StatefulWidget {
  final ScrollController controller;
  final bool isDark;
  final bool visible;
  final double bottom;
  final double right;
  final String heroTag;
  final double showAfter;

  const ScrollToTopButton({
    super.key,
    required this.controller,
    required this.isDark,
    required this.heroTag,
    this.visible = true,
    this.bottom = 120,
    this.right = 20,
    this.showAfter = 360,
  });

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncVisibility);
  }

  @override
  void didUpdateWidget(covariant ScrollToTopButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_syncVisibility);
    widget.controller.addListener(_syncVisibility);
    _syncVisibility();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncVisibility);
    super.dispose();
  }

  void _syncVisibility() {
    if (!widget.controller.hasClients) return;
    final next = widget.controller.offset > widget.showAfter;
    if (next != _show && mounted) setState(() => _show = next);
  }

  Future<void> _goTop() async {
    if (!widget.controller.hasClients) return;
    HapticFeedback.selectionClick();
    setState(() => _show = false);
    await widget.controller.animateTo(
      0,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveShow = widget.visible && _show;
    final bg =
        widget.isDark ? const Color(0xFF15100E) : const Color(0xFF6B4439);
    final fg = widget.isDark ? const Color(0xFFE8C7B6) : Colors.white;

    return Positioned(
      right: widget.right,
      bottom: widget.bottom,
      child: IgnorePointer(
        ignoring: !effectiveShow,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          scale: effectiveShow ? 1 : 0.82,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 140),
            opacity: effectiveShow ? 1 : 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: widget.isDark ? 0.42 : 0.16,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton.small(
                heroTag: widget.heroTag,
                elevation: 0,
                backgroundColor: bg,
                foregroundColor: fg,
                shape: CircleBorder(
                  side: BorderSide(
                    color:
                        widget.isDark
                            ? const Color(0xFFE8C7B6).withValues(alpha: 0.30)
                            : Colors.white.withValues(alpha: 0.22),
                    width: 1.2,
                  ),
                ),
                onPressed: _goTop,
                child: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
