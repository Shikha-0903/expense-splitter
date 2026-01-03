import 'package:expense_splitter/src/feature/trip/presentation/pages/create_trip_screen.dart';
import 'package:expense_splitter/src/feature/trip/presentation/pages/trip_detail_screen.dart';
import 'package:go_router/go_router.dart';

class TripRoutes {
  static final routes = [
    GoRoute(
      path: '/create-trip',
      builder: (context, state) => const CreateTripScreen(),
    ),
    GoRoute(
      path: '/trip/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TripDetailScreen(tripId: id);
      },
    ),
  ];
}
