import 'package:expense_splitter/src/feature/expense/data/model/expense_model.dart';
import 'package:expense_splitter/src/feature/expense/data/repository/expense_repository.dart';
import 'package:expense_splitter/src/feature/trip/data/model/friend_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class BulkExpenseScreen extends StatefulWidget {
  final String tripId;
  final List<FriendModel> friends;

  const BulkExpenseScreen({
    super.key,
    required this.tripId,
    required this.friends,
  });

  @override
  State<BulkExpenseScreen> createState() => _BulkExpenseScreenState();
}

class _BulkExpenseScreenState extends State<BulkExpenseScreen> {
  final _descriptionController = TextEditingController();
  final Map<String, TextEditingController> _amountControllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (var friend in widget.friends) {
      _amountControllers[friend.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    for (var controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveExpenses() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    // Collect all non-empty amounts
    final expenses = <ExpenseModel>[];
    for (var friend in widget.friends) {
      final amountText = _amountControllers[friend.id]!.text.trim();
      if (amountText.isNotEmpty) {
        final amount = double.tryParse(amountText);
        if (amount != null && amount > 0) {
          expenses.add(
            ExpenseModel(
              id: const Uuid().v4(),
              tripId: widget.tripId,
              description: _descriptionController.text,
              amount: amount,
              paidByUserId: friend.id,
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    }

    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one amount')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ExpenseRepository();
      for (var expense in expenses) {
        await repo.addExpense(expense);
      }
      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expenses (Bulk)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Dinner, Hotel, Transport',
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter amount paid by each person:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: widget.friends.length,
                itemBuilder: (context, index) {
                  final friend = widget.friends[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _amountControllers[friend.id],
                      decoration: InputDecoration(
                        labelText: friend.name,
                        hintText: '0',
                        prefixIcon: CircleAvatar(
                          child: Text(friend.name[0].toUpperCase()),
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isLoading ? null : _saveExpenses,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save All Expenses'),
            ),
          ],
        ),
      ),
    );
  }
}
