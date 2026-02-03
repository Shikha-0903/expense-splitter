import 'package:expense_splitter/src/feature/familia/presentation/pages/familia_page.dart';
import 'package:expense_splitter/src/feature/splitter/presentation/pages/splitter_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../feature/dashboard/presentation/pages/dashboard_page.dart';
import '../../../feature/self/presentation/pages/self_page.dart';

class HomeRoutes {
  static const String splitterPage = '/splitter-page';
  static const String familiaPage = '/familia-page';
  static const String dashBoardPage = '/dashboard-page';
  static const String selfPage = '/self-page';

  static final routes = <GoRoute>[
    GoRoute(
      path: splitterPage,
      pageBuilder: (context, state) => MaterialPage(child: SplitterPage()),
    ),
    GoRoute(path: familiaPage, builder: (context, state) => FamiliaPage()),
    GoRoute(
      path: dashBoardPage,
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(path: selfPage, builder: (context, state) => const SelfPage()),
  ];
}
