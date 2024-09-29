import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kharcha_app/blocs/expense_list/expense_list_bloc.dart';
import 'package:kharcha_app/extensions/extensions.dart';
import 'package:kharcha_app/models/expense.dart';
import 'package:kharcha_app/models/category.dart';

String convertToNepaliNumerals(String number) {
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
    '9': '९',
    '.': '.'
  };
  return number.split('').map((e) => englishToNepali[e] ?? e).join('');
}

String formatDateInNepali(DateTime date) {
  final nepaliMonths = {
    1: 'जनवरी',
    2: 'फेब्रुअरी',
    3: 'मार्च',
    4: 'अप्रिल',
    5: 'मे',
    6: 'जुन',
    7: 'जुलाई',
    8: 'अगस्ट',
    9: 'सेप्टेम्बर',
    10: 'अक्टोबर',
    11: 'नोभेम्बर',
    12: 'डिसेम्बर'
  };
  final day = convertToNepaliNumerals(date.day.toString());
  final month = nepaliMonths[date.month];
  final year = convertToNepaliNumerals(date.year.toString());
  return '$day $month $year';
}

class ExpenseTileWidget extends StatelessWidget {
  const ExpenseTileWidget({super.key, required this.expense});
  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final formattedDate = formatDateInNepali(expense.date);
    final amountInNepali =
        convertToNepaliNumerals(expense.amount.toStringAsFixed(2));

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(16),
        color: colorScheme.error,
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      onDismissed: (direction) {
        context
            .read<ExpenseListBloc>()
            .add(ExpenseListExpenseDeleted(expense: expense));
      },
      child: ListTile(
        onTap: () => context.showAddExpenseSheet(expense: expense),
        leading: Icon(
          _getIconForCategory(expense.category),
          color: colorScheme.surfaceTint,
        ),
        title: Text(expense.title, style: textTheme.titleMedium),
        subtitle: Text(
          formattedDate,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        trailing: Text(
          '-$amountInNepali',
          style: textTheme.titleLarge?.copyWith(
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(Category category) {
    switch (category) {
      case Category.grocery:
        return Icons.shopping_cart;
      case Category.food:
        return Icons.restaurant;
      case Category.entertainment:
        return Icons.movie;
      case Category.traveling:
        return Icons.flight;
      case Category.other:
        return Icons.category;
      default:
        return Icons.attach_money;
    }
  }
}
