import 'package:flutter/material.dart';

/// Tokens visuais do design system InOutWare.
///
/// Espelha `colors_and_type.css` 1:1 e expõe o tema M3 derivado do seed
/// `#0E2238`. Mantenha estes valores como fonte única — os módulos consomem
/// estes tokens via `IwColors`, `IwSpacing`, `IwRadius` etc.
class IwColors {
  IwColors._();

  // Primary — navy
  static const Color primary = Color(0xFF395E83);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD3E4FF);
  static const Color onPrimaryContainer = Color(0xFF001D33);
  static const Color primaryDeep = Color(0xFF0E2238);
  static const Color primaryFixed = Color(0xFFC9E2FF);

  // Secondary — slate
  static const Color secondary = Color(0xFF535F70);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD7E3F8);
  static const Color onSecondaryContainer = Color(0xFF101C2B);

  // Tertiary — muted plum
  static const Color tertiary = Color(0xFF6B5778);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFF2DAFF);
  static const Color onTertiaryContainer = Color(0xFF251431);

  // Surfaces
  static const Color surface = Color(0xFFFDFCFF);
  static const Color surfaceDim = Color(0xFFDCDBE0);
  static const Color surfaceBright = Color(0xFFFDFCFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F6FA);
  static const Color surfaceContainer = Color(0xFFF0F1F4);
  static const Color surfaceContainerHigh = Color(0xFFEAEBEF);
  static const Color surfaceContainerHighest = Color(0xFFE4E5E9);
  static const Color onSurface = Color(0xFF1A1C1E);
  static const Color onSurfaceVariant = Color(0xFF43474E);
  static const Color surfaceVariant = Color(0xFFDFE3EB);
  static const Color outline = Color(0xFF74777F);
  static const Color outlineVariant = Color(0xFFC4C6CF);

  // Semantic
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  static const Color success = Color(0xFF1F7A4D);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFB6F2C8);
  static const Color onSuccessContainer = Color(0xFF002111);

  static const Color warning = Color(0xFFB36500);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFDDB4);
  static const Color onWarningContainer = Color(0xFF2C1700);

  // Accent (uso ilustrativo, nunca em ação principal)
  static const Color accentOrange = Color(0xFFF58220);
  static const Color accentOrangeDeep = Color(0xFFD86A0F);
  static const Color accentSky = Color(0xFF1E8BEA);
  static const Color accentLeaf = Color(0xFF4DA64A);
}

class IwSpacing {
  IwSpacing._();
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s7 = 28;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;
}

class IwRadius {
  IwRadius._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 28;
}

class IwSizing {
  IwSizing._();
  static const double appBarHeight = 60;
  static const double contentMaxWidth = 1200;
  static const double loginMaxWidth = 400;
}

/// Tema do app — M3 light scheme a partir de `primaryDeep` com sobrescritas
/// alinhadas ao design system.
ThemeData buildIwTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: IwColors.primaryDeep,
    primary: IwColors.primary,
    onPrimary: IwColors.onPrimary,
    primaryContainer: IwColors.primaryContainer,
    onPrimaryContainer: IwColors.onPrimaryContainer,
    secondary: IwColors.secondary,
    onSecondary: IwColors.onSecondary,
    secondaryContainer: IwColors.secondaryContainer,
    onSecondaryContainer: IwColors.onSecondaryContainer,
    tertiary: IwColors.tertiary,
    onTertiary: IwColors.onTertiary,
    tertiaryContainer: IwColors.tertiaryContainer,
    onTertiaryContainer: IwColors.onTertiaryContainer,
    error: IwColors.error,
    onError: IwColors.onError,
    errorContainer: IwColors.errorContainer,
    onErrorContainer: IwColors.onErrorContainer,
    surface: IwColors.surface,
    onSurface: IwColors.onSurface,
    onSurfaceVariant: IwColors.onSurfaceVariant,
    outline: IwColors.outline,
    outlineVariant: IwColors.outlineVariant,
    surfaceContainerLowest: IwColors.surfaceContainerLowest,
    surfaceContainerLow: IwColors.surfaceContainerLow,
    surfaceContainer: IwColors.surfaceContainer,
    surfaceContainerHigh: IwColors.surfaceContainerHigh,
    surfaceContainerHighest: IwColors.surfaceContainerHighest,
  );

  final base = ThemeData(colorScheme: scheme, useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IwRadius.md),
        borderSide: const BorderSide(color: IwColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IwRadius.md),
        borderSide: const BorderSide(color: IwColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IwRadius.md),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IwRadius.md),
        borderSide: BorderSide(color: scheme.error),
      ),
      labelStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.w400,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(40, 40),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outline),
        foregroundColor: scheme.primary,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IwRadius.lg),
        side: const BorderSide(color: IwColors.outlineVariant),
      ),
    ),
    chipTheme: ChipThemeData(
      side: const BorderSide(color: IwColors.outlineVariant),
      backgroundColor: scheme.surfaceContainerLow,
      labelStyle: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w500),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(IwRadius.xl)),
      ),
      dragHandleColor: scheme.outline,
    ),
    dividerTheme: const DividerThemeData(
      color: IwColors.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF322F33),
      contentTextStyle: const TextStyle(color: Color(0xFFF4EFF4)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IwRadius.xs),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IwRadius.xl),
      ),
    ),
  );
}
