import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Analytics event names.
abstract final class AnalyticsEvents {
  static const String expenseAdded = 'expense_added';
  static const String expenseUpdated = 'expense_updated';
  static const String expenseDeleted = 'expense_deleted';
  static const String expenseRestored = 'expense_restored';
  static const String expensesCleared = 'expenses_cleared';
  static const String budgetSet = 'budget_set';
  static const String currencyChanged = 'currency_changed';
  static const String themeChanged = 'theme_changed';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String paramCategory = 'category';
  static const String paramValue = 'value';
}

/// Crash reporting and analytics, abstracted so the app works with or
/// without Firebase configured.
abstract interface class MonitoringService {
  /// Navigator observers that report screen views.
  List<NavigatorObserver> get navigatorObservers;

  /// Logs an analytics event. Never throws.
  Future<void> logEvent(String name, [Map<String, Object>? parameters]);

  /// Reports a non-fatal error. Never throws.
  Future<void> recordError(Object error, StackTrace? stackTrace);
}

/// Used when Firebase is not configured (or on web/desktop): prints in
/// debug builds, does nothing in release.
class NoopMonitoringService implements MonitoringService {
  /// Creates a no-op monitor.
  const NoopMonitoringService();

  @override
  List<NavigatorObserver> get navigatorObservers => const [];

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    if (kDebugMode) debugPrint('[analytics] $name ${parameters ?? ''}');
  }

  @override
  Future<void> recordError(Object error, StackTrace? stackTrace) async {
    if (kDebugMode) debugPrint('[error] $error\n$stackTrace');
  }
}

/// Firebase Crashlytics + Analytics implementation.
class FirebaseMonitoringService implements MonitoringService {
  FirebaseMonitoringService._(this._analytics, this._crashlytics);

  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;

  /// Initialises Firebase and installs global error handlers.
  ///
  /// Returns a [NoopMonitoringService] when Firebase is unavailable — for
  /// example before `flutterfire configure` has been run, or on web/desktop
  /// where Crashlytics is not supported — so the app always starts.
  static Future<MonitoringService> initialize() async {
    final isMobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (!isMobile) return const NoopMonitoringService();
    try {
      await Firebase.initializeApp();
      final crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
      FlutterError.onError = crashlytics.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        unawaited(crashlytics.recordError(error, stack, fatal: true));
        return true;
      };
      return FirebaseMonitoringService._(
        FirebaseAnalytics.instance,
        crashlytics,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Firebase not configured, monitoring disabled: $error');
        debugPrint('$stackTrace');
      }
      return const NoopMonitoringService();
    }
  }

  @override
  List<NavigatorObserver> get navigatorObservers => [
    FirebaseAnalyticsObserver(analytics: _analytics),
  ];

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (_) {
      // Analytics must never break the app.
    }
  }

  @override
  Future<void> recordError(Object error, StackTrace? stackTrace) async {
    try {
      await _crashlytics.recordError(error, stackTrace);
    } catch (_) {
      // Crash reporting must never break the app.
    }
  }
}
