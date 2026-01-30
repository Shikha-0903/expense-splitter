import 'package:expense_splitter/src/core/theme/theme.dart';
import 'package:expense_splitter/src/core/widgets/animated_card.dart';
import 'package:expense_splitter/src/core/widgets/animated_gradient_button.dart';
import 'package:expense_splitter/src/core/widgets/contacts_picker_sheet.dart';
import 'package:expense_splitter/src/feature/trip/presentation/cubit/trip_cubit.dart';
import 'package:expense_splitter/src/feature/trip/data/repository/trip_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateTripScreen extends StatelessWidget {
  const CreateTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripCubit(TripRepository()),
      child: const _CreateTripView(),
    );
  }
}

class _CreateTripView extends StatefulWidget {
  const _CreateTripView();

  @override
  State<_CreateTripView> createState() => _CreateTripViewState();
}

class _CreateTripViewState extends State<_CreateTripView> {
  final _nameController = TextEditingController();
  final _friendController = TextEditingController();
  String _selectedCurrency = 'USD';
  DateTime? _selectedDate;
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'INR', 'JPY'];

  @override
  void dispose() {
    _nameController.dispose();
    _friendController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
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
          child: BlocConsumer<TripCubit, TripState>(
            listener: (context, state) {
              if (state is TripError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text(state.message)),
                      ],
                    ),
                    backgroundColor: AppTheme.errorRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } else if (state is TripCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Trip Created Successfully!'),
                      ],
                    ),
                    backgroundColor: AppTheme.successGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                context.pop();
              }
            },
            builder: (context, state) {
              final friends = context.read<TripCubit>().friends;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create New Trip',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set up your trip and add friends',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Trip Name
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Trip Name',
                          hintText: 'e.g. Goa Trip 2024',
                          prefixIcon: Icon(
                            Icons.flight_takeoff_rounded,
                            color: AppTheme.premiumPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Currency
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCurrency,
                        decoration: InputDecoration(
                          labelText: 'Currency',
                          prefixIcon: Icon(
                            Icons.attach_money_rounded,
                            color: AppTheme.premiumPurple,
                          ),
                        ),
                        items: _currencies
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCurrency = val!),
                      ),
                      const SizedBox(height: 20),
                      // Date Picker
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.lightLavender,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                color: AppTheme.premiumPurple,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Trip Date',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedDate != null
                                          ? _formatDate(_selectedDate!)
                                          : 'Select date',
                                      style: TextStyle(
                                        color: _selectedDate != null
                                            ? null
                                            : Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Friends Section
                      Row(
                        children: [
                          Icon(
                            Icons.people_rounded,
                            color: AppTheme.premiumPurple,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Friends',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _friendController,
                                decoration: InputDecoration(
                                  hintText: 'Add friend name',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    context.read<TripCubit>().addFriend(value);
                                    _friendController.clear();
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              tooltip: 'Pick from contacts',
                              onPressed: () async {
                                final name = await ContactsPickerSheet.pickName(
                                  context,
                                );
                                if (name != null && name.trim().isNotEmpty) {
                                  if (context.mounted) {
                                    context.read<TripCubit>().addFriend(name);
                                  }
                                }
                              },
                              icon: Icon(
                                Icons.contact_page_rounded,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  if (_friendController.text.isNotEmpty) {
                                    context.read<TripCubit>().addFriend(
                                      _friendController.text,
                                    );
                                    _friendController.clear();
                                  }
                                },
                                icon: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Friends List
                      Container(
                        constraints: const BoxConstraints(maxHeight: 250),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: friends.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(32),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0.0, end: 1.0),
                                        duration: const Duration(
                                          milliseconds: 800,
                                        ),
                                        curve: Curves.elasticOut,
                                        builder: (context, value, child) {
                                          return Transform.scale(
                                            scale: value,
                                            child: Icon(
                                              Icons.person_add_outlined,
                                              size: 48,
                                              color: isDark
                                                  ? Colors.grey[500]
                                                  : Colors.grey[400],
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No friends added yet',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(8),
                                itemCount: friends.length,
                                itemBuilder: (context, index) {
                                  final friend = friends[index];
                                  return AnimatedCard(
                                    index: index,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppTheme.midnightBlue
                                            : AppTheme.softLavender,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 4,
                                            ),
                                        leading: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: AppTheme.primaryGradient,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              friend.name[0].toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          friend.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_rounded,
                                            color: AppTheme.errorRed,
                                          ),
                                          onPressed: () => context
                                              .read<TripCubit>()
                                              .removeFriend(friend.id),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 32),
                      // Create Button
                      AnimatedGradientButton(
                        text: 'Create Trip',
                        icon: Icons.flight_takeoff_rounded,
                        onPressed: state is TripLoading
                            ? null
                            : () {
                                context.read<TripCubit>().createTrip(
                                  _nameController.text,
                                  _selectedCurrency,
                                  _selectedDate,
                                );
                              },
                        isLoading: state is TripLoading,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
