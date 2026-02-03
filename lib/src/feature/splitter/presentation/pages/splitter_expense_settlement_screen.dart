import 'package:expense_splitter/src/core/theme/theme.dart';
import 'package:expense_splitter/src/core/widgets/animated_card.dart';
import 'package:expense_splitter/src/core/widgets/animated_gradient_button.dart';
import 'package:expense_splitter/src/feature/splitter/data/model/splitter_expense_model.dart';
import 'package:expense_splitter/src/feature/splitter/data/repository/splitter_expense_repository.dart';
import 'package:expense_splitter/src/feature/trip/data/model/friend_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class SplitterExpenseSettlementScreen extends StatefulWidget {
  final String tripId;
  final List<FriendModel> friends;

  const SplitterExpenseSettlementScreen({
    super.key,
    required this.tripId,
    required this.friends,
  });

  @override
  State<SplitterExpenseSettlementScreen> createState() =>
      _SplitterExpenseSettlementScreenState();
}

class _SplitterExpenseSettlementScreenState
    extends State<SplitterExpenseSettlementScreen> {
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
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Please enter a description'),
            ],
          ),
          backgroundColor: AppTheme.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Collect all non-empty amounts
    final expenses = <SplitterExpenseModel>[];
    for (var friend in widget.friends) {
      final amountText = _amountControllers[friend.id]!.text.trim();
      if (amountText.isNotEmpty) {
        final amount = double.tryParse(amountText);
        if (amount != null && amount > 0) {
          expenses.add(
            SplitterExpenseModel(
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
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Please enter at least one amount'),
            ],
          ),
          backgroundColor: AppTheme.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = SplitterExpenseRepository();
      for (var expense in expenses) {
        await repo.addExpense(expense);
      }
      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Expenses',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enter amounts for each person',
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
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Description Field
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'e.g., Dinner, Hotel, Transport',
                            prefixIcon: Icon(
                              Icons.description_rounded,
                              color: AppTheme.premiumPurple,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Icon(
                            Icons.people_rounded,
                            color: AppTheme.premiumPurple,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Amounts by Person',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Friends List
                      ...widget.friends.asMap().entries.map((entry) {
                        final index = entry.key;
                        final friend = entry.value;
                        return AnimatedCard(
                          index: index,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
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
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          friend.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller:
                                              _amountControllers[friend.id],
                                          decoration: InputDecoration(
                                            hintText: '0.00',
                                            prefixIcon: Icon(
                                              Icons.attach_money_rounded,
                                              color: AppTheme.premiumPurple,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme.lightLavender,
                                                width: 1.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme.lightLavender,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: AppTheme.premiumPurple,
                                                width: 2.5,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: isDark
                                                ? AppTheme.midnightBlue
                                                : AppTheme.softLavender
                                                      .withAlpha(77),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 14,
                                                ),
                                          ),
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Save Button
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: AnimatedGradientButton(
                  text: 'Save All Expenses',
                  icon: Icons.save_rounded,
                  onPressed: _isLoading ? null : _saveExpenses,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
