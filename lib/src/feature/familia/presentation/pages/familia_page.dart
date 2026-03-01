import 'package:expense_splitter/src/core/theme/theme.dart';
import 'package:expense_splitter/src/core/widgets/animated_card.dart';
import 'package:expense_splitter/src/core/widgets/animated_gradient_button.dart';
import 'package:expense_splitter/src/feature/familia/data/model/family_expense_model.dart';
import 'package:expense_splitter/src/feature/familia/data/model/family_member_model.dart';
import 'package:expense_splitter/src/feature/familia/data/model/family_model.dart';
import 'package:expense_splitter/src/feature/familia/data/repository/familia_repository.dart';
import 'package:expense_splitter/src/feature/familia/presentation/cubit/familia_cubit.dart';
import 'package:expense_splitter/src/feature/familia/presentation/cubit/familia_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class FamiliaPage extends StatefulWidget {
  const FamiliaPage({super.key});

  @override
  State<FamiliaPage> createState() => _FamiliaPageState();
}

class _FamiliaPageState extends State<FamiliaPage> {
  late final FamiliaCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = FamiliaCubit(FamiliaRepository())..init();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: BlocBuilder<FamiliaCubit, FamiliaState>(
          builder: (context, state) {
            if (state is FamiliaLoading) {
              return _buildLoading();
            }

            if (state is FamiliaError) {
              return Center(child: Text("Error: ${state.message}"));
            }

            if (state is FamiliaNoFamily) {
              return _CreateFamilyView();
            }

            if (state is FamiliaLoaded) {
              return _FamilyDashboardView(
                family: state.family,
                members: state.members,
                expenses: state.expenses,
              );
            }

            return _buildLoading();
          },
        ),
        floatingActionButton: BlocBuilder<FamiliaCubit, FamiliaState>(
          builder: (context, state) {
            if (state is FamiliaLoaded) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 88),
                child: FloatingActionButton.extended(
                  onPressed: () =>
                      _showAddExpenseSheet(context, state.family.id),
                  label: const Text("Add Expense"),
                  icon: const Icon(Icons.add),
                  backgroundColor: AppTheme.premiumPurple,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(height: 100, color: Colors.white),
        ),
      ),
    );
  }

  void _showAddExpenseSheet(BuildContext context, String familyId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: _AddExpenseSheet(familyId: familyId),
      ),
    );
  }
}

class _FamilyDashboardView extends StatelessWidget {
  final FamilyModel family;
  final List<FamilyMemberModel> members;
  final List<FamilyExpenseModel> expenses;

