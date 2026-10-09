import 'package:flutter/material.dart';

class NeuSurface extends StatelessWidget {
  const NeuSurface({
    super.key,
    required this.child,
    this.radius = 22,
    this.padding = const EdgeInsets.all(18),
    this.intensity = 1.0,
    this.color,
    this.borderColor,
    this.height,
    this.width,
    this.onTap,
    this.onLongPress,
    this.pressed = false,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double intensity;
  final Color? color;
  final Color? borderColor;
  final double? height;
  final double? width;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final base = color ?? theme.scaffoldBackgroundColor;
    final lightShadow = (isDark ? Colors.white : Colors.white).withValues(
      alpha: 0.55 * intensity,
    );
    final darkShadow = (isDark ? Colors.black : const Color(0xFF283618))
        .withValues(alpha: isDark ? 0.55 * intensity : 0.18 * intensity);

    final offset = pressed ? 1.0 : 6.0 * intensity;
    final blur = pressed ? 3.0 : 14.0 * intensity;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(radius),
        splashColor: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        highlightColor: theme.colorScheme.onSurface.withValues(alpha: 0.02),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: height,
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(radius),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!, width: 1),
            boxShadow: [
              BoxShadow(
                color: lightShadow,
                offset: Offset(-offset, -offset),
                blurRadius: blur,
              ),
              BoxShadow(
                color: darkShadow,
                offset: Offset(offset, offset),
                blurRadius: blur,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class NeuIconButton extends StatelessWidget {
  const NeuIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.radius = 18,
    this.padding = const EdgeInsets.all(10),
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final button = NeuSurface(
      radius: radius,
      padding: padding,
      onTap: onPressed,
      child: Icon(
        icon,
        size: 20,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
