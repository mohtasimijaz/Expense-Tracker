import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../constants/app_theme.dart';
import '../../utils/app_routes.dart';

/// Odometer-style text: when a character changes it rolls up into place.
///
/// Characters are matched from the right so digits keep their place as the
/// number grows (e.g. `999` → `1,000`). Use tabular figures for steady
/// widths (added automatically).
class RollingText extends StatelessWidget {
  /// Creates rolling text.
  const RollingText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final effective = (style ?? DefaultTextStyle.of(context).style).copyWith(
      fontFeatures: AppTypography.tabularFigures,
    );
    final animate = AppMotion.enabled(context);
    final chars = text.characters.toList();
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: ClipRect(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < chars.length; i++)
              _RollingChar(
                key: ValueKey(chars.length - i),
                char: chars[i],
                style: effective,
                animate: animate,
              ),
          ],
        ),
      ),
    );
  }
}

class _RollingChar extends StatelessWidget {
  const _RollingChar({
    super.key,
    required this.char,
    required this.style,
    required this.animate,
  });

  final String char;
  final TextStyle style;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: animate ? AppDurations.medium : Duration.zero,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final incoming = child.key == ValueKey(char);
        final slide = Tween<Offset>(
          begin: Offset(0, incoming ? 1 : -1),
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(
          position: slide,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Text(char, key: ValueKey(char), style: style),
    );
  }
}
