import 'package:expense_splitter/src/core/supabase/supabase_client.dart';
import 'package:expense_splitter/src/feature/familia/data/model/family_expense_model.dart';
import 'package:expense_splitter/src/feature/familia/data/model/family_member_model.dart';
import 'package:expense_splitter/src/feature/familia/data/model/family_model.dart';
import 'package:expense_splitter/src/feature/familia/data/model/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FamiliaRepository {
  final SupabaseClient _client = SupabaseClientManager().client;

  String? get authUserId => _client.auth.currentUser?.id;

  Future<List<ProfileModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('profiles')
        .select()
        .or('email.ilike.%$query%,display_name.ilike.%$query%')
        .neq('id', userId)
        .limit(10);

    return (response as List)
        .map((json) => ProfileModel.fromJson(json))
        .toList();
  }

  Future<Map<String, dynamic>?> getCurrentFamily() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final memberRecord = await _client
        .from('family_members')
        .select('family_id, families(*)')
        .eq('user_id', userId)
        .maybeSingle();

    if (memberRecord == null) return null;

    final familyId = memberRecord['family_id'];

    // Fetch all members of this family
    final membersResponse = await _client
        .from('family_members')
        .select('*, profiles(*)')
        .eq('family_id', familyId);

    return {
      'family': FamilyModel.fromJson(
        memberRecord['families'] as Map<String, dynamic>,
      ),
      'members': (membersResponse as List)
          .map((json) => FamilyMemberModel.fromJson(json))
          .toList(),
    };
  }

  Future<List<FamilyExpenseModel>> fetchFamilyExpenses(String familyId) async {
    final response = await _client
        .from('family_expenses')
        .select()
        .eq('family_id', familyId)
        .order('expense_date', ascending: false);

    return (response as List)
        .map((json) => FamilyExpenseModel.fromJson(json))
        .toList();
  }

  Future<void> addFamilyExpense(FamilyExpenseModel expense) async {
    await _client.from('family_expenses').insert(expense.toJson());
  }

  Future<String> createFamily(String name) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception("User not logged in");

    // 1. Create the family
    final familyResponse = await _client
        .from('families')
        .insert({'name': name, 'created_by': userId})
        .select()
        .single();

    final familyId = familyResponse['id'] as String;

    // 2. Add creator as first member
    await _client.from('family_members').insert({
      'family_id': familyId,
      'user_id': userId,
    });

    return familyId;
  }

  Future<void> addMember(String familyId, String userId) async {
    await _client.from('family_members').insert({
      'family_id': familyId,
      'user_id': userId,
    });
  }
}
