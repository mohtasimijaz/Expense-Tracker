import 'dart:io';

import 'package:expense_tracker/constants/app_info.dart';
import 'package:expense_tracker/constants/app_strings.dart';
import 'package:expense_tracker/utils/expense_validator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  test('AppInfo version matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*(\S+)\+(\d+)',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(match, isNotNull);
    expect(match!.group(1), AppInfo.version);
    expect(int.parse(match.group(2)!), AppInfo.buildNumber);
  });

  test('bundled Lottie animations parse', () async {
    for (final path in [
      AppAssets.lottieEmpty,
      AppAssets.lottieSuccess,
      AppAssets.lottieLoading,
    ]) {
      final bytes = File(path).readAsBytesSync();
      final composition = await LottieComposition.fromBytes(bytes);
      expect(composition.duration, greaterThan(Duration.zero), reason: path);
      expect(composition.layers, isNotEmpty, reason: path);
    }
  });

  group('ExpenseValidator', () {
    test('title', () {
      expect(ExpenseValidator.title(''), AppStrings.validationTitleEmpty);
      expect(ExpenseValidator.title('   '), AppStrings.validationTitleEmpty);
      expect(ExpenseValidator.title('a' * 61), AppStrings.validationTitleLong);
      expect(ExpenseValidator.title('Lunch 🍜 & "drinks"'), isNull);
    });

    test('amount', () {
      expect(ExpenseValidator.amount(''), AppStrings.validationAmountEmpty);
      expect(
        ExpenseValidator.amount('abc'),
        AppStrings.validationAmountInvalid,
      );
      expect(ExpenseValidator.amount('0'), AppStrings.validationAmountZero);
      expect(ExpenseValidator.amount('-5'), AppStrings.validationAmountZero);
      expect(ExpenseValidator.amount('999999999'), isNull);
      expect(ExpenseValidator.amount('1,250.75'), isNull);
      expect(
        ExpenseValidator.amount('9999999999999'),
        AppStrings.validationAmountTooLarge,
      );
      expect(ExpenseValidator.parseAmount('1,250.75'), 1250.75);
    });

    test('note', () {
      expect(ExpenseValidator.note(null), isNull);
      expect(ExpenseValidator.note('x' * 201), AppStrings.validationNoteLong);
    });

    test('amount input formatter', () {
      final two = AmountInputFormatter(decimalDigits: 2);
      final zero = AmountInputFormatter(decimalDigits: 0);
      TextEditingValue apply(AmountInputFormatter f, String from, String to) =>
          f.formatEditUpdate(
            TextEditingValue(text: from),
            TextEditingValue(text: to),
          );
      expect(apply(two, '12', '12.5').text, '12.5');
      expect(apply(two, '12.50', '12.505').text, '12.50');
      expect(apply(two, '12.5', '12.5.').text, '12.5');
      expect(apply(two, '1', '1a').text, '1');
      expect(apply(zero, '12', '12.').text, '12');
      expect(apply(two, '', '9' * 13).text, '');
    });
  });
}
