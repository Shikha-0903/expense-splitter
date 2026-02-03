part of 'splitter_cubit.dart';

@immutable
abstract class SplitterState {}

class SplitterInitial extends SplitterState {}

class SplitterLoading extends SplitterState {}

class SplitterLoaded extends SplitterState {
  final List<TripModel> trips;
  final Map<String, double> expenseTotals; // tripId -> total expenses
  SplitterLoaded(this.trips, this.expenseTotals);
}

class SplitterError extends SplitterState {
  final String message;
  SplitterError(this.message);
}
