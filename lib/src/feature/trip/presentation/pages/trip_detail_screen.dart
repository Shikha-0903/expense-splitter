import 'package:expense_splitter/src/core/theme/theme.dart';
import 'package:expense_splitter/src/core/widgets/animated_card.dart';
import 'package:expense_splitter/src/core/widgets/animated_icon_button.dart';
import 'package:expense_splitter/src/core/widgets/pull_to_refresh_wrapper.dart';
import 'package:expense_splitter/src/feature/splitter/presentation/pages/splitter_expense_settlement_screen.dart';
import 'package:expense_splitter/src/feature/trip/presentation/cubit/trip_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_splitter/src/feature/splitter/data/repository/splitter_expense_repository.dart';
import 'package:expense_splitter/src/feature/trip/data/repository/trip_repository.dart';

class TripDetailScreen extends StatelessWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripDetailCubit(
        tripRepository: TripRepository(),
        expenseRepository: SplitterExpenseRepository(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<TripDetailCubit, TripDetailState>(
      builder: (context, state) {
        if (state is TripDetailLoading) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.charcoalBlack, AppTheme.midnightBlue],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.offWhite,
                          AppTheme.softLavender.withAlpha(77),
                        ],
                      ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is TripDetailError) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.charcoalBlack, AppTheme.midnightBlue],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.offWhite,
                          AppTheme.softLavender.withAlpha(77),
                        ],
                      ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.errorRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is TripDetailLoaded) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.charcoalBlack,
                            AppTheme.midnightBlue,
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.offWhite,
                            AppTheme.softLavender.withAlpha(77),
                          ],
                        ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Premium Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Expanded(
                              child: Text(
                                state.trip.name,
                                style: Theme.of(context).textTheme.displaySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Premium Tabs
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: isDark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          tabs: const [
                            Tab(text: "Expenses"),
                            Tab(text: "Settlements"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _ExpensesTab(state: state),
                            _SettlementsTab(state: state),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: AnimatedIconButton(
                icon: Icons.add_rounded,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SplitterExpenseSettlementScreen(
                        tripId: state.trip.id,
                        friends: state.friends,
                      ),
                    ),
                  );
                  if (result == true && context.mounted) {
                    context.read<TripDetailCubit>().loadDetails();
                  }
                },
                tooltip: 'Add Expenses',
                size: 64,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (state.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.softLavender, AppTheme.lightLavender],
                ),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: AppTheme.deepLavender,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No expenses yet",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Add your first expense to get started",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    return PullToRefreshWrapper(
      onRefresh: () async {
        context.read<TripDetailCubit>().loadDetails();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: state.expenses.length,
        itemBuilder: (context, index) {
          final expense = state.expenses[index];
          final paidBy = state.friends
              .firstWhere(
                (f) => f.id == expense.paidByUserId,
                orElse: () => state.friends.first,
              )
              .name;

          return AnimatedCard(
            index: index,
            margin: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.receipt_rounded, color: Colors.white),
                ),
                title: Text(
                  expense.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "Paid by $paidBy",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.softLavender,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${state.trip.currency} ${expense.amount.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.premiumPurple,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SettlementsTab extends StatelessWidget {
  final TripDetailLoaded state;
  const _SettlementsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PullToRefreshWrapper(
      onRefresh: () async {
        context.read<TripDetailCubit>().loadDetails();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // Total Expense Card
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.premiumShadow,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(51),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Total Expenses',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Colors.white.withAlpha(230),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: state.totalExpenses),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOutCubic,
                            builder: (context, animatedValue, child) {
                              return Text(
                                '${state.trip.currency} ${animatedValue.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Fair share per person: ${state.trip.currency} ${state.fairShare.toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Individual Payments
          Row(
            children: [
              Icon(
                Icons.people_rounded,
                color: AppTheme.premiumPurple,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Individual Payments',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...state.friends.asMap().entries.map((entry) {
            final index = entry.key;
            final friend = entry.value;
            final paid = state.paidByPerson[friend.id] ?? 0.0;
            final balance = paid - state.fairShare;
            final isPositive = balance >= 0;
            return AnimatedCard(
              index: index,
              margin: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPositive
                            ? [
                                AppTheme.successGreen,
                                AppTheme.successGreen.withAlpha(179),
                              ]
                            : [
                                AppTheme.errorRed,
                                AppTheme.errorRed.withAlpha(179),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        friend.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    friend.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      isPositive
                          ? 'Should receive ${state.trip.currency} ${balance.toStringAsFixed(2)}'
                          : 'Should pay ${state.trip.currency} ${(-balance).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isPositive
                            ? AppTheme.successGreen
                            : AppTheme.errorRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? AppTheme.successGreen.withAlpha(26)
                          : AppTheme.errorRed.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.trip.currency} ${paid.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPositive
                            ? AppTheme.successGreen
                            : AppTheme.errorRed,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

          if (state.settlements.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Divider(height: 1),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  Icons.payment_rounded,
                  color: AppTheme.premiumPurple,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Settlement Plan',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...state.settlements.asMap().entries.map((entry) {
              final index = entry.key;
              final settlement = entry.value;
              return AnimatedCard(
                index: index,
                margin: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                    border: Border.all(
                      color: AppTheme.successGreen.withAlpha(77),
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.monetization_on_rounded,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    title: Text(
                      settlement,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.successGreen.withAlpha(51),
                          AppTheme.successGreen.withAlpha(26),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 48,
                      color: AppTheme.successGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "All settled up!",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Everyone has paid their fair share",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
