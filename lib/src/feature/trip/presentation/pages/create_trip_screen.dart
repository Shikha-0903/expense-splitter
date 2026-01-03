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
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Trip')),
      body: BlocConsumer<TripCubit, TripState>(
        listener: (context, state) {
          if (state is TripError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TripCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Trip Created Successfully!')),
            );
            context.pop(); // Go back to homepage
          }
        },
        builder: (context, state) {
          final friends = context.read<TripCubit>().friends;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Trip Name',
                      hintText: 'e.g. Goa Trip 2024',
                      prefixIcon: Icon(Icons.flight_takeoff),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    items: _currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCurrency = val!),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Trip Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? _formatDate(_selectedDate!)
                            : 'Select date',
                        style: TextStyle(
                          color: _selectedDate != null
                              ? null
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Friends',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _friendController,
                          decoration: const InputDecoration(
                            hintText: 'Add friend name',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () {
                          context.read<TripCubit>().addFriend(
                            _friendController.text,
                          );
                          _friendController.clear();
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: friends.isEmpty
                        ? Center(
                            child: Text(
                              'No friends added yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            itemCount: friends.length,
                            itemBuilder: (context, index) {
                              final friend = friends[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(friend.name[0].toUpperCase()),
                                  ),
                                  title: Text(friend.name),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => context
                                        .read<TripCubit>()
                                        .removeFriend(friend.id),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: state is TripLoading
                        ? null
                        : () {
                            context.read<TripCubit>().createTrip(
                              _nameController.text,
                              _selectedCurrency,
                              _selectedDate,
                            );
                          },
                    child: state is TripLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create Trip'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
