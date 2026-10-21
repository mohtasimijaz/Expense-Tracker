/// Layout, sizing and timing tokens shared across the app.
///
/// Every spacing value sits on an 8px grid (with a 4px half-step) so
/// screens line up consistently on every device.
library;

/// Spacing scale based on an 8px grid.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

/// Corner radii used by cards, chips, inputs and sheets.
abstract final class AppRadius {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double pill = 999;
}

/// Fixed component sizes.
abstract final class AppSizes {
  static const double iconXs = 12;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
  static const double iconHero = 56;

  static const double avatar = 48;
  static const double logo = 96;
  static const double onboardingArt = 220;
  static const double emptyStateArt = 180;
  static const double successArt = 140;
  static const double loadingArt = 96;

  static const double chipHeight = 40;
  static const double searchBarHeight = 48;
  static const double progressBarHeight = 8;
  static const double buttonHeight = 56;
  static const double dotIndicator = 8;
  static const double dotIndicatorActive = 24;
  static const double handleWidth = 40;
  static const double handleHeight = 4;

  static const double chartHeight = 220;
  static const double pieChartHeight = 200;
  static const double pieCenterRadius = 48;
  static const double pieSectionRadius = 44;
  static const double pieSectionRadiusTouched = 54;
  static const double barWidth = 18;
  static const double lineWidth = 3;
  static const double chartReservedLeft = 44;
  static const double chartReservedBottom = 28;

  /// Content never grows wider than this so tablets/landscape stay readable.
  static const double maxContentWidth = 720;

  /// Above this width two-column layouts are used.
  static const double wideBreakpoint = 720;

  /// Bottom padding so the floating action button never hides list items.
  static const double fabClearance = 96;

  /// Distance from the end of the list at which the next page is loaded.
  static const double loadMoreTriggerExtent = 400;
}

/// Elevation and blur values.
abstract final class AppEffects {
  static const double glassBlur = 18;
  static const double glassOpacity = 0.14;
  static const double glassBorderOpacity = 0.22;
  static const double shadowOpacity = 0.08;
  static const double shadowBlur = 24;
  static const double shadowOffsetY = 8;
  static const double tintOpacity = 0.14;
  static const double subtleOpacity = 0.06;
  static const double pressedScale = 0.96;
  static const double decorationOpacity = 0.07;
}

/// Animation durations.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration counter = Duration(milliseconds: 900);
  static const Duration splashMinimum = Duration(milliseconds: 1800);
  static const Duration success = Duration(milliseconds: 1400);
  static const Duration snackBar = Duration(seconds: 4);
  static const Duration listItemStagger = Duration(milliseconds: 40);
  static const Duration searchDebounce = Duration(milliseconds: 250);

  /// Stagger animations stop growing after this many items so long lists
  /// do not take seconds to appear.
  static const int maxStaggeredItems = 8;
}
