import 'package:bloc/bloc.dart';
import 'package:expense_splitter/src/feature/trip/data/model/trip_model.dart';
import 'package:expense_splitter/src/feature/trip/data/repository/trip_repository.dart';
import 'package:flutter/foundation.dart';

part 'splitter_state.dart';

class SplitterCubit extends Cubit<SplitterState> {
  final TripRepository _repository;

  SplitterCubit(this._repository) : super(SplitterInitial());

  Future<void> fetchTrips() async {
    emit(SplitterLoading());
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

      emit(SplitterLoaded(trips, expenseTotals));
    } catch (e) {
      emit(SplitterError(e.toString()));
    }
  }
}
