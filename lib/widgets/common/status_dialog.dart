import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../utils/app_routes.dart';

/// The visual style of a [StatusDialog].
@immutable
class StatusStyle {
  /// Creates a style.
  const StatusStyle({required this.asset, required this.fallbackIcon});

  /// Lottie animation to play.
  final String asset;

  /// Icon shown if the animation cannot load.
  final IconData fallbackIcon;
}

/// Shows a centred animated status card (e.g. the green "saved" tick or the
/// red "deleted" bin) on [navigator] and closes it after [duration].
///
/// Takes a [NavigatorState] instead of a context so it can be called after
/// the widget that triggered it has left the tree.
Future<void> showStatusDialog(
  NavigatorState navigator, {
  required String message,
  required StatusStyle style,
  required Color color,
  required Duration duration,
}) async {
  var closed = false;
  unawaited(
    showGeneralDialog<void>(
      context: navigator.context,
      barrierDismissible: false,
      barrierColor: AppColors.black.withValues(alpha: _barrierOpacity),
      transitionDuration: AppDurations.medium,
      pageBuilder: (_, _, _) =>
          StatusDialog(message: message, style: style, color: color),
      transitionBuilder: (context, animation, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: animation, child: child),
      ),
    ).then((_) => closed = true),
  );
  await Future<void>.delayed(duration);
  if (!closed && navigator.mounted) navigator.pop();
}

const double _barrierOpacity = 0.3;

/// The card shown by [showStatusDialog].
class StatusDialog extends StatelessWidget {
  /// Creates the card.
  const StatusDialog({
    super.key,
    required this.message,
    required this.style,
    required this.color,
  });

  final String message;
  final StatusStyle style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Semantics(
        liveRegion: true,
        label: message,
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: AppSizes.successArt,
                  child: Lottie.asset(
                    style.asset,
                    repeat: false,
                    animate: AppMotion.enabled(context),
                    errorBuilder: (context, error, stackTrace) => Icon(
                      style.fallbackIcon,
                      size: AppSizes.iconHero,
                      color: color,
                    ),
                  ),
                ),
                Text(message, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
