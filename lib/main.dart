import 'package:flutter/material.dart';
import 'package:kharcha_app/data/local_data_storage.dart';
import 'package:kharcha_app/repositories/expense_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = LocalDataStorage(
    preferences: await SharedPreferences.getInstance(),
  );

  final expenseRepository = ExpenseRepository(storage: storage);

  runApp(App(expenseRepository: expenseRepository));
}
