import 'package:expense_splitter/src/core/supabase/supabase_client.dart';
import 'package:expense_splitter/src/feature/trip/data/model/trip_model.dart';
import 'package:expense_splitter/src/feature/trip/data/model/friend_model.dart';
import 'package:expense_splitter/src/feature/expense/data/model/expense_model.dart';

class TripRepository {
  final _client = SupabaseClientManager().client;

  Future<String> createTrip(TripModel trip) async {
    final response = await _client
        .from('trips')
        .insert(trip.toJson())
        .select()
        .single();
    return response['id'] as String;
  }

  Future<void> addFriends(List<FriendModel> friends) async {
    final friendsJson = friends.map((e) => e.toJson()).toList();
    await _client.from('friends').insert(friendsJson);
  }

  Future<List<TripModel>> getTrips() async {
    final response = await _client
        .from('trips')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => TripModel.fromJson(e)).toList();
  }

  Future<TripModel> getTrip(String id) async {
    final response = await _client.from('trips').select().eq('id', id).single();
    return TripModel.fromJson(response);
  }

  Future<List<FriendModel>> getFriends(String tripId) async {
    final response = await _client
        .from('friends')
        .select()
        .eq('trip_id', tripId);
    return (response as List).map((e) => FriendModel.fromJson(e)).toList();
  }

  Future<List<ExpenseModel>> getExpenses(String tripId) async {
    final response = await _client
        .from('expenses')
        .select()
        .eq('trip_id', tripId);
    return (response as List).map((e) => ExpenseModel.fromJson(e)).toList();
  }
}
