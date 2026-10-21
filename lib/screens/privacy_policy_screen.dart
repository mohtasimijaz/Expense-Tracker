import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_info.dart';
import '../constants/app_strings.dart';

/// In-app privacy policy (required by Google Play and the App Store).
class PrivacyPolicyScreen extends StatelessWidget {
  /// Creates the screen.
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.privacyTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  '${AppStrings.privacyUpdatedPrefix}${AppInfo.privacyPolicyUpdated}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
                for (final (heading, body) in AppStrings.privacySections) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(heading, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(body, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
