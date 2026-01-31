part of 'home_cubit.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<TripModel> trips;
  final Map<String, double> expenseTotals; // tripId -> total expenses
  HomeLoaded(this.trips, this.expenseTotals);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
