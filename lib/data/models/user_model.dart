import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'email_verified_at')
  final String? emailVerifiedAt;
  @JsonKey(name: 'profile_photo', fromJson: _parseProfilePhoto)
  final String? profilePhoto;
  @JsonKey(name: 'jenis_kelamin')
  final String? jenisKelamin;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'batch')
  final dynamic batch;
  @JsonKey(name: 'training')
  final dynamic training;

  @JsonKey(name: 'batch_id')
  final int? batchId;
  @JsonKey(name: 'training_id')
  final int? trainingId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.profilePhoto,
    this.jenisKelamin,
    this.createdAt,
    this.updatedAt,
    this.batch,
    this.training,
    this.batchId,
    this.trainingId,
  });

  static String? _parseProfilePhoto(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    String photo = value.toString();
    if (!photo.startsWith('http')) {
      if (!photo.startsWith('/')) {
        photo = '/$photo';
      }
      photo = 'https://appabsensi.mobileprojp.com$photo';
    }
    return photo;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
