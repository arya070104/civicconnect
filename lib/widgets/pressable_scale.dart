import 'package:flutter/material.dart';

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double pressedScale;
  final bool glow;
  final Color? glowColor;

  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.92,
    this.glow = true,
    this.glowColor,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.glowColor ?? Colors.brown;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow:
                widget.glow && (_hovered || _pressed)
                    ? [
                      BoxShadow(
                        color: glowColor.withValues(
                          alpha: _pressed ? 0.34 : 0.22,
                        ),
                        blurRadius: _pressed ? 16 : 22,
                        spreadRadius: _pressed ? 1 : 2,
                      ),
                    ]
                    : [],
          ),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOutCubic,
            scale: _pressed ? widget.pressedScale : 1,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
