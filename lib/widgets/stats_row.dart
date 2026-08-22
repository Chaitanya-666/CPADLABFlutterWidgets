import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

/// Quick-stats strip showing Today / Week / Month / Average spend.
///
/// Lab 02 base: `Row` → 4 × `Expanded` → `Column`.
///
/// Lab 03 enhancement: On screens narrower than 360 dp the four
/// `Expanded` cards become too cramped.  A [LayoutBuilder] wraps the
/// row; when `constraints.maxWidth < 360` we switch from a single `Row`
/// to a [Wrap] that lets cards flow onto a second line (2 per row).
/// This demonstrates the responsive use of `Wrap` alongside `Expanded`.
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
    final avg = expenses.isEmpty
        ? 0.0
        : expenses.fold(0.0, (s, e) => s + e.amount) / expenses.length;

    final cards = [
      _StatCard(label: 'Today', value: fmt.format(todayTotal), accent: Colors.orange),
      _StatCard(label: 'This Week', value: fmt.format(weekTotal), accent: Colors.blue),
      _StatCard(label: 'This Month', value: fmt.format(monthTotal), accent: Colors.green),
      _StatCard(label: 'Avg / Txn', value: fmt.format(avg), accent: Colors.purple),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // ── LayoutBuilder: choose Row (>= 360 dp) or Wrap (< 360 dp)
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 360) {
            // Wrap: cards flow to next line — responsive fallback
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cards
                  .map((c) => SizedBox(
                        width: (constraints.maxWidth - 8) / 2,
                        child: c,
                      ))
                  .toList(),
            );
          }
          // Row → 4 × Expanded (default, Lab 02 behaviour)
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i < cards.length - 1) const SizedBox(width: 8),
              ],
            ],
          );
        },
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
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold, color: accent)),
          ],
        ),
      ),
    );
  }
}
