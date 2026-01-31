// Legacy route holder (kept for compatibility; app now uses /app/* shell routes).
import 'package:expense_splitter/src/feature/splitter/presentation/pages/splitter_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplitterRoutes {
  static const String homePage = '/splitter-page';

  static final routes = <GoRoute>[
    GoRoute(
      path: homePage,
      pageBuilder: (context, state) => MaterialPage(child: SplitterPage()),
    ),
  ];
}
