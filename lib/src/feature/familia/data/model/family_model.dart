class FamilyModel {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;

  FamilyModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
