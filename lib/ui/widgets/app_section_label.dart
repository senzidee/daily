import 'package:flutter/material.dart';

class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 1.1);

    return Row(
      children: [
        Expanded(child: Text(text.toUpperCase(), style: style)),
        ?trailing,
      ],
    );
  }
}
