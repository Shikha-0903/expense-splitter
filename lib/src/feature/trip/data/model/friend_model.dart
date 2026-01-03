class FriendModel {
  final String id;
  final String name;
  final String tripId;

  FriendModel({required this.id, required this.name, required this.tripId});

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] as String,
      name: json['name'] as String,
      tripId: json['trip_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'trip_id': tripId};
  }
}
