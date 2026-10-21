import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../screens/privacy_policy_screen.dart';
import '../utils/app_routes.dart';

/// Animated page indicator: the active dot stretches into a pill.
class PageDots extends StatelessWidget {
  /// Creates dots for [count] pages with [current] highlighted.
  const PageDots({super.key, required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppDurations.medium,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            width: i == current
                ? AppSizes.dotIndicatorActive
                : AppSizes.dotIndicator,
            height: AppSizes.dotIndicator,
            decoration: BoxDecoration(
              color: i == current ? scheme.primary : scheme.outline,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}

/// "By continuing you agree to our Privacy policy" with a tappable link.
class PrivacyFooter extends StatelessWidget {
  /// Creates the footer.
  const PrivacyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          AppStrings.onboardingPrivacyPrefix,
          style: theme.textTheme.bodySmall,
        ),
        Semantics(
          link: true,
          child: GestureDetector(
            onTap: () => Navigator.of(
              context,
            ).push(AppRoutes.fadeSlide<void>(const PrivacyPolicyScreen())),
            child: Text(
              AppStrings.privacyTitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
