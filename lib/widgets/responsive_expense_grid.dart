import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../widgets/expense_card.dart';

/// Lab 03 — Responsive expense grid for the tablet/web layout.
///
/// Uses [GridView.builder] inside an [OrientationBuilder] (the
/// crossAxisCount is passed in by the caller, who read it from
/// OrientationBuilder).  Each grid cell is an [ExpenseCard] wrapped
/// in a [Card] with a percentage badge — the same visual as the mobile
/// list, but laid out in a grid.
///
/// The [Wrap] widget inside the legend below the chart (see
/// ChartSection) is the other responsive container in this app:
/// it flows category legend chips onto multiple lines on narrow
/// screens.
class ResponsiveExpenseGrid extends StatelessWidget {
  final List<Expense> expenses;
  final Map<String, double> categoryTotals;
  final double total;
  final int crossAxisCount;
  final void Function(Expense)? onTap;
  final void Function(String)? onDelete;

  const ResponsiveExpenseGrid({
    super.key,
    required this.expenses,
    required this.categoryTotals,
    required this.total,
    required this.crossAxisCount,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 2.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final catTotal = categoryTotals[expense.category] ?? 0;
        final pct = total > 0 ? (catTotal / total) * 100 : 0.0;
        return ExpenseCard(
          expense: expense,
          categoryPercentage: pct,
          onTap: onTap != null ? () => onTap!(expense) : null,
          onDelete: onDelete != null ? () => onDelete!(expense.id) : null,
        );
      },
    );
  }
}
