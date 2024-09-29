import 'package:flutter/material.dart';
import 'package:kharcha_app/extensions/extensions.dart';

import '../widgets/expense_filter_widget.dart';
import '../widgets/expenses_widget.dart';
import '../widgets/total_expenses_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'हिसाब किताब',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        leading: const Padding(
          padding: EdgeInsets.all(10.0),
          child: CircleAvatar(),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.menu))],
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TotalExpensesWidget(),
            SizedBox(height: 14),
            ExpenseFilterWidget(),
            SizedBox(height: 14),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: ExpensesWidget(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: context.showAddExpenseSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
