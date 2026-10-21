import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../constants/category_data.dart';
import '../../providers/expense_provider.dart';
import '../../utils/app_haptics.dart';
import '../common/pressable_scale.dart';

/// Horizontally scrolling category chips ("All" + every category).
class CategoryFilterBar extends StatelessWidget {
  /// Creates the bar.
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.select<ExpenseProvider, String?>(
      (p) => p.categoryFilter,
    );
    final provider = context.read<ExpenseProvider>();
    return SizedBox(
      height: AppSizes.chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: CategoryData.all.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _FilterChip(
              label: AppStrings.filterAll,
              icon: Icons.apps_rounded,
              selected: selected == null,
              onTap: () => provider.setCategoryFilter(null),
            );
          }
          final category = CategoryData.all[index - 1];
          return _FilterChip(
            label: category.label,
            icon: category.icon,
            selected: selected == category.id,
            onTap: () => provider.setCategoryFilter(category.id),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected
        ? scheme.onPrimary
        : context.palette.textSecondary;
    return Semantics(
      selected: selected,
      child: PressableScale(
        onTap: () {
          AppHaptics.play(context, HapticKind.selection);
          onTap();
        },
        child: AnimatedContainer(
          duration: AppDurations.medium,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : scheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outline,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: scheme.primary.withValues(
                        alpha: AppEffects.glassBorderOpacity,
                      ),
                      blurRadius: AppEffects.shadowBlur / 2,
                      offset: const Offset(0, AppEffects.shadowOffsetY / 2),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppSizes.iconSm, color: foreground),
              const SizedBox(width: AppSpacing.xxs + 2),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
