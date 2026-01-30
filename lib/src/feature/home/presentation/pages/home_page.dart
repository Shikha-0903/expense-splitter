import 'package:expense_splitter/src/core/theme/theme.dart';
import 'package:expense_splitter/src/core/widgets/animated_card.dart';
import 'package:expense_splitter/src/core/widgets/animated_icon_button.dart';
import 'package:expense_splitter/src/core/widgets/pull_to_refresh_wrapper.dart';
import 'package:expense_splitter/src/core/widgets/shimmer_loading.dart';
import 'package:expense_splitter/src/feature/home/presentation/cubit/home_cubit.dart';
import 'package:expense_splitter/src/feature/trip/data/repository/trip_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = HomeCubit(TripRepository())..fetchTrips();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: _cubit, child: const _HomeView());
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTripDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        child: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppTheme.primaryGradient.createShader(bounds),
                            child: Text(
                              "Expense Splitter",
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Manage your shared expenses",
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: 5,
                        itemBuilder: (context, index) => const ShimmerCard(),
                      ),
                    ),
                  ],
                );
              } else if (state is HomeError) {
                return Center(
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
                        "Error: ${state.message}",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                );
              } else if (state is HomeLoaded) {
                final filteredTrips = state.trips.where((trip) {
                  return trip.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
                }).toList();

                return Column(
                  children: [
                    // Premium Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppTheme.primaryGradient.createShader(bounds),
                            child: Text(
                              "Expense Splitter",
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Manage your shared expenses",
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Premium Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: AppTheme.cardShadow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search trips...',
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: isDark
                                  ? AppTheme.classicLavender
                                  : AppTheme.deepLavender,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: PullToRefreshWrapper(
                        onRefresh: () async {
                          context.read<HomeCubit>().fetchTrips();
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                        },
                        backgroundColor: isDark
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        child: filteredTrips.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.softLavender,
                                            AppTheme.lightLavender,
                                          ],
                                        ),
                                      ),
                                      child: Icon(
                                        _searchQuery.isEmpty
                                            ? Icons.airport_shuttle_rounded
                                            : Icons.search_off_rounded,
                                        size: 64,
                                        color: AppTheme.deepLavender,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      _searchQuery.isEmpty
                                          ? "No trips found"
                                          : "No trips match your search",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _searchQuery.isEmpty
                                          ? "Create a new trip to get started!"
                                          : "Try a different search term",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                itemCount: filteredTrips.length,
                                itemBuilder: (context, index) {
                                  final trip = filteredTrips[index];
                                  final totalExpense =
                                      state.expenseTotals[trip.id] ?? 0.0;
                                  return AnimatedCard(
                                    index: index,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    onTap: () async {
                                      await context.push('/trip/${trip.id}');
                                      if (context.mounted) {
                                        context.read<HomeCubit>().fetchTrips();
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: AppTheme.cardShadow,
                                        gradient: isDark
                                            ? AppTheme.darkCardGradient
                                            : AppTheme.cardGradient,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          children: [
                                            Hero(
                                              tag: 'trip_${trip.id}',
                                              child: Container(
                                                width: 64,
                                                height: 64,
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      AppTheme.primaryGradient,
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppTheme
                                                          .premiumPurple
                                                          .withAlpha(77),
                                                      blurRadius: 12,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    trip.currency,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    trip.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  if (trip.tripDate != null)
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .calendar_today_rounded,
                                                          size: 14,
                                                          color: isDark
                                                              ? Colors.grey[400]
                                                              : Colors
                                                                    .grey[600],
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          _formatTripDate(
                                                            trip.tripDate!,
                                                          ),
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                color: isDark
                                                                    ? Colors
                                                                          .grey[400]
                                                                    : Colors
                                                                          .grey[600],
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  if (totalExpense > 0) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "${trip.currency} ${totalExpense.toStringAsFixed(2)}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppTheme
                                                                .premiumPurple,
                                                          ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 18,
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        // This ensures the FAB doesn't overlap the custom bottom nav in MainShell.
        padding: const EdgeInsets.only(bottom: 88),
        child: AnimatedIconButton(
          icon: Icons.add_rounded,
          onPressed: () async {
            await context.push('/create-trip');
            if (context.mounted) {
              context.read<HomeCubit>().fetchTrips();
            }
          },
          tooltip: 'Create New Trip',
          size: 64,
        ),
      ),
      // Lift the FAB above the shell's bottom navigation.
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
