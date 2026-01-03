part of 'trip_cubit.dart';

@immutable
abstract class TripState {}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripFriendsUpdated extends TripState {
  final List<FriendModel> friends;
  TripFriendsUpdated(this.friends);
}

class TripCreated extends TripState {
  final String tripId;
  TripCreated(this.tripId);
}

class TripError extends TripState {
  final String message;
  TripError(this.message);
}
