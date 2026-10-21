import 'package:hive/hive.dart';

/// Represents a single expense record in the application.
///
/// Designed with immutability, full null-safety, and serialization
/// support for Hive database and JSON export/import.
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  /// Creates a copy of this expense with modified fields.
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  /// Converts this [Expense] to a map representation for JSON export or backup.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note ?? '',
    };
  }

  /// Creates an [Expense] from a map representation.
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String? ?? 'Other',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      note: map['note'] as String?,
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
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, category: $category, date: $date, note: $note)';
  }
}

/// Hive TypeAdapter for [Expense] to enable high-performance binary serialization
/// without requiring external build_runner code generation.
class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String? ?? '',
      title: fields[1] as String? ?? '',
      amount: (fields[2] as num?)?.toDouble() ?? 0.0,
      category: fields[3] as String? ?? 'Other',
      date: fields[4] != null
          ? DateTime.fromMillisecondsSinceEpoch(fields[4] as int)
          : DateTime.now(),
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(5)
      ..write(obj.note);
  }
}
