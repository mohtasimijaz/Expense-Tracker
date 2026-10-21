import 'package:expense_tracker/constants/app_strings.dart';
import 'package:expense_tracker/models/expense_sort.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/add_expense_screen.dart';
import 'package:expense_tracker/screens/main_shell.dart';
import 'package:expense_tracker/screens/recap_screen.dart';
import 'package:expense_tracker/utils/formatters.dart';
import 'package:expense_tracker/widgets/expense_card.dart';
import 'package:expense_tracker/widgets/home/day_header.dart';
import 'package:expense_tracker/widgets/quick_add/category_bubbles.dart';
import 'package:expense_tracker/widgets/quick_add/number_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'helpers/pump_app.dart';
import 'helpers/test_helpers.dart';

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 12);
  DateTime daysAgo(int d) => today.subtract(Duration(days: d));

  Future<void> tapKeys(WidgetTester tester, String keys) async {
    for (final k in keys.split('')) {
      await tester.tap(
        find.descendant(of: find.byType(NumberPad), matching: find.text(k)),
      );
      await tester.pump();
    }
  }

  Future<void> openQuickAdd(WidgetTester tester) async {
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
  }

  ExpenseProvider provider(WidgetTester tester) =>
      tester.element(find.byType(MainShell)).read<ExpenseProvider>();

  group('quick add', () {
    testWidgets('keypad + category + save shows the green tick', (
      tester,
    ) async {
      final app = await pumpApp(tester);
      await openQuickAdd(tester);
      await tapKeys(tester, '1250');
      await tester.tap(
        find.descendant(
          of: find.byType(CategoryBubbles),
          matching: find.text('Transport'),
        ),
      );
      await tester.tap(find.text(AppStrings.quickAddSave));
      await settle(tester, const Duration(milliseconds: 700));
      expect(find.text(AppStrings.expenseSaved), findsOneWidget);
      await settle(tester, const Duration(seconds: 2));

      final saved = app.repository.store.values.single;
      expect(saved.amount, 1250);
      expect(saved.category, 'Transport');
      expect(saved.title, 'Transport', reason: 'title defaults to category');
      expect(tester.takeException(), isNull);
    });

    testWidgets('save does nothing until an amount is typed', (tester) async {
      final app = await pumpApp(tester);
      await openQuickAdd(tester);
      await tester.tap(find.text(AppStrings.quickAddSave));
      await settle(tester, const Duration(milliseconds: 500));
      expect(app.repository.store, isEmpty);
      await tapKeys(tester, '0');
      await tester.tap(find.text(AppStrings.quickAddSave));
      await settle(tester, const Duration(milliseconds: 500));
      expect(app.repository.store, isEmpty);
    });

    testWidgets('"More details" carries amount and category to the form', (
      tester,
    ) async {
      await pumpApp(tester);
      await openQuickAdd(tester);
      await tapKeys(tester, '75');
      await tester.tap(
        find.descendant(
          of: find.byType(CategoryBubbles),
          matching: find.text('Health'),
        ),
      );
      await tester.tap(find.text(AppStrings.quickAddMoreDetails));
      await settle(tester);
      final screen = tester.widget<AddExpenseScreen>(
        find.byType(AddExpenseScreen),
      );
      expect(screen.initialAmount, 75);
      expect(screen.initialCategory, 'Health');
      expect(find.widgetWithText(TextFormField, '75'), findsOneWidget);
    });
  });

  group('delete, undo and cancel', () {
    testWidgets('swipe shows the bin animation, then UNDO restores', (
      tester,
    ) async {
      final expense = makeExpense(id: 'x', title: 'Groceries', date: today);
      final app = await pumpApp(tester, initial: [expense]);
      await scrollTo(tester, find.text('Groceries'));
      await scrollToEnd(tester);
      await tester.drag(find.byType(ExpenseCard), const Offset(-600, 0));
      await settle(tester, const Duration(milliseconds: 600));
      expect(find.text(AppStrings.expenseDeletedTitle), findsOneWidget);
      expect(app.repository.store, isEmpty);

      await settle(tester, const Duration(seconds: 2));
      expect(find.text(AppStrings.undo), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget, reason: 'cancel undo');

      await tester.tap(find.text(AppStrings.undo));
      await settle(tester, const Duration(milliseconds: 700));
      expect(app.repository.store['x'], expense);
      expect(find.text(AppStrings.expenseRestored), findsOneWidget);
      await settle(tester, const Duration(seconds: 2));
    });

    testWidgets('closing the undo bar makes the delete final', (tester) async {
      final app = await pumpApp(
        tester,
        initial: [makeExpense(id: 'x', title: 'Groceries', date: today)],
      );
      await scrollTo(tester, find.text('Groceries'));
      await scrollToEnd(tester);
      await tester.drag(find.byType(ExpenseCard), const Offset(-600, 0));
      await settle(tester, const Duration(seconds: 2));
      await tester.tap(find.byIcon(Icons.close));
      await settle(tester, const Duration(seconds: 1));
      expect(find.text(AppStrings.undo), findsNothing);
      expect(provider(tester).canUndoDelete, isFalse);
      expect(app.repository.store, isEmpty);
    });

    testWidgets('press and hold opens options; Delete works', (tester) async {
      final app = await pumpApp(
        tester,
        initial: [makeExpense(id: 'x', title: 'Cinema', date: today)],
      );
      await scrollTo(tester, find.text('Cinema'));
      await scrollToEnd(tester);
      await tester.longPress(find.text('Cinema'));
      await settle(tester);
      expect(find.text(AppStrings.optionsEdit), findsOneWidget);
      await tester.tap(find.text(AppStrings.optionsDelete));
      await settle(tester, const Duration(milliseconds: 800));
      expect(find.text(AppStrings.expenseDeletedTitle), findsOneWidget);
      expect(app.repository.store, isEmpty);
      await settle(tester, const Duration(seconds: 2));
    });

    testWidgets('press and hold → Edit opens the edit screen', (tester) async {
      await pumpApp(
        tester,
        initial: [makeExpense(id: 'x', title: 'Cinema', date: today)],
      );
      await scrollTo(tester, find.text('Cinema'));
      await scrollToEnd(tester);
      await tester.longPress(find.text('Cinema'));
      await settle(tester);
      await tester.tap(find.text(AppStrings.optionsEdit));
      await settle(tester);
      expect(find.text(AppStrings.editExpenseTitle), findsOneWidget);
    });
  });

  testWidgets('timeline groups by day; amount sort shows a flat list', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initial: [
        makeExpense(id: 'a', title: 'A', amount: 100, date: today),
        makeExpense(id: 'b', title: 'B', amount: 50, date: today),
        makeExpense(id: 'c', title: 'C', amount: 30, date: daysAgo(1)),
      ],
    );
    await scrollTo(tester, find.text('C'));
    final headers = tester
        .widgetList<DayHeader>(find.byType(DayHeader))
        .toList();
    expect(headers.length, 2);
    expect(headers.first.group.total, 150);
    expect(headers.first.group.expenses.length, 2);
    expect(find.text(AppStrings.yesterday), findsWidgets);

    provider(tester).setSort(ExpenseSort.highestAmount);
    await settle(tester, const Duration(milliseconds: 500));
    expect(find.byType(DayHeader), findsNothing);
  });

  testWidgets('streak chip counts consecutive days', (tester) async {
    await pumpApp(
      tester,
      initial: [
        makeExpense(id: 'a', date: today),
        makeExpense(id: 'b', date: daysAgo(1)),
        makeExpense(id: 'c', date: daysAgo(2)),
        makeExpense(id: 'old', date: daysAgo(10)),
      ],
    );
    expect(find.text('🔥 ${AppStrings.streakChip(3)}'), findsOneWidget);
  });

  testWidgets('reaching a streak milestone celebrates once', (tester) async {
    final app = await pumpApp(
      tester,
      initial: [
        makeExpense(id: 'a', date: daysAgo(1)),
        makeExpense(id: 'b', date: daysAgo(2)),
      ],
    );
    await openQuickAdd(tester);
    await tapKeys(tester, '5');
    await tester.tap(find.text(AppStrings.quickAddSave));
    await settle(tester, const Duration(seconds: 3));
    expect(find.text(AppStrings.streakCelebrationTitle(3)), findsOneWidget);
    await tester.tap(find.text(AppStrings.celebrationButton));
    await settle(tester, const Duration(seconds: 3));
    expect(app.settings.settings.celebratedStreakLength, 3);
  });

  testWidgets('last month under budget is celebrated on start, once', (
    tester,
  ) async {
    final lastMonth = DateTime(now.year, now.month - 1, 10);
    final app = await pumpApp(
      tester,
      prefs: const {
        'settings.onboardingComplete': true,
        'settings.monthlyBudget': 1000.0,
      },
      initial: [makeExpense(id: 'm', amount: 400, date: lastMonth)],
    );
    await settle(tester, const Duration(seconds: 1));
    final title = AppStrings.monthCelebrationTitle(
      AppDateFormat.monthYear(lastMonth),
    );
    expect(find.text(title), findsOneWidget);
    await tester.tap(find.text(AppStrings.celebrationButton));
    await settle(tester, const Duration(seconds: 3));
    expect(app.settings.settings.celebratedMonthKey, isNotNull);
  });

  testWidgets('budget ring shows usage and over-budget state', (tester) async {
    await pumpApp(
      tester,
      prefs: const {
        'settings.onboardingComplete': true,
        'settings.monthlyBudget': 1000.0,
      },
      initial: [makeExpense(id: 'a', amount: 1500, date: today)],
    );
    expect(find.text('150%'), findsOneWidget);
    expect(find.textContaining(AppStrings.budgetOver), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('insight cards open the monthly recap story', (tester) async {
    await pumpApp(
      tester,
      initial: [
        makeExpense(id: 'a', amount: 500, date: daysAgo(0)),
        makeExpense(id: 'b', amount: 100, category: 'Health', date: daysAgo(1)),
      ],
    );
    expect(find.text(AppStrings.insightsTitle), findsOneWidget);
    final recapTitle = AppStrings.insightRecapTitle(
      AppDateFormat.monthName(provider(tester).insights.recapMonth()),
    );
    await tester.dragUntilVisible(
      find.text(recapTitle),
      find.byType(PageView),
      const Offset(-300, 0),
    );
    await tester.tap(find.text(recapTitle));
    await settle(tester);
    expect(find.byType(RecapScreen), findsOneWidget);
    expect(find.textContaining(AppStrings.recapYouSpent), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      await tester.tapAt(const Offset(350, 400));
      await settle(tester, const Duration(milliseconds: 600));
    }
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip(AppStrings.recapClose));
    await settle(tester);
    expect(find.byType(RecapScreen), findsNothing);
  });

  testWidgets('haptics switch and gesture tip are remembered', (tester) async {
    final app = await pumpApp(
      tester,
      initial: [makeExpense(id: 'a', date: today)],
    );
    await scrollTo(tester, find.text(AppStrings.gestureHint));
    await scrollToEnd(tester);
    expect(find.text(AppStrings.gestureHint), findsOneWidget);
    await tester.tap(find.byTooltip(AppStrings.dismiss));
    await settle(tester, const Duration(milliseconds: 600));
    expect(find.text(AppStrings.gestureHint), findsNothing);
    expect(app.settings.settings.gestureHintDismissed, isTrue);

    await tester.tap(find.text(AppStrings.navSettings));
    await settle(tester);
    await tester.tap(find.text(AppStrings.settingHaptics));
    await settle(tester, const Duration(milliseconds: 300));
    expect(app.settings.settings.hapticsEnabled, isFalse);
  });
}
