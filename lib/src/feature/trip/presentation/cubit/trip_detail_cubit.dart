import 'package:bloc/bloc.dart';
import 'package:expense_splitter/src/feature/expense/data/model/expense_model.dart';
import 'package:expense_splitter/src/feature/expense/data/repository/expense_repository.dart';
import 'package:expense_splitter/src/feature/trip/data/model/friend_model.dart';
import 'package:expense_splitter/src/feature/trip/data/model/trip_model.dart';
import 'package:expense_splitter/src/feature/trip/data/repository/trip_repository.dart';
import 'package:flutter/foundation.dart';

part 'trip_detail_state.dart';

class TripDetailCubit extends Cubit<TripDetailState> {
  final TripRepository _tripRepository;
  final ExpenseRepository _expenseRepository;
  final String tripId;

  TripDetailCubit({
    required TripRepository tripRepository,
    required ExpenseRepository expenseRepository,
    required this.tripId,
  }) : _tripRepository = tripRepository,
       _expenseRepository = expenseRepository,
       super(TripDetailInitial());

  Future<void> loadDetails() async {
    emit(TripDetailLoading());
    try {
      final trip = await _tripRepository.getTrip(tripId);
      final friends = await _tripRepository.getFriends(tripId);
      final expenses = await _expenseRepository.getExpenses(tripId);

      // Calculate summary data
      double totalExpenses = 0;
      final paidByPerson = <String, double>{};
      for (var friend in friends) {
        paidByPerson[friend.id] = 0.0;
      }
      for (var expense in expenses) {
        totalExpenses += expense.amount;
        paidByPerson[expense.paidByUserId] =
            (paidByPerson[expense.paidByUserId] ?? 0) + expense.amount;
      }
      final fairShare = friends.isNotEmpty
          ? totalExpenses / friends.length
          : 0.0;

      emit(
        TripDetailLoaded(
          trip: trip,
          friends: friends,
          expenses: expenses,
          settlements: _calculateSettlements(friends, expenses),
          totalExpenses: totalExpenses,
          fairShare: fairShare,
          paidByPerson: paidByPerson,
        ),
      );
    } catch (e) {
      emit(TripDetailError(e.toString()));
    }
  }

  List<String> _calculateSettlements(
    List<FriendModel> friends,
    List<ExpenseModel> expenses,
  ) {
    if (friends.isEmpty || expenses.isEmpty) return [];

    // Step 1: Calculate total expenses
    double totalExpenses = 0;
    for (var expense in expenses) {
      totalExpenses += expense.amount;
    }

    // Step 2: Calculate fair share per person
    final fairShare = totalExpenses / friends.length;

    // Step 3: Calculate how much each person paid
    final paidByPerson = <String, double>{};
    for (var friend in friends) {
      paidByPerson[friend.id] = 0.0;
    }
    for (var expense in expenses) {
      paidByPerson[expense.paidByUserId] =
          (paidByPerson[expense.paidByUserId] ?? 0) + expense.amount;
    }

    // Step 4: Calculate balance for each person (what they paid - fair share)
    final balances = <String, double>{};
    for (var friend in friends) {
      balances[friend.id] = (paidByPerson[friend.id] ?? 0) - fairShare;
    }

    // Step 5: Generate settlement transactions
    final settlements = <String>[];
    final debtors = balances.keys.where((k) => balances[k]! < -0.01).toList();
    final creditors = balances.keys.where((k) => balances[k]! > 0.01).toList();

    // Sort to optimize matching
    debtors.sort(
      (a, b) => balances[a]!.compareTo(balances[b]!),
    ); // Ascending (most negative first)
    creditors.sort(
      (a, b) => balances[b]!.compareTo(balances[a]!),
    ); // Descending (most positive first)

    int i = 0; // debtor index
    int j = 0; // creditor index

    while (i < debtors.length && j < creditors.length) {
      final debtor = debtors[i];
      final creditor = creditors[j];

      final debtAmount = -balances[debtor]!; // How much debtor owes
      final creditAmount = balances[creditor]!; // How much creditor is owed

      final amount = debtAmount < creditAmount ? debtAmount : creditAmount;

      final debtorName = friends.firstWhere((f) => f.id == debtor).name;
      final creditorName = friends.firstWhere((f) => f.id == creditor).name;

      settlements.add(
        "$debtorName should pay $creditorName: ${amount.toStringAsFixed(2)}",
      );

      balances[debtor] = balances[debtor]! + amount;
      balances[creditor] = balances[creditor]! - amount;

      if (balances[debtor]!.abs() < 0.01) i++;
      if (balances[creditor]!.abs() < 0.01) j++;
    }

    return settlements;
  }
}
