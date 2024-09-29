import 'package:kharcha_app/models/expense.dart';

enum Category {
  all,
  grocery,
  food,
  entertainment,
  traveling,
  other;

  String toJson() => name;
  static Category fromJson(String json) => values.byName(json);
}

extension CategoryX on Category {
  String get toName => switch (this) {
        Category.all => 'सबै',
        Category.entertainment => 'मनोरञ्जन',
        Category.food => 'खाना',
        Category.grocery => 'किराना',
        Category.traveling => 'यात्रा',
        Category.other => 'अन्य',
      };

  bool apply(Expense? expense) => switch (this) {
        Category.all => true,
        Category.entertainment => expense?.category == Category.entertainment,
        Category.food => expense?.category == Category.food,
        Category.grocery => expense?.category == Category.grocery,
        Category.traveling => expense?.category == Category.traveling,
        Category.other => expense?.category == Category.other,
      };

  Iterable<Expense?> applyAll(Iterable<Expense?> expenses) {
    return expenses.where(apply);
  }
}
