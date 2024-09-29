import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kharcha_app/models/category.dart';
import 'package:kharcha_app/models/expense.dart';
import 'package:kharcha_app/repositories/expense_repository.dart';

part 'expense_list_event.dart';
part 'expense_list_state.dart';

class ExpenseListBloc extends Bloc<ExpenseListEvent, ExpenseListState> {
  ExpenseListBloc({required ExpenseRepository repository})
      : _repository = repository,
        super(const ExpenseListState()) {
    on<ExpenseListSubscriptionRequested>(_onSubscriptionRequested);
    on<ExpenseListExpenseDeleted>(_onExpenseDeleted);
    on<ExpenseListCategoryFilterChanged>(_onExpenseCategoryFilterChanged);
  }

  final ExpenseRepository _repository;

  final Map<int, String> nepaliMonths = {
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
    12: 'डिसेम्बर',
  };

  String convertToNepaliNumerals(int number) {
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

  String _getWeekKey(DateTime date) {
    final weekOfMonth = ((date.day - 1) ~/ 7) + 1;
    final nepaliMonth = nepaliMonths[date.month];
    final nepaliWeek = convertToNepaliNumerals(weekOfMonth);
    final nepaliYear = convertToNepaliNumerals(date.year);

    return '$nepaliMonth, हप्ता $nepaliWeek, $nepaliYear';
  }

  Future<void> _onSubscriptionRequested(
    ExpenseListSubscriptionRequested event,
    Emitter<ExpenseListState> emit,
  ) async {
    emit(state.copyWith(status: () => ExpenseListStatus.loading));

    final stream = _repository.getAllExpenses();
    await emit.forEach<List<Expense?>>(
      stream,
      onData: (expenses) {
        if (expenses.isEmpty) {
          return state.copyWith(
            status: () => ExpenseListStatus.success,
            expenses: () => [],
            totalExpenses: () => 0.0,
            expensesByWeek: () => {},
          );
        }

        final filteredExpenses = state.filter.applyAll(expenses);

        final Map<String, List<Expense>> expensesByWeek = {};
        for (final expense in filteredExpenses) {
          final weekKey = _getWeekKey(expense!.date);
          expensesByWeek.putIfAbsent(weekKey, () => []).add(expense);
        }

        final sortedExpensesByWeek = Map.fromEntries(
          expensesByWeek.entries.toList()
            ..sort((a, b) => b.key.compareTo(a.key)),
        );

        return state.copyWith(
          status: () => ExpenseListStatus.success,
          expenses: () => expenses,
          totalExpenses: () =>
              filteredExpenses.map((e) => e!.amount).fold(0.0, (a, b) => a + b),
          expensesByWeek: () => sortedExpensesByWeek,
        );
      },
      onError: (_, __) => state.copyWith(
        status: () => ExpenseListStatus.failure,
      ),
    );
  }

  Future<void> _onExpenseDeleted(
    ExpenseListExpenseDeleted event,
    Emitter<ExpenseListState> emit,
  ) async {
    await _repository.deleteExpense(event.expense.id);
  }

  Future<void> _onExpenseCategoryFilterChanged(
    ExpenseListCategoryFilterChanged event,
    Emitter<ExpenseListState> emit,
  ) async {
    emit(state.copyWith(filter: () => event.filter));

    final filteredExpenses = state.filter.applyAll(state.expenses);
    final Map<String, List<Expense>> expensesByWeek = {};

    for (final expense in filteredExpenses) {
      final weekKey = _getWeekKey(expense!.date);
      expensesByWeek.putIfAbsent(weekKey, () => []).add(expense);
    }

    final sortedExpensesByWeek = Map.fromEntries(
      expensesByWeek.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );

    emit(state.copyWith(expensesByWeek: () => sortedExpensesByWeek));
  }
}
