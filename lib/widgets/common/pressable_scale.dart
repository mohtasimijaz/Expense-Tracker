import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';

/// Micro-interaction: shrinks [child] slightly while pressed, then springs
/// back. Used on cards and buttons.
class PressableScale extends StatefulWidget {
  /// Creates a pressable wrapper. When [onTap] is null no effect is shown.
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Accessibility label announced for the tappable area.
  final String? semanticLabel;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  final ValueNotifier<bool> _pressed = ValueNotifier(false);

  @override
  void dispose() {
    _pressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    return Semantics(
      button: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _pressed.value = true : null,
        onTapUp: enabled ? (_) => _pressed.value = false : null,
        onTapCancel: enabled ? () => _pressed.value = false : null,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: ValueListenableBuilder<bool>(
          valueListenable: _pressed,
          child: widget.child,
          builder: (context, pressed, child) => AnimatedScale(
            scale: pressed ? AppEffects.pressedScale : 1,
            duration: AppDurations.fast,
            curve: Curves.easeOut,
            child: child,
          ),
        ),
      ),
    );
  }
}
