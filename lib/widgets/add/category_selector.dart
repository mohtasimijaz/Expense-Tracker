import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../constants/category_data.dart';
import '../../utils/app_haptics.dart';
import '../common/pressable_scale.dart';

/// Grid of selectable category tiles for the add/edit form.
class CategorySelector extends StatelessWidget {
  /// Creates the selector.
  const CategorySelector({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final category in CategoryData.all)
          _CategoryTile(
            category: category,
            selected: category.id == selectedId,
            onTap: () => onSelected(category.id),
          ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category.colorFor(theme.brightness);
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: AppEffects.tintOpacity * 1.5)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? color : theme.colorScheme.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(category.icon, color: color, size: AppSizes.iconMd),
              const SizedBox(width: AppSpacing.xs),
              Text(category.label, style: theme.textTheme.labelLarge),
              AnimatedSize(
                duration: AppDurations.fast,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.xxs),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: color,
                          size: AppSizes.iconSm,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
