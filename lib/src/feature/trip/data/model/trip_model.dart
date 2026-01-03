class TripModel {
  final String id;
  final String name;
  final String currency;
  final DateTime createdAt;
  final DateTime? tripDate;

  TripModel({
    required this.id,
    required this.name,
    required this.currency,
    required this.createdAt,
    this.tripDate,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      name: json['name'] as String,
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      tripDate: json['trip_date'] != null
          ? DateTime.parse(json['trip_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      if (tripDate != null)
        'trip_date': tripDate!.toIso8601String().split('T')[0],
    };
  }
}
