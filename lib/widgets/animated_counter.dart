import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';

/// Animates a number from its previous value to [value] (counting up from
/// zero on first build) and renders it with [format].
class AnimatedCounter extends StatelessWidget {
  /// Creates a counter.
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.duration = AppDurations.counter,
    this.textAlign,
  });

  final double value;

  /// Turns the in-between value into text (e.g. a currency formatter).
  final String Function(double value) format;
  final TextStyle? style;
  final Duration duration;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: reduceMotion ? Duration.zero : duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => Text(
        format(animated),
        style: style,
        textAlign: textAlign,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        semanticsLabel: format(value),
      ),
    );
  }
}
