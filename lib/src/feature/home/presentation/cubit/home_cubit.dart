import 'package:bloc/bloc.dart';
import 'package:expense_splitter/src/feature/trip/data/model/trip_model.dart';
import 'package:expense_splitter/src/feature/trip/data/repository/trip_repository.dart';
import 'package:flutter/foundation.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final TripRepository _repository;

  HomeCubit(this._repository) : super(HomeInitial());

  Future<void> fetchTrips() async {
    emit(HomeLoading());
    try {
      final trips = await _repository.getTrips();

      // Fetch expense totals for each trip
      final expenseTotals = <String, double>{};
      for (var trip in trips) {
        final expenses = await _repository.getExpenses(trip.id);
        double total = 0;
        for (var expense in expenses) {
          total += expense.amount;
        }
        expenseTotals[trip.id] = total;
      }

      emit(HomeLoaded(trips, expenseTotals));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
