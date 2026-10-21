import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/category_data.dart';
import '../common/pressable_scale.dart';

/// One-row horizontal picker of round category bubbles.
class CategoryBubbles extends StatelessWidget {
  /// Creates the picker.
  const CategoryBubbles({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  static const double _height = 92;
  static const double _bubble = 52;
  static const double _selectedScale = 1.08;

  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: _height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        // Room for the selected bubble's scale-up and glow.
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        itemCount: CategoryData.all.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = CategoryData.all[index];
          final selected = category.id == selectedId;
          final color = category.colorFor(theme.brightness);
          return Semantics(
            selected: selected,
            label: category.label,
            child: PressableScale(
              onTap: () => onSelected(category.id),
              child: Column(
                children: [
                  AnimatedScale(
                    scale: selected ? _selectedScale : 1,
                    duration: AppDurations.fast,
                    child: AnimatedContainer(
                      duration: AppDurations.medium,
                      curve: Curves.easeOutCubic,
                      width: _bubble,
                      height: _bubble,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? color
                            : color.withValues(alpha: AppEffects.tintOpacity),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: color.withValues(
                                    alpha: AppEffects.glassBorderOpacity * 2,
                                  ),
                                  blurRadius: AppEffects.shadowBlur / 2,
                                ),
                              ]
                            : const [],
                      ),
                      child: Icon(
                        category.icon,
                        color: selected
                            ? (context.isDarkMode
                                  ? AppColors.backgroundDark
                                  : AppColors.white)
                            : color,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    category.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: selected ? color : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
