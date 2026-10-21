import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';

/// A titled card grouping related settings rows.
class SettingsGroup extends StatelessWidget {
  /// Creates a group.
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.xs,
          ),
          child: Text(title, style: theme.textTheme.labelSmall),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: theme.colorScheme.outline),
            boxShadow: [
              BoxShadow(
                color: context.palette.cardShadow,
                blurRadius: AppEffects.shadowBlur / 2,
                offset: const Offset(0, AppEffects.shadowOffsetY / 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// Leading icon in a tinted rounded square, used by settings rows.
class SettingsIcon extends StatelessWidget {
  /// Creates the icon. [color] defaults to the primary color.
  const SettingsIcon(this.icon, {super.key, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: AppEffects.tintOpacity),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: tint, size: AppSizes.iconMd),
    );
  }
}
