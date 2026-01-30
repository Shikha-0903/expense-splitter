import 'package:expense_splitter/src/core/router/all/trip_routes.dart';
import 'package:expense_splitter/src/feature/dashboard/presentation/pages/dashboard_page.dart';
import 'package:expense_splitter/src/feature/home/presentation/pages/home_page.dart';
import 'package:expense_splitter/src/feature/shell/presentation/pages/main_shell.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/app/home',
  routes: [
    // Backwards-compatible redirects (older builds / deep links)
    GoRoute(path: '/', redirect: (context, state) => '/app/home'),
    GoRoute(path: '/home-page', redirect: (context, state) => '/app/search'),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/app/home',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/app/search',
          builder: (context, state) => const HomePage(),
        ),
      ],
    ),
    ...TripRoutes.routes,
  ],
);
