import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kharcha_app/blocs/expense_list/expense_list_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final state = context.watch<ExpenseListBloc>().state;

    final totalExpensesInNepali = convertToNepaliNumerals(state.totalExpenses);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'कुल खर्च',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.4),
              fontSize: 18,
            ),
          ),
          Text('रु $totalExpensesInNepali', style: textTheme.displaySmall),
        ],
      ),
    );
  }
}
