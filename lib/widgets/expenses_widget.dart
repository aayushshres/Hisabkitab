import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kharcha_app/blocs/expense_list/expense_list_bloc.dart';
import 'expense_tile_widget.dart';
import 'loading_widget.dart';

class ExpensesWidget extends StatelessWidget {
  const ExpensesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return BlocBuilder<ExpenseListBloc, ExpenseListState>(
      builder: (context, state) {
        if (state.status == ExpenseListStatus.loading) {
          return const LoadingWidget(radius: 12, addPadding: true);
        }

        final groupedExpenses =
            state.expensesByWeek; // Get grouped expenses by week

        if (groupedExpenses.isEmpty) {
          return const EmptyListWidget();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groupedExpenses.length,
          itemBuilder: (context, index) {
            final weekKey = groupedExpenses.keys.elementAt(index);
            final expenses = groupedExpenses[weekKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekKey, // Display the week in Nepali
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 18,
                  ),
                ),
                ...expenses
                    .map((expense) => ExpenseTileWidget(expense: expense))
                    .toList(),
              ],
            );
          },
        );
      },
    );
  }
}

class EmptyListWidget extends StatelessWidget {
  const EmptyListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.search),
          const SizedBox(height: 10),
          Text(
            'Nothing to see here',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
