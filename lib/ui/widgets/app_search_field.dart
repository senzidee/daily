import 'package:flutter/material.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Clear search',
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                    },
                  ),
          ),
        );
      },
    );
  }
}
