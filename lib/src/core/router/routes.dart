import 'package:expense_splitter/src/core/router/all/trip_routes.dart';
import 'package:expense_splitter/src/core/router/all/home_routes.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home-page',
  routes: [...HomeRoutes.routes, ...TripRoutes.routes],
);
