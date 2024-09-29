import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kharcha_app/theme/theme.dart';

import '../blocs/expense_form/expense_form_bloc.dart';
import '../models/category.dart';
import 'loading_widget.dart';

class AddExpenseSheetWidget extends StatelessWidget {
  const AddExpenseSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.viewInsetsOf(context),
      child: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CategoryChoicesWidget(),
            SizedBox(height: 16),
            NameField(),
            SizedBox(height: 16),
            AmountField(),
            SizedBox(height: 16),
            DateFieldWidget(),
            SizedBox(height: 16),
            AddButtonWidget(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class AddButtonWidget extends StatelessWidget {
  const AddButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExpenseFormBloc>().state;
    final isLoading = state.status == ExpenseFormStatus.loading;

    return FilledButton(
      onPressed: isLoading || !state.isFormValid
          ? null
          : () {
              context.read<ExpenseFormBloc>().add(const ExpenseSubmitted());
              Navigator.pop(context);
            },
      child: isLoading ? const LoadingWidget() : const Text('खर्च जोड्नुहोस्'),
    );
  }
}

class DateFieldWidget extends StatelessWidget {
  const DateFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final bloc = context.read<ExpenseFormBloc>();
    final state = context.watch<ExpenseFormBloc>().state;

    final formattedDate = state.initialExpense == null
        ? DateFormat('dd/MM/yyyy').format(state.date)
        : DateFormat('dd/MM/yyyy').format(state.initialExpense!.date);

    return GestureDetector(
      onTap: () async {
        final today = DateTime.now();
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: state.date,
          firstDate: DateTime(1900),
          lastDate: DateTime(today.year + 50),
        );
        if (selectedDate != null) {
          bloc.add(ExpenseDateChanged(selectedDate));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month),
            Text('   $formattedDate', style: textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class AmountField extends StatelessWidget {
  const AmountField({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = context.watch<ExpenseFormBloc>().state;

    return TextFormField(
      style: textTheme.displaySmall?.copyWith(fontSize: 30),
      onChanged: (value) {
        context.read<ExpenseFormBloc>().add(ExpenseAmountChanged(value));
      },
      initialValue: state.initialExpense?.amount.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          enabled: !state.status.isLoading,
          border: const OutlineInputBorder(),
          hintText: 'रु',
          hintStyle: TextStyle(
            color: AppTheme.colorScheme.primary.withOpacity(0.1),
          ),
          labelText: 'रकम लेख्नुहोस्'),
    );
  }
}

class NameField extends StatelessWidget {
  const NameField({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = context.watch<ExpenseFormBloc>().state;

    return TextFormField(
      style: textTheme.displaySmall?.copyWith(fontSize: 30),
      onChanged: (value) {
        context.read<ExpenseFormBloc>().add(ExpenseTitleChanged(value));
      },
      initialValue: state.initialExpense?.title,
      decoration: InputDecoration(
        enabled: !state.status.isLoading,
        border: const OutlineInputBorder(),
        labelText: 'खर्चको नाम लेख्नुहोस्',
      ),
    );
  }
}

class CategoryChoicesWidget extends StatelessWidget {
  const CategoryChoicesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ExpenseFormBloc>();
    final state = context.watch<ExpenseFormBloc>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 15,
          runSpacing: 0,
          children: Category.values
              .where((category) => category != Category.all)
              .map((currentCategory) => ChoiceChip(
                    label: Text(currentCategory.toName),
                    selected: currentCategory == state.category,
                    onSelected: (_) => bloc.add(
                      ExpenseCategoryChanged(currentCategory),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
