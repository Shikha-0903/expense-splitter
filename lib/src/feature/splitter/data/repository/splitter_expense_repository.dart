import 'package:expense_splitter/src/core/supabase/supabase_client.dart';
import 'package:expense_splitter/src/feature/splitter/data/model/splitter_expense_model.dart';

class SplitterExpenseRepository {
  final _client = SupabaseClientManager().client;

  Future<void> addExpense(SplitterExpenseModel expense) async {
    await _client.from('expenses').insert(expense.toJson());
  }

  Future<List<SplitterExpenseModel>> getExpenses(String tripId) async {
    final response = await _client
        .from('expenses')
        .select()
        .eq('trip_id', tripId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((e) => SplitterExpenseModel.fromJson(e))
        .toList();
  }

  Future<List<SplitterExpenseModel>> getAllExpenses() async {
    final response = await _client
        .from('expenses')
        .select()
        .order('created_at', ascending: false);
    return (response as List)
        .map((e) => SplitterExpenseModel.fromJson(e))
        .toList();
  }
}
