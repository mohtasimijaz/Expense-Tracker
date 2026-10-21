/// Static application metadata.
abstract final class AppInfo {
  /// Must match the `version:` name in pubspec.yaml (checked by a test).
  static const String version = '1.0.0';

  /// Must match the `+build` number in pubspec.yaml (checked by a test).
  static const int buildNumber = 1;

  /// Date the bundled privacy policy was last changed.
  static const String privacyPolicyUpdated = '21 October 2026';

  /// Display string such as "1.0.0 (1)".
  static String get versionLabel => '$version ($buildNumber)';
}

/// Paths of bundled assets.
abstract final class AppAssets {
  static const String lottieEmpty = 'assets/lottie/empty_wallet.json';
  static const String lottieSuccess = 'assets/lottie/success.json';
  static const String lottieLoading = 'assets/lottie/loading_coin.json';
}
