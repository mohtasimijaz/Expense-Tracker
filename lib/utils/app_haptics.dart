import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

/// Strength of a vibration.
enum HapticKind {
  /// Tiny tick for keypad keys, chips and tabs.
  selection,

  /// Saved, restored.
  light,

  /// Deleted, long-press menu.
  medium,

  /// Budget exceeded, celebrations.
  heavy,
}

/// Vibration feedback that respects the user's "Haptic feedback" setting.
abstract final class AppHaptics {
  /// Plays [kind] if haptics are enabled in settings.
  static void play(BuildContext context, HapticKind kind) =>
      playIf(enabledIn(context), kind);

  /// Plays [kind] when [enabled] — for callers that captured the setting
  /// before their context went away.
  static void playIf(bool enabled, HapticKind kind) {
    if (!enabled) return;
    switch (kind) {
      case HapticKind.selection:
        HapticFeedback.selectionClick();
      case HapticKind.light:
        HapticFeedback.lightImpact();
      case HapticKind.medium:
        HapticFeedback.mediumImpact();
      case HapticKind.heavy:
        HapticFeedback.heavyImpact();
    }
  }

  /// Whether haptics are on; defaults to on when settings are unavailable.
  static bool enabledIn(BuildContext context) {
    try {
      return Provider.of<SettingsProvider>(
        context,
        listen: false,
      ).settings.hapticsEnabled;
    } on ProviderNotFoundException {
      return true;
    }
  }
}
