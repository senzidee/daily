import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static const Color seed = Colors.deepPurple;

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppTypography.family,
    );
    final textTheme = AppTypography.textTheme(base.textTheme);
    final palette = brightness == Brightness.dark
        ? AppPalette.dark
        : AppPalette.light;

    final roundedSm = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
    );
    final roundedMd = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );
    final roundedLg = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    );
    final roundedXl = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.xl),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide.none,
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: AppTypography.textTheme(base.primaryTextTheme),
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      appBarTheme: AppBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: roundedLg,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        shape: roundedMd,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        elevation: 0,
        highlightElevation: 0,
        shape: const StadiumBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: roundedXl,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: scheme.onSurfaceVariant,
        collapsedIconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        collapsedTextColor: scheme.onSurface,
        shape: roundedMd,
        collapsedShape: roundedMd,
        childrenPadding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.sm,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: roundedSm,
      ),
      extensions: [palette],
    );
  }
}
