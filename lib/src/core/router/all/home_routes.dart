import 'package:expense_splitter/src/feature/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeRoutes {
  static const String homePage = '/home-page';

  static final routes = <GoRoute>[
    GoRoute(
      path: homePage,
      pageBuilder: (context, state) => MaterialPage(child: HomePage()),
    ),
  ];
}
