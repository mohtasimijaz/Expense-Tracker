import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../providers/quick_add_controller.dart';
import '../common/pressable_scale.dart';

/// Calculator-style number pad: 1–9, decimal point, 0 and backspace.
/// Long-press backspace clears everything.
class NumberPad extends StatelessWidget {
  /// Creates a pad. When [allowDecimal] is false the "." key is hidden.
  const NumberPad({
    super.key,
    required this.onKey,
    required this.onClear,
    required this.allowDecimal,
  });

  final ValueChanged<PadKey> onKey;
  final VoidCallback onClear;
  final bool allowDecimal;

  static const List<List<PadKey>> _rows = [
    [PadKey.digit1, PadKey.digit2, PadKey.digit3],
    [PadKey.digit4, PadKey.digit5, PadKey.digit6],
    [PadKey.digit7, PadKey.digit8, PadKey.digit9],
    [PadKey.decimal, PadKey.digit0, PadKey.backspace],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                for (var i = 0; i < row.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.xs),
                  Expanded(child: _key(context, row[i])),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _key(BuildContext context, PadKey key) {
    if (key == PadKey.decimal && !allowDecimal) {
      return const SizedBox(height: AppSizes.buttonHeight);
    }
    final theme = Theme.of(context);
    final isBackspace = key == PadKey.backspace;
    return PressableScale(
      onTap: () => onKey(key),
      onLongPress: isBackspace ? onClear : null,
      semanticLabel: switch (key) {
        PadKey.backspace => AppStrings.keypadBackspace,
        PadKey.decimal => AppStrings.keypadDecimal,
        _ => key.symbol,
      },
      child: Container(
        height: AppSizes.buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: isBackspace
            ? Icon(Icons.backspace_outlined, color: theme.colorScheme.onSurface)
            : Text(key.symbol, style: theme.textTheme.headlineSmall),
      ),
    );
  }
}
