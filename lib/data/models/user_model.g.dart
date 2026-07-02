// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: UserModel._parseInt(json['id']),
  name: json['name'] as String,
  email: json['email'] as String,
  emailVerifiedAt: json['email_verified_at'] as String?,
  profilePhoto: UserModel._parseProfilePhoto(json['profile_photo']),
  jenisKelamin: json['jenis_kelamin'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  batch: json['batch'],
  training: json['training'],
  batchId: UserModel._parseNullableInt(json['batch_id']),
  trainingId: UserModel._parseNullableInt(json['training_id']),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'email_verified_at': instance.emailVerifiedAt,
  'profile_photo': instance.profilePhoto,
  'jenis_kelamin': instance.jenisKelamin,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'batch': instance.batch,
  'training': instance.training,
  'batch_id': instance.batchId,
  'training_id': instance.trainingId,
};
