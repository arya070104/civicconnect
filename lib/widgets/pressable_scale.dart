import 'package:flutter/material.dart';

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double pressedScale;
  final bool glow;
  final Color? glowColor;
  final bool hoverScale;

  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.92,
    this.glow = true,
    this.glowColor,
    this.hoverScale = true,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;
  bool _hovered = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = widget.glowColor ?? Colors.brown;
    final targetScale =
        _pressed ? widget.pressedScale : (_hovered && widget.hoverScale ? 1.035 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) {
        setState(() {
          _hovered = false;
          _pressed = false;
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: targetScale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow:
                  widget.glow && (_hovered || _pressed)
                      ? [
                        BoxShadow(
                          color: effectiveGlowColor.withValues(alpha: 0.20),
                          blurRadius: _pressed ? 12 : 20,
                          spreadRadius: _pressed ? 0 : 1,
                        ),
                      ]
                      : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
