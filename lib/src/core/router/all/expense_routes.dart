import 'package:expense_splitter/src/feature/expense/presentation/pages/expense_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpenseRoutes {
  static const String expensePage = '/expense-page';

  static final routes = <GoRoute>[
    GoRoute(
      path: expensePage,
      pageBuilder: (context, state) => MaterialPage(child: const ExpensePage()),
    ),
  ];
}
