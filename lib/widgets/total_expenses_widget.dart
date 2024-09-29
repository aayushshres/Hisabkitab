import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kharcha_app/blocs/expense_list/expense_list_bloc.dart';
import 'package:kharcha_app/theme/theme.dart';
import 'package:fl_chart/fl_chart.dart';

String convertToNepaliNumerals(double number) {
  const englishToNepali = {
    '0': '०',
    '1': '१',
    '2': '२',
    '3': '३',
    '4': '४',
    '5': '५',
    '6': '६',
    '7': '७',
    '8': '८',
    '9': '९'
  };
  return number
      .toString()
      .split('')
      .map((e) => englishToNepali[e] ?? e)
      .join('');
}

class TotalExpensesWidget extends StatelessWidget {
  const TotalExpensesWidget({super.key});

  List<FlSpot> _prepareGraphData(ExpenseListState state) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    final monthlyExpenses = state.expenses.where((expense) {
      final expenseDate = expense!.date;
      return expenseDate.isAfter(currentMonth) &&
          expenseDate.isBefore(nextMonth);
    }).toList();

    final weeklyData = List.generate(5, (index) => 0.0);

    for (var expense in monthlyExpenses) {
      final weekOfMonth = ((expense!.date.day - 1) ~/ 7);
      weeklyData[weekOfMonth] += expense.amount;
    }

    return weeklyData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = context.watch<ExpenseListBloc>().state;
    final totalExpensesInNepali = convertToNepaliNumerals(state.totalExpenses);
    final graphData = _prepareGraphData(state);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          width: 200,
          height: 85,
          decoration: BoxDecoration(
            color: AppTheme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'कुल खर्च',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
              Text('रु $totalExpensesInNepali', style: textTheme.displaySmall),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          width: 160,
          height: 85,
          decoration: BoxDecoration(
            color: AppTheme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'खर्च ग्राफ',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
              ),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 4,
                    minY: 0,
                    maxY: graphData
                        .map((spot) => spot.y)
                        .reduce((a, b) => a > b ? a : b),
                    lineBarsData: [
                      LineChartBarData(
                        spots: graphData,
                        isCurved: true,
                        color: AppTheme.colorScheme.primary,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
