import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    title: json['title'],
    amount: json['amount'],
    date: DateTime.parse(json['date']),
    category: json['category'],
  );
}

class Category {
  static const List<String> all = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health',
    'Other',
  ];

  static const Map<String, int> colors = {
    'Food': 0xFFE57373,
    'Transport': 0xFF64B5F6,
    'Shopping': 0xFF81C784,
    'Entertainment': 0xFFFFB74D,
    'Bills': 0xFFBA68C8,
    'Health': 0xFF4DB6AC,
    'Other': 0xFF90A4AE,
  };
}
