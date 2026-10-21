import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_strings.dart';
import 'constants/app_theme.dart';
import 'providers/expense_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'services/expense_repository.dart';
import 'services/monitoring_service.dart';

/// Root widget: provides state to the tree and applies the theme.
class ExpenseTrackerApp extends StatelessWidget {
  /// Creates the app. [home] overrides the first screen (used in tests).
  const ExpenseTrackerApp({
    super.key,
    required this.repository,
    required this.settings,
    this.monitoring = const NoopMonitoringService(),
    this.home,
  });

  final ExpenseRepository repository;
  final SettingsProvider settings;
  final MonitoringService monitoring;
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MonitoringService>.value(value: monitoring),
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        ChangeNotifierProvider<ExpenseProvider>(
          create: (_) => ExpenseProvider(repository, monitoring: monitoring),
        ),
      ],
      child: Selector<SettingsProvider, ThemeMode>(
        selector: (_, s) => s.themeMode,
        builder: (context, themeMode, _) => MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          navigatorObservers: monitoring.navigatorObservers,
          home: home ?? const SplashScreen(),
        ),
      ),
    );
  }
}
