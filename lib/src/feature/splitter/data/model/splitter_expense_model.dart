class SplitterExpenseModel {
  final String id;
  final String tripId;
  final String description;
  final double amount;
  final String paidByUserId;
  final DateTime createdAt;

  SplitterExpenseModel({
    required this.id,
    required this.tripId,
    required this.description,
    required this.amount,
    required this.paidByUserId,
    required this.createdAt,
  });

  factory SplitterExpenseModel.fromJson(Map<String, dynamic> json) {
    return SplitterExpenseModel(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidByUserId: json['paid_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'description': description,
      'amount': amount,
      'paid_by': paidByUserId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
