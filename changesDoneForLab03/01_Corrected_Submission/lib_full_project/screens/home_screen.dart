import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/chart_section.dart';
import '../widgets/expense_card.dart';
import '../widgets/stats_row.dart';
import '../widgets/responsive_expense_grid.dart';
import 'add_expense_screen.dart';

/// Lab 03 — Adaptive & Responsive Design
///
/// The HomeScreen now wraps its body in a [LayoutBuilder] to detect the
/// available width and switches between a single-column **mobile layout**
/// (< 600 dp) and a two-column **tablet/web layout** (>= 600 dp).
///
/// Inside the tablet layout, an [OrientationBuilder] wraps the expense
/// list section so that the grid column count changes between portrait
/// (2 columns) and landscape (3 columns).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Material Design breakpoint — widely used convention.
  static const double tabletBreakpoint = 600.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (!provider.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = provider.expenses;
          final total = provider.totalExpenses;
          final categoryTotals = provider.categoryTotals;
          final currencyFormat =
              NumberFormat.currency(symbol: '₹', decimalDigits: 0);

          // ── LayoutBuilder: detect available width ──────────────
          // This is the core of Lab 03. Instead of assuming a mobile
          // width, we read constraints.maxWidth and branch.
          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= tabletBreakpoint;

              if (isTablet) {
                return _tabletLayout(
                  context: context,
                  expenses: expenses,
                  total: total,
                  categoryTotals: categoryTotals,
                  currencyFormat: currencyFormat,
                  provider: provider,
                  constraints: constraints,
                );
              }
              return _mobileLayout(
                context: context,
                expenses: expenses,
                total: total,
                categoryTotals: categoryTotals,
                currencyFormat: currencyFormat,
                provider: provider,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  //  MOBILE LAYOUT  (< 600 dp)
  //  Single-column scroll view — identical to Lab 02 but now explicitly
  //  selected by the LayoutBuilder branch above.
  // ──────────────────────────────────────────────────────────────────
  Widget _mobileLayout({
    required BuildContext context,
    required List expenses,
    required double total,
    required Map<String, double> categoryTotals,
    required NumberFormat currencyFormat,
    required ExpenseProvider provider,
  }) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _totalCard(context, total, expenses.length, currencyFormat)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: StatsRow(expenses: expenses),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Breakdown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
        SliverToBoxAdapter(child: ChartSection(categoryTotals: categoryTotals, total: total)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Recent Transactions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
        if (expenses.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No expenses yet. Tap + to add one.'),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final expense = expenses[index];
                final catTotal = categoryTotals[expense.category] ?? 0;
                final pct = total > 0 ? (catTotal / total) * 100 : 0.0;
                return ExpenseCard(
                  expense: expense,
                  categoryPercentage: pct,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddExpenseScreen(expense: expense)),
                  ),
                  onDelete: () => provider.deleteExpense(expense.id),
                );
              },
              childCount: expenses.length,
            ),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────
  //  TABLET / WEB LAYOUT  (>= 600 dp)
  //  Two-pane master–detail: left pane holds the summary (total card,
  //  stats, chart) in a fixed-width column; right pane holds the
  //  expense list in a responsive grid whose column count depends on
  //  orientation (via OrientationBuilder).
  // ──────────────────────────────────────────────────────────────────
  Widget _tabletLayout({
    required BuildContext context,
    required List expenses,
    required double total,
    required Map<String, double> categoryTotals,
    required NumberFormat currencyFormat,
    required ExpenseProvider provider,
    required BoxConstraints constraints,
  }) {
    // MediaQuery: read orientation for the overall pane split ratio
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left pane: summary (fixed width 380 on portrait, 320 on landscape)
        SizedBox(
          width: isLandscape ? 320 : 380,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _totalCard(context, total, expenses.length, currencyFormat)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: StatsRow(expenses: expenses),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Breakdown',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
              SliverToBoxAdapter(child: ChartSection(categoryTotals: categoryTotals, total: total)),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
        ),
        // ── Right pane: expense grid
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                // ── OrientationBuilder: change grid columns on rotation
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    // Portrait → 2 columns, Landscape → 3 columns
                    final crossAxisCount =
                        orientation == Orientation.portrait ? 2 : 3;
                    if (expenses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('No expenses yet. Tap + to add one.'),
                          ],
                        ),
                      );
                    }
                    return ResponsiveExpenseGrid(
                      expenses: expenses,
                      categoryTotals: categoryTotals,
                      total: total,
                      crossAxisCount: crossAxisCount,
                      onTap: (expense) => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddExpenseScreen(expense: expense)),
                      ),
                      onDelete: (id) => provider.deleteExpense(id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Shared total-balance gradient card ────────────────────────────
  Widget _totalCard(BuildContext context, double total, int count, NumberFormat fmt) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('Total Expenses',
              style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 8),
          Text(fmt.format(total),
              style: const TextStyle(
                  fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('$count transaction${count != 1 ? 's' : ''}',
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