  const _FamilyDashboardView({
    required this.family,
    required this.members,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final totalSpent = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          family.name,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Monthly Overview",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.group_outlined),
                      onPressed: () => _showMembersList(context),
                      tooltip: "View Members",
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTotalCard(context, totalSpent),
                const SizedBox(height: 32),
                if (expenses.isNotEmpty) ...[
                  Text(
                    "Spending Distribution",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSpendingChart(context),
                  const SizedBox(height: 32),
                  Text(
                    "Recent Family Expenses",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text("No expenses yet. Start adding!"),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final expense = expenses[index];
            final member = members.firstWhere(
              (m) => m.userId == expense.userId,
            );
            return AnimatedCard(
              index: index,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.premiumPurple.withAlpha(20),
                  child: Text(
                    expense.category.isNotEmpty ? expense.category[0] : 'G',
                    style: TextStyle(color: AppTheme.premiumPurple),
                  ),
                ),
                title: Text(expense.description ?? expense.category),
                subtitle: Text(
                  "Paid by ${member.profile?.displayName ?? 'Member'}",
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  "₹${expense.amount.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }, childCount: expenses.length),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildTotalCard(BuildContext context, double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.premiumPurple, AppTheme.premiumIndigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.premiumPurple.withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Family Spending",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "₹${total.toStringAsFixed(0)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Current Month",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingChart(BuildContext context) {
    Map<String, double> memberSpending = {};
    for (var member in members) {
      memberSpending[member.userId] = 0;
    }
    for (var expense in expenses) {
      memberSpending[expense.userId] =
          (memberSpending[expense.userId] ?? 0) + expense.amount;
    }

    final sortedSpending = memberSpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 40,
              sections: sortedSpending.map((entry) {
                final index = sortedSpending.indexOf(entry);
                final color = _getChartColor(index);
                return PieChartSectionData(
                  color: color,
                  value: entry.value,
                  title: '',
                  radius: 50,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: sortedSpending.map((entry) {
            final member = members.firstWhere((m) => m.userId == entry.key);
            final index = sortedSpending.indexOf(entry);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getChartColor(index),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${member.profile?.displayName ?? 'Member'}: ₹${entry.value.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getChartColor(int index) {
    final colors = [
      AppTheme.premiumPurple,
      AppTheme.premiumIndigo,
      Colors.teal,
      Colors.orange,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  void _showMembersList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<FamiliaCubit>(),
        child: _MembersModal(members: members, familyId: family.id),
      ),
    );
  }
}

class _MembersModal extends StatelessWidget {
  final List<FamilyMemberModel> members;
  final String familyId;
  const _MembersModal({required this.members, required this.familyId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.midnightBlue : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Family Members",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.person_add_rounded,
                    color: AppTheme.premiumPurple,
                  ),
                  onPressed: () => _showAddMemberSearch(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final profile = members[index].profile;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.premiumPurple.withAlpha(26),
                    backgroundImage:
                        profile?.avatarUrl != null &&
                            profile!.avatarUrl!.isNotEmpty
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child:
                        profile?.avatarUrl == null ||
                            profile!.avatarUrl!.isEmpty
                        ? Text((profile?.displayName ?? "?")[0].toUpperCase())
                        : null,
                  ),
                  title: Text(profile?.displayName ?? "Unknown"),
                  subtitle: Text(profile?.email ?? ""),
                  trailing: index == 0
                      ? const Text(
                          "Owner",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<FamiliaCubit>(),
        child: _AddMemberSheet(familyId: familyId),
      ),
    );
  }
}

class _AddExpenseSheet extends StatefulWidget {
  final String familyId;
  const _AddExpenseSheet({required this.familyId});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Food';

  final List<String> _categories = [
    'Food',
    'Utilities',
    'Rent',
    'Shopping',
    'Travel',
    'Health',
    'General',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.midnightBlue : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Family Expense",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Amount",
              prefixText: "₹ ",
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: "Description (Optional)",
              hintText: "e.g. Grocery shopping",
            ),
          ),
          const SizedBox(height: 24),
          const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.premiumPurple
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          AnimatedGradientButton(
            text: "Save Expense",
            onPressed: () {
              final amount = double.tryParse(_amountController.text);
              if (amount != null && amount > 0) {
                context.read<FamiliaCubit>().addExpense(
                  familyId: widget.familyId,
                  amount: amount,
                  description: _descController.text,
                  category: _selectedCategory,
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _CreateFamilyView extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.family_restroom_rounded,
            size: 80,
            color: AppTheme.premiumPurple,
          ),
          const SizedBox(height: 24),
          Text(
            "You are not in a family yet",
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Create a family to start sharing expenses and visibility with your loved ones.",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Family Name",
              hintText: "e.g. The Prajapatis",
            ),
          ),
          const SizedBox(height: 24),
          AnimatedGradientButton(
            text: "Create Family",
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                context.read<FamiliaCubit>().createFamily(_controller.text);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _AddMemberSheet extends StatefulWidget {
  final String familyId;
  const _AddMemberSheet({required this.familyId});

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.midnightBlue : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add Family Member",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Search for your family member by email to ensure you add the right person.",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            onChanged: (val) {
              context.read<FamiliaCubit>().searchMembers(val);
            },
            decoration: InputDecoration(
              hintText: "Enter email or name...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: () {
                  context.read<FamiliaCubit>().searchMembers(
                    _searchController.text,
                  );
                },
              ),
            ),
            onSubmitted: (val) {
              context.read<FamiliaCubit>().searchMembers(val);
            },
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<FamiliaCubit, FamiliaState>(
              builder: (context, state) {
                if (state is FamiliaSearching) {
                  if (state.results.isEmpty) {
                    return const Center(
                      child: Text(
                        "No users found. Try searching by full email.",
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.results.length,
                    itemBuilder: (context, index) {
                      final result = state.results[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              result.avatarUrl != null &&
                                  result.avatarUrl!.isNotEmpty
                              ? NetworkImage(result.avatarUrl!)
                              : null,
                          child:
                              result.avatarUrl == null ||
                                  result.avatarUrl!.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(result.displayName ?? "No Name"),
                        subtitle: Text(result.email),
                        trailing: ElevatedButton(
                          onPressed: () {
                            context.read<FamiliaCubit>().addMember(
                              widget.familyId,
                              result.id,
                            );
                            Navigator.pop(context);
                          },
                          child: const Text("Add"),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text("Search to find members"));
              },
            ),
          ),
        ],
      ),
    );
  }
}
