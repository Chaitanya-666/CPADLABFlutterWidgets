import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoaded = false;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoaded => _isLoaded;

  double get totalExpenses => _expenses.fold(0, (sum, e) => sum + e.amount);

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final cat in Category.all) {
      totals[cat] = _expenses
          .where((e) => e.category == cat)
          .fold(0, (sum, e) => sum + e.amount);
    }
    return totals;
  }

  Future<void> load() async {
    _expenses = await StorageService.loadExpenses();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    await StorageService.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      _expenses.sort((a, b) => b.date.compareTo(a.date));
      await StorageService.saveExpenses(_expenses);
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await StorageService.saveExpenses(_expenses);
    notifyListeners();
  }
}
