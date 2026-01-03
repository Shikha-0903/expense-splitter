part of 'trip_detail_cubit.dart';

@immutable
abstract class TripDetailState {}

class TripDetailInitial extends TripDetailState {}

class TripDetailLoading extends TripDetailState {}

class TripDetailLoaded extends TripDetailState {
  final TripModel trip;
  final List<FriendModel> friends;
  final List<ExpenseModel> expenses;
  final List<String> settlements;
  final double totalExpenses;
  final double fairShare;
  final Map<String, double> paidByPerson;

  TripDetailLoaded({
    required this.trip,
    required this.friends,
    required this.expenses,
    required this.settlements,
    required this.totalExpenses,
    required this.fairShare,
    required this.paidByPerson,
  });
}

class TripDetailError extends TripDetailState {
  final String message;
  TripDetailError(this.message);
}
