import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

/// Quick-stats strip showing Today / Week / Month / Average spend.
///
/// Layout demonstration (Lab 02):
///   Row                      ← horizontal arrangement
///     ├─ Expanded(child: _StatCard(...))
///     ├─ Expanded(child: _StatCard(...))
///     ├─ Expanded(child: _StatCard(...))
///     └─ Expanded(child: _StatCard(...))
///
/// Each _StatCard is a Column of label (small grey text) + value (bold).
/// Expanded inside Row gives each card equal width regardless of screen size.
class StatsRow extends StatelessWidget {
  final List<Expense> expenses;

  const StatsRow({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.compactCurrency(symbol: '₹', decimalDigits: 0);

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 6));
    final monthStart = DateTime(now.year, now.month, 1);

    double todayTotal = 0;
    double weekTotal = 0;
    double monthTotal = 0;
    for (final e in expenses) {
      if (e.date.isAfter(todayStart.subtract(const Duration(seconds: 1)))) {
        todayTotal += e.amount;
      }
      if (e.date.isAfter(weekStart.subtract(const Duration(seconds: 1)))) {
        weekTotal += e.amount;
      }
      if (e.date.isAfter(monthStart.subtract(const Duration(seconds: 1)))) {
        monthTotal += e.amount;
      }
    }
    final avg = expenses.isEmpty ? 0.0 : expenses.fold(0.0, (s, e) => s + e.amount) / expenses.length;

    // Row → 4 × Expanded → each Expanded holds a Column (label + value)
    // NOTE: Do NOT use crossAxisAlignment: stretch here — inside a
    // SliverToBoxAdapter the Row would expand to fill all remaining vertical
    // space and push subsequent slivers (chart, expense list) off-screen.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Today',
              value: fmt.format(todayTotal),
              accent: Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'This Week',
              value: fmt.format(weekTotal),
              accent: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'This Month',
              value: fmt.format(monthTotal),
              accent: Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'Avg / Txn',
              value: fmt.format(avg),
              accent: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single stat card. A Column of label + value inside a Card.
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
