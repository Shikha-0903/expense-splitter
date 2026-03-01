import 'package:expense_splitter/src/feature/familia/data/model/family_expense_model.dart';
import 'package:expense_splitter/src/feature/familia/data/model/family_member_model.dart';
import 'package:expense_splitter/src/feature/familia/data/model/family_model.dart';
import 'package:expense_splitter/src/feature/familia/data/model/profile_model.dart';

abstract class FamiliaState {}

class FamiliaInitial extends FamiliaState {}

class FamiliaLoading extends FamiliaState {}

class FamiliaNoFamily extends FamiliaState {}

class FamiliaLoaded extends FamiliaState {
  final FamilyModel family;
  final List<FamilyMemberModel> members;
  final List<FamilyExpenseModel> expenses;

  FamiliaLoaded({
    required this.family,
    required this.members,
    required this.expenses,
  });
}

class FamiliaSearching extends FamiliaState {
  final List<ProfileModel> results;
  FamiliaSearching(this.results);
}

class FamiliaError extends FamiliaState {
  final String message;
  FamiliaError(this.message);
}
