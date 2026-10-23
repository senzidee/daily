import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Rounded surface used for entries, meals, metrics and summary sections.
///
/// Optionally takes a [gradient] (for hero cards) or an [accent] border.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.accent,
    this.gradient,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? accent;
  final List<Color>? gradient;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadius.lg);

    Widget body = Padding(padding: padding ?? AppSpacing.card, child: child);

    if (gradient != null) {
      body = Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient!,
          ),
        ),
        child: body,
      );
    }

    if (accent != null) {
      body = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: accent!.withValues(alpha: 0.4)),
        ),
        child: body,
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: gradient == null
            ? scheme.surfaceContainerLow
            : Colors.transparent,
        elevation: 0,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? body : InkWell(onTap: onTap, child: body),
      ),
    );
  }
}
