class FamilyExpenseModel {
  final String id;
  final String familyId;
  final String userId;
  final double amount;
  final String? description;
  final String category;
  final DateTime expenseDate;
  final DateTime createdAt;

  FamilyExpenseModel({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.amount,
    this.description,
    this.category = 'General',
    required this.expenseDate,
    required this.createdAt,
  });

  factory FamilyExpenseModel.fromJson(Map<String, dynamic> json) {
    return FamilyExpenseModel(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'General',
      expenseDate: DateTime.parse(json['expense_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'family_id': familyId,
      'user_id': userId,
      'amount': amount,
      'description': description,
      'category': category,
      'expense_date': expenseDate.toIso8601String().split('T')[0],
    };
  }
}
