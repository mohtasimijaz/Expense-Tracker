import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';

/// Shows a floating "deleted" bar with **UNDO** and a **✕** close button.
///
/// - Tapping UNDO calls [onUndo].
/// - Tapping ✕, letting the timer run out, or another message replacing it
///   calls [onCommit] (the delete becomes final).
void showUndoBar(
  ScaffoldMessengerState messenger, {
  required String message,
  required VoidCallback onUndo,
  required VoidCallback onCommit,
}) {
  messenger.clearSnackBars();
  final controller = messenger.showSnackBar(
    SnackBar(
      duration: AppDurations.undoWindow,
      showCloseIcon: true,
      content: UndoBarContent(message: message),
      action: SnackBarAction(label: AppStrings.undo, onPressed: onUndo),
    ),
  );
  controller.closed.then((reason) {
    if (reason != SnackBarClosedReason.action) onCommit();
  });
}

/// Message with a bin icon and a shrinking line that shows how long Undo is
/// still available.
class UndoBarContent extends StatelessWidget {
  /// Creates the content.
  const UndoBarContent({super.key, required this.message});

  static const double _countdownHeight = 3;

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        theme.snackBarTheme.contentTextStyle?.color ??
        theme.colorScheme.onInverseSurface;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: color),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 1, end: 0),
            duration: AppDurations.undoWindow,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: _countdownHeight,
              color: color,
              backgroundColor: color.withValues(alpha: AppEffects.tintOpacity),
            ),
          ),
        ),
      ],
    );
  }
}
