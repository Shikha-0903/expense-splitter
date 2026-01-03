import 'package:expense_splitter/src/core/theme/theme.dart';
import 'package:expense_splitter/src/feature/expense/presentation/pages/bulk_expense_screen.dart';

import 'package:expense_splitter/src/feature/trip/presentation/cubit/trip_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_splitter/src/feature/expense/data/repository/expense_repository.dart';
import 'package:expense_splitter/src/feature/trip/data/repository/trip_repository.dart';

class TripDetailScreen extends StatelessWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripDetailCubit(
        tripRepository: TripRepository(),
        expenseRepository: ExpenseRepository(),
        tripId: tripId,
      )..loadDetails(),
      child: const _TripDetailView(),
    );
  }
}

class _TripDetailView extends StatelessWidget {
  const _TripDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripDetailCubit, TripDetailState>(
      builder: (context, state) {
        if (state is TripDetailLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is TripDetailError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.message)),
          );
        } else if (state is TripDetailLoaded) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text(state.trip.name),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: "Expenses"),
                    Tab(text: "Settlements"),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _ExpensesTab(state: state),
                  _SettlementsTab(state: state),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BulkExpenseScreen(
                        tripId: state.trip.id,
                        friends: state.friends,
                      ),
                    ),
                  );
                  if (result == true && context.mounted) {
                    context.read<TripDetailCubit>().loadDetails();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Expenses'),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ExpensesTab extends StatelessWidget {
  final TripDetailLoaded state;
  const _ExpensesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.expenses.isEmpty) {
      return Center(
        child: Text(
          "No expenses yet",
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    return ListView.builder(
      itemCount: state.expenses.length,
      itemBuilder: (context, index) {
        final expense = state.expenses[index];
        final paidBy = state.friends
            .firstWhere(
              (f) => f.id == expense.paidByUserId,
              orElse: () => state.friends.first, // Fallback safely
            )
            .name;

        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppTheme.softLavender,
            child: Icon(Icons.receipt, color: AppTheme.deepLavender),
          ),
          title: Text(expense.description),
          subtitle: Text("Paid by $paidBy"),
          trailing: Text(
            "${state.trip.currency} ${expense.amount.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      },
    );
  }
}

class _SettlementsTab extends StatelessWidget {
  final TripDetailLoaded state;
  const _SettlementsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Total Expense Card
        Card(
          color: AppTheme.softLavender,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Expenses',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.trip.currency} ${state.totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepLavender,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fair share per person: ${state.trip.currency} ${state.fairShare.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Individual Payments
        const Text(
          'Individual Payments',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...state.friends.map((friend) {
          final paid = state.paidByPerson[friend.id] ?? 0.0;
          final balance = paid - state.fairShare;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: balance >= 0
                    ? Colors.green[100]
                    : Colors.red[100],
                child: Text(
                  friend.name[0].toUpperCase(),
                  style: TextStyle(
                    color: balance >= 0 ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(friend.name),
              subtitle: Text(
                balance >= 0
                    ? 'Should receive ${state.trip.currency} ${balance.toStringAsFixed(2)}'
                    : 'Should pay ${state.trip.currency} ${(-balance).toStringAsFixed(2)}',
                style: TextStyle(
                  color: balance >= 0 ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Text(
                '${state.trip.currency} ${paid.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),

        if (state.settlements.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Settlement Plan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...state.settlements.map((settlement) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.monetization_on_outlined,
                  color: Colors.green,
                ),
                title: Text(
                  settlement,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ] else ...[
          const SizedBox(height: 24),
          Center(
            child: Text(
              "All settled up!",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
        ],
        const SizedBox(height: 80), // Extra space for FAB
      ],
    );
  }
}
