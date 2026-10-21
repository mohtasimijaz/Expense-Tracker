import 'package:expense_tracker/providers/quick_add_controller.dart';
import 'package:expense_tracker/utils/expense_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  QuickAddController type(String keys, {int decimals = 2}) {
    final c = QuickAddController(decimalDigits: decimals);
    for (final k in keys.split('')) {
      c.press(switch (k) {
        '.' => PadKey.decimal,
        '<' => PadKey.backspace,
        _ => PadKey.forDigit(int.parse(k)),
      });
    }
    return c;
  }

  test('digits build the amount', () {
    final c = type('1250');
    expect(c.raw, '1250');
    expect(c.amount, 1250);
    expect(c.canSave, isTrue);
  });

  test('empty and zero cannot be saved', () {
    expect(type('').canSave, isFalse);
    expect(type('0').canSave, isFalse);
    expect(type('0.0').canSave, isFalse);
  });

  test('no leading zeros', () {
    expect(type('007').raw, '7');
    expect(type('00').raw, '0');
  });

  test('decimal point rules', () {
    expect(type('.5').raw, '0.5');
    expect(type('1..2').raw, '1.2');
    expect(type('9.999').raw, '9.99');
    expect(type('12.5', decimals: 0).raw, '125');
  });

  test('integer digits are capped', () {
    final c = type('9' * 20);
    expect(c.raw.length, ExpenseValidator.maxIntegerDigits);
    expect(c.canSave, isTrue);
  });

  test('backspace and clear', () {
    expect(type('123<').raw, '12');
    expect(type('<<').raw, '');
    final c = type('45')..clear();
    expect(c.raw, '');
  });

  test('rejected keys report false', () {
    final c = type('1.25');
    expect(c.press(PadKey.digit3), isFalse);
    expect(c.press(PadKey.decimal), isFalse);
    expect(c.press(PadKey.backspace), isTrue);
  });
}
