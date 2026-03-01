import 'package:expense_splitter/src/core/theme/theme.dart';
import 'package:expense_splitter/src/core/widgets/animated_card.dart';
import 'package:expense_splitter/src/core/widgets/animated_gradient_button.dart';
import 'package:expense_splitter/src/feature/familia/data/repository/familia_repository.dart';
import 'package:expense_splitter/src/feature/familia/presentation/cubit/familia_cubit.dart';
import 'package:expense_splitter/src/feature/familia/presentation/cubit/familia_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FamiliaError) {
              return Center(child: Text("Error: ${state.message}"));
            }

            if (state is FamiliaNoFamily) {
              return _CreateFamilyView();
            }

            if (state is FamiliaLoaded) {
              return _FamilyDetailView(
                family: state.family,
                members: state.members,
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
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

class _FamilyDetailView extends StatelessWidget {
  final dynamic family;
  final List<dynamic> members;

  const _FamilyDetailView({required this.family, required this.members});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      family.name,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Family Members",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_add_rounded),
                onPressed: () => _showAddMemberSearch(context),
                color: AppTheme.premiumPurple,
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final profile = member.profile;
                return AnimatedCard(
                  index: index,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
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
                          ? Text(
                              (profile?.displayName ?? profile?.email ?? "?")[0]
                                  .toUpperCase(),
                              style: TextStyle(color: AppTheme.premiumPurple),
                            )
                          : null,
                    ),
                    title: Text(
                      profile?.displayName ?? "Unknown User",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(profile?.email ?? ""),
                    trailing: index == 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.premiumPurple.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Owner",
                              style: TextStyle(
                                color: AppTheme.premiumPurple,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : null,
                  ),
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
        child: _AddMemberSheet(familyId: family.id),
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
