import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';

/// Shared page transitions so navigation feels identical on Android and iOS.
abstract final class AppRoutes {
  static const double _slideOffset = 0.06;

  /// Fade + gentle upward slide. Used for full-screen pages.
  static Route<T> fadeSlide<T>(Widget page, {bool fullscreenDialog = false}) {
    return PageRouteBuilder<T>(
      fullscreenDialog: fullscreenDialog,
      transitionDuration: AppDurations.medium,
      reverseTransitionDuration: AppDurations.medium,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, _slideOffset),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Plain cross-fade. Used when replacing the whole screen (splash → home).
  static Route<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: AppDurations.slow,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}

/// Respects the system "reduce motion" accessibility setting.
abstract final class AppMotion {
  /// Whether decorative animations should play.
  static bool enabled(BuildContext context) =>
      !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
}
