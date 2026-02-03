import 'package:expense_splitter/src/core/router/all/auth_routes.dart';
import 'package:expense_splitter/src/core/router/all/home_routes.dart';
import 'package:expense_splitter/src/core/router/all/trip_routes.dart';
import 'package:expense_splitter/src/core/widgets/auth_gate.dart';
import 'package:expense_splitter/src/feature/shell/presentation/pages/main_shell.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: AuthRoutes.loginPage,
  redirect: (context, state) {
    // The AuthGate will handle the actual redirects based on auth state
    return null;
  },
  routes: [
    ...AuthRoutes.routes,
    ...TripRoutes.routes,
    ShellRoute(
      builder: (context, state, child) =>
          AuthGate(child: MainShell(child: child)),
      routes: HomeRoutes.routes,
    ),
  ],
);
