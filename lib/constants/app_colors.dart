import 'package:flutter/material.dart';

/// Raw color values for the light and dark palettes.
///
/// Text/background pairs were chosen to meet WCAG AA (4.5:1) for body text:
/// - light: textPrimary #0F172A on #F8FAFC ≈ 17:1, textSecondary #475569 ≈ 7.2:1
/// - dark:  textPrimary #F1F5F9 on #0B1120 ≈ 17:1, textSecondary #94A3B8 ≈ 7.4:1
/// - white on primary #4F46E5 ≈ 6.3:1, white on danger #B91C1C ≈ 6.5:1
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF818CF8);
  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryDark = Color(0xFFA78BFA);
  static const Color accent = Color(0xFF0D9488);
  static const Color accentDark = Color(0xFF2DD4BF);

  // Semantic (light)
  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFB45309);
  static const Color danger = Color(0xFFB91C1C);

  // Semantic (dark)
  static const Color successDark = Color(0xFF4ADE80);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color dangerDark = Color(0xFFF87171);

  // Neutrals (light)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF2F7);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);

  // Neutrals (dark)
  static const Color backgroundDark = Color(0xFF0B1120);
  static const Color surfaceDark = Color(0xFF131C2E);
  static const Color surfaceVariantDark = Color(0xFF1E293B);
  static const Color outlineDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
}

/// Semantic colors and gradients exposed through the theme so widgets never
/// hard-code a color and automatically follow light/dark mode.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// Creates a palette.
  const AppPalette({
    required this.success,
    required this.warning,
    required this.danger,
    required this.textSecondary,
    required this.cardShadow,
    required this.brandGradient,
    required this.backgroundGradient,
    required this.glassTint,
    required this.decoration,
    this.warningGradient = _warningGradient,
    this.dangerGradient = _dangerGradient,
  });

  // Deep amber/orange and red/rose keep white text above 4.5:1 contrast.
  static const Gradient _warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB45309), Color(0xFFC2410C)],
  );
  static const Gradient _dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB91C1C), Color(0xFFBE185D)],
  );

  final Color success;
  final Color warning;
  final Color danger;
  final Color textSecondary;
  final Color cardShadow;
  final Gradient brandGradient;
  final Gradient backgroundGradient;
  final Color glassTint;
  final Color decoration;

  /// Balance card when spending reached the warning threshold.
  final Gradient warningGradient;

  /// Balance card when the budget is exceeded.
  final Gradient dangerGradient;

  /// Palette used in light mode.
  static const AppPalette light = AppPalette(
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    textSecondary: AppColors.textSecondary,
    cardShadow: Color(0x140F172A),
    brandGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.primary, AppColors.secondary],
    ),
    backgroundGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFEEF0FF), AppColors.background, AppColors.background],
    ),
    glassTint: AppColors.white,
    decoration: AppColors.primary,
  );

  /// Palette used in dark mode.
  static const AppPalette dark = AppPalette(
    success: AppColors.successDark,
    warning: AppColors.warningDark,
    danger: AppColors.dangerDark,
    textSecondary: AppColors.textSecondaryDark,
    cardShadow: Color(0x66000000),
    brandGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4338CA), Color(0xFF6D28D9)],
    ),
    backgroundGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF161B3D),
        AppColors.backgroundDark,
        AppColors.backgroundDark,
      ],
    ),
    glassTint: AppColors.white,
    decoration: AppColors.primaryDark,
  );

  @override
  AppPalette copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? textSecondary,
    Color? cardShadow,
    Gradient? brandGradient,
    Gradient? backgroundGradient,
    Color? glassTint,
    Color? decoration,
    Gradient? warningGradient,
    Gradient? dangerGradient,
  }) {
    return AppPalette(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      textSecondary: textSecondary ?? this.textSecondary,
      cardShadow: cardShadow ?? this.cardShadow,
      brandGradient: brandGradient ?? this.brandGradient,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      glassTint: glassTint ?? this.glassTint,
      decoration: decoration ?? this.decoration,
      warningGradient: warningGradient ?? this.warningGradient,
      dangerGradient: dangerGradient ?? this.dangerGradient,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t) ?? cardShadow,
      brandGradient:
          Gradient.lerp(brandGradient, other.brandGradient, t) ?? brandGradient,
      backgroundGradient:
          Gradient.lerp(backgroundGradient, other.backgroundGradient, t) ??
          backgroundGradient,
      glassTint: Color.lerp(glassTint, other.glassTint, t) ?? glassTint,
      decoration: Color.lerp(decoration, other.decoration, t) ?? decoration,
      warningGradient:
          Gradient.lerp(warningGradient, other.warningGradient, t) ??
          warningGradient,
      dangerGradient:
          Gradient.lerp(dangerGradient, other.dangerGradient, t) ??
          dangerGradient,
    );
  }
}

/// Convenient access to the active [AppPalette].
extension AppPaletteContext on BuildContext {
  /// The semantic palette of the current theme.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  /// Whether the current theme is dark.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
