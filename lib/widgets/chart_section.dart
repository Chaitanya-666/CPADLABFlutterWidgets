import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class ChartSection extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final double total;

  const ChartSection({
    super.key,
    required this.categoryTotals,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No expenses yet')),
      );
    }

    final sections = categoryTotals.entries
        .where((e) => e.value > 0)
        .map((e) {
          final percentage = (e.value / total) * 100;
          return PieChartSectionData(
            color: Color(Category.colors[e.key] ?? 0xFF90A4AE),
            value: e.value,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: categoryTotals.entries.where((e) => e.value > 0).map((e) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(Category.colors[e.key] ?? 0xFF90A4AE),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text('${e.key}'),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
