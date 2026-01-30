import 'package:expense_splitter/src/core/theme/theme.dart';
import 'package:expense_splitter/src/core/widgets/shimmer_loading.dart';
import 'package:expense_splitter/src/feature/expense/data/model/expense_model.dart';
import 'package:expense_splitter/src/feature/expense/data/repository/expense_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _repo = ExpenseRepository();

  bool _loading = true;
  String? _error;
  List<ExpenseModel> _expenses = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final expenses = await _repo.getAllExpenses();
      if (!mounted) return;
      setState(() {
        _expenses = expenses;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.charcoalBlack, AppTheme.midnightBlue],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.offWhite,
                    AppTheme.softLavender.withAlpha(64),
                  ],
                ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _load,
            color: AppTheme.premiumPurple,
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Your spending trends (from saved expenses)',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                if (_loading) ...[
                  const ShimmerCard(),
                  const ShimmerCard(),
                ] else if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppTheme.errorRed,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_error!)),
                      ],
                    ),
                  ),
                ] else ...[
                  _DailyChart(expenses: _expenses),
                  const SizedBox(height: 16),
                  _MonthlyChart(expenses: _expenses),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyChart extends StatelessWidget {
  final List<ExpenseModel> expenses;
  const _DailyChart({required this.expenses});

  DateTime _dayKey(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Map<DateTime, double> _sumByDayLastNDays(int days) {
    final now = DateTime.now();
    final start = _dayKey(now).subtract(Duration(days: days - 1));
    final map = <DateTime, double>{};
    for (int i = 0; i < days; i++) {
      map[start.add(Duration(days: i))] = 0.0;
    }
    for (final e in expenses) {
      final k = _dayKey(e.createdAt);
      if (k.isBefore(start) || k.isAfter(_dayKey(now))) continue;
      map[k] = (map[k] ?? 0) + e.amount;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final map = _sumByDayLastNDays(7);
    final keys = map.keys.toList()..sort();
    final values = keys.map((k) => map[k] ?? 0).toList();
    final maxY = (values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.show_chart, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                'Daily (last 7 days)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: (maxY <= 0) ? 10 : (maxY * 1.2),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= keys.length) {
                          return const SizedBox.shrink();
                        }
                        final d = keys[idx];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${d.day}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: AppTheme.premiumPurple,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.premiumPurple.withAlpha(64),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    spots: [
                      for (int i = 0; i < values.length; i++)
                        FlSpot(i.toDouble(), values[i]),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  final List<ExpenseModel> expenses;
  const _MonthlyChart({required this.expenses});

  DateTime _monthKey(DateTime dt) => DateTime(dt.year, dt.month);

  Map<DateTime, double> _sumByMonthLastNMonths(int months) {
    final now = DateTime.now();
    final end = _monthKey(now);
    final start = DateTime(end.year, end.month - (months - 1));
    final map = <DateTime, double>{};
    for (int i = 0; i < months; i++) {
      map[DateTime(start.year, start.month + i)] = 0.0;
    }
    for (final e in expenses) {
      final k = _monthKey(e.createdAt);
      if (k.isBefore(start) || k.isAfter(end)) continue;
      map[k] = (map[k] ?? 0) + e.amount;
    }
    return map;
  }

  String _monthLabel(DateTime m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final map = _sumByMonthLastNMonths(6);
    final keys = map.keys.toList()..sort();
    final values = keys.map((k) => map[k] ?? 0).toList();
    final maxY = (values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bar_chart, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                'Monthly (last 6 months)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: (maxY <= 0) ? 10 : (maxY * 1.2),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= keys.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _monthLabel(keys[idx]),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (int i = 0; i < values.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values[i],
                          width: 14,
                          borderRadius: BorderRadius.circular(8),
                          gradient: AppTheme.primaryGradient,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
