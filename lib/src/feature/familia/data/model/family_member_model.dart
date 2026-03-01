import 'profile_model.dart';

class FamilyMemberModel {
  final String familyId;
  final String userId;
  final DateTime joinedAt;
  final ProfileModel? profile;

  FamilyMemberModel({
    required this.familyId,
    required this.userId,
    required this.joinedAt,
    this.profile,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      familyId: json['family_id'] as String,
      userId: json['user_id'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      profile: json['profiles'] != null
          ? ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'family_id': familyId,
      'user_id': userId,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
