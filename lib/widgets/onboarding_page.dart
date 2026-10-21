import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../utils/app_routes.dart';

/// Content of one onboarding page: illustration, title and description.
@immutable
class OnboardingContent {
  /// Creates page content.
  const OnboardingContent({
    required this.icon,
    required this.title,
    required this.body,
    required this.satellites,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Small icons that float around the main illustration.
  final List<IconData> satellites;
}

/// One onboarding page with an animated illustration.
class OnboardingPage extends StatelessWidget {
  /// Creates the page.
  const OnboardingPage({super.key, required this.content});

  final OnboardingContent content;

  // Positions of the floating satellite icons around the circle.
  static const List<Alignment> _orbit = [
    Alignment(-0.95, -0.7),
    Alignment(0.95, -0.4),
    Alignment(-0.8, 0.85),
  ];
  static const double _floatDistance = 0.08;
  static const Duration _floatDuration = Duration(milliseconds: 1800);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final animate = AppMotion.enabled(context);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: AppSizes.onboardingArt,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: AppSizes.onboardingArt * 0.72,
                      height: AppSizes.onboardingArt * 0.72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: palette.brandGradient,
                      ),
                      child: Icon(
                        content.icon,
                        size: AppSizes.iconHero * 1.4,
                        color: AppColors.white,
                      ),
                    ).animate().scale(
                      duration: animate ? AppDurations.slow : Duration.zero,
                      curve: Curves.easeOutBack,
                    ),
                    for (
                      var i = 0;
                      i < content.satellites.length && i < _orbit.length;
                      i++
                    )
                      Align(
                        alignment: _orbit[i],
                        child:
                            Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: palette.cardShadow,
                                        blurRadius: AppEffects.shadowBlur,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    content.satellites[i],
                                    color: theme.colorScheme.primary,
                                  ),
                                )
                                .animate(
                                  onPlay: (c) =>
                                      animate ? c.repeat(reverse: true) : null,
                                )
                                .slideY(
                                  begin: 0,
                                  end: i.isEven
                                      ? _floatDistance
                                      : -_floatDistance,
                                  duration: _floatDuration,
                                  curve: Curves.easeInOut,
                                ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                content.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ).animate().fadeIn(
                duration: animate ? AppDurations.slow : Duration.zero,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                content.body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: palette.textSecondary,
                ),
              ).animate().fadeIn(
                delay: animate ? AppDurations.fast : Duration.zero,
                duration: animate ? AppDurations.slow : Duration.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
