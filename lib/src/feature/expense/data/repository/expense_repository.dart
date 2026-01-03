import 'package:expense_splitter/src/core/supabase/supabase_client.dart';
import 'package:expense_splitter/src/feature/expense/data/model/expense_model.dart';

class ExpenseRepository {
  final _client = SupabaseClientManager().client;

  Future<void> addExpense(ExpenseModel expense) async {
    await _client.from('expenses').insert(expense.toJson());
  }

  Future<List<ExpenseModel>> getExpenses(String tripId) async {
    final response = await _client
        .from('expenses')
        .select()
        .eq('trip_id', tripId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => ExpenseModel.fromJson(e)).toList();
  }
}
