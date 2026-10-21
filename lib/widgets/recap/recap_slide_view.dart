import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_theme.dart';
import '../../utils/app_routes.dart';

/// Content of one recap slide.
@immutable
class RecapSlide {
  /// Creates a slide. Provide either [emoji] or [icon].
  const RecapSlide({
    required this.gradient,
    required this.kicker,
    required this.headline,
    this.emoji,
    this.icon,
    this.caption,
    this.footer,
  });

  final Gradient gradient;
  final String? emoji;
  final IconData? icon;

  /// Small text above the headline.
  final String kicker;

  /// The big number or word.
  final String headline;
  final String? caption;

  /// Small branding line (on the shareable summary slide).
  final String? footer;
}

/// Full-bleed gradient slide with its content animating in.
class RecapSlideView extends StatelessWidget {
  /// Creates the view.
  const RecapSlideView({super.key, required this.slide});

  static const double _emojiSize = 64;
  static const double _headlineSize = 44;
  static const double _mutedOpacity = 0.85;

  final RecapSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animate = AppMotion.enabled(context);
    final muted = AppColors.white.withValues(alpha: _mutedOpacity);
    final icon = slide.icon;
    final caption = slide.caption;
    final footer = slide.footer;
    final parts = <Widget>[
      if (slide.emoji case final emoji?)
        Text(emoji, style: const TextStyle(fontSize: _emojiSize))
      else if (icon != null)
        Icon(icon, size: _emojiSize, color: AppColors.white),
      const SizedBox(height: AppSpacing.lg),
      Text(
        slide.kicker,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(color: muted),
      ),
      const SizedBox(height: AppSpacing.sm),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          slide.headline,
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            color: AppColors.white,
            fontSize: _headlineSize,
            fontFeatures: AppTypography.tabularFigures,
          ),
        ),
      ),
      if (caption != null) ...[
        const SizedBox(height: AppSpacing.sm),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: muted),
        ),
      ],
      if (footer != null) ...[
        const SizedBox(height: AppSpacing.xxl),
        Text(footer, style: theme.textTheme.labelSmall?.copyWith(color: muted)),
      ],
    ];
    return DecoratedBox(
      decoration: BoxDecoration(gradient: slide.gradient),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: parts
                .animate(
                  interval: animate
                      ? AppDurations.listItemStagger * 2
                      : Duration.zero,
                )
                .fadeIn(duration: animate ? AppDurations.slow : Duration.zero)
                .slideY(begin: animate ? 0.2 : 0, end: 0),
          ),
        ),
      ),
    );
  }
}
