import 'package:bloc/bloc.dart';
import 'package:expense_splitter/src/feature/trip/data/model/friend_model.dart';
import 'package:expense_splitter/src/feature/trip/data/model/trip_model.dart';
import 'package:expense_splitter/src/feature/trip/data/repository/trip_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

part 'trip_state.dart';

class TripCubit extends Cubit<TripState> {
  final TripRepository _repository;

  TripCubit(this._repository) : super(TripInitial());

  final List<FriendModel> _friends = [];

  List<FriendModel> get friends => List.unmodifiable(_friends);

  void addFriend(String name) {
    if (name.trim().isEmpty) return;
    final friend = FriendModel(
      id: const Uuid().v4(),
      name: name,
      tripId: '', // verify this later
    );
    _friends.add(friend);
    emit(TripFriendsUpdated(List.from(_friends)));
  }

  void removeFriend(String id) {
    _friends.removeWhere((f) => f.id == id);
    emit(TripFriendsUpdated(List.from(_friends)));
  }

  Future<void> createTrip(
    String name,
    String currency,
    DateTime? tripDate,
  ) async {
    if (name.isEmpty) {
      emit(TripError("Trip name is required"));
      return;
    }
    if (_friends.isEmpty) {
      emit(TripError("Add at least one friend"));
      return;
    }

    emit(TripLoading());
    try {
      final tripId = const Uuid().v4();
      final trip = TripModel(
        id: tripId,
        name: name,
        currency: currency,
        createdAt: DateTime.now(),
        tripDate: tripDate,
      );

      // Create trip first
      final createdTripId = await _repository.createTrip(trip);

      // Update friends with tripId and add them
      final friendsWithTripId = _friends
          .map(
            (f) => FriendModel(id: f.id, name: f.name, tripId: createdTripId),
          )
          .toList();

      await _repository.addFriends(friendsWithTripId);

      emit(TripCreated(createdTripId));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }
}
