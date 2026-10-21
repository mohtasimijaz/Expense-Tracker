import 'package:flutter/material.dart';

import 'app.dart';
import 'providers/settings_provider.dart';
import 'services/database_service.dart';
import 'services/expense_repository.dart';
import 'services/monitoring_service.dart';
import 'services/settings_service.dart';

/// App entry point.
///
/// Start-up order:
/// 1. Firebase (crash reporting + analytics) — falls back to a no-op
///    monitor if Firebase is not configured yet.
/// 2. Settings and the Hive database, in parallel.
/// 3. `runApp`. If the database failed to open, the splash screen retries
///    and shows an error with a "Try again" button instead of crashing.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final monitoring = await FirebaseMonitoringService.initialize();
  final region = WidgetsBinding.instance.platformDispatcher.locale.countryCode;
  final settings = SettingsProvider(
    SettingsService(regionCode: region),
    monitoring: monitoring,
  );
  final database = DatabaseService();

  await Future.wait([settings.load(), _openDatabase(database, monitoring)]);

  runApp(
    ExpenseTrackerApp(
      repository: database,
      settings: settings,
      monitoring: monitoring,
    ),
  );
}

Future<void> _openDatabase(
  DatabaseService database,
  MonitoringService monitoring,
) async {
  try {
    await database.init();
  } on DatabaseException catch (error, stackTrace) {
    await monitoring.recordError(error, stackTrace);
  }
}
