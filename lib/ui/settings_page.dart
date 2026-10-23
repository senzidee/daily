import 'package:flutter/material.dart';

import 'widgets/app_empty_state.dart';
import 'widgets/app_radial_background.dart';

/// Management surface for everything that is configured rather than logged.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  /// Key for the page title, used by widget tests.
  static const titleKey = Key('settings-title');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings', key: titleKey)),
      body: const AppRadialBackground(
        child: AppEmptyState(
          icon: Icons.tune,
          message: 'Nothing to configure yet',
        ),
      ),
    );
  }
}
