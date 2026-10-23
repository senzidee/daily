import 'package:flutter/material.dart';

class AppRadialBackground extends StatelessWidget {
  const AppRadialBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.85, -0.95),
          radius: 1.5,
          colors: [
            scheme.primary.withValues(alpha: isDark ? 0.20 : 0.10),
            scheme.surface,
          ],
        ),
      ),
      child: child,
    );
  }
}
