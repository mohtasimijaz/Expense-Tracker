import 'package:hive/hive.dart';

part 'expense.g.dart';

/// A single expense record.
///
/// Immutable and null-safe. Persisted with Hive through the generated
/// [ExpenseAdapter] (`dart run build_runner build`). Field numbers in
/// `@HiveField` must never be changed or reused once released, otherwise
/// existing users' data could not be read.
@HiveType(typeId: 0)
class Expense {
  /// Creates an expense.
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  /// Unique identifier (UUID v4). Also used as the database key.
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  /// Amount in the user's selected currency. Always > 0.
  @HiveField(2)
  final double amount;

  /// Category id from `CategoryData`.
  @HiveField(3)
  final String category;

  /// When the money was spent.
  @HiveField(4)
  final DateTime date;

  /// Optional free-text note.
  @HiveField(5)
  final String? note;

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass [clearNote] to explicitly remove the note.
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    bool clearNote = false,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: clearNote ? null : (note ?? this.note),
    );
  }

  /// Serialises to a JSON-compatible map (for export/backup).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  /// Parses a map produced by [toMap]. Missing or malformed values fall back
  /// to safe defaults instead of throwing.
  factory Expense.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    final rawNote = map['note'];
    return Expense(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      category: map['category'] as String? ?? 'Other',
      date: rawDate is String
          ? DateTime.tryParse(rawDate) ?? DateTime.now()
          : DateTime.now(),
      note: rawNote is String && rawNote.isNotEmpty ? rawNote : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.category == category &&
        other.date == date &&
        other.note == note;
  }

  @override
  int get hashCode => Object.hash(id, title, amount, category, date, note);

  @override
  String toString() =>
      'Expense(id: $id, title: $title, amount: $amount, '
      'category: $category, date: $date, note: $note)';
}
