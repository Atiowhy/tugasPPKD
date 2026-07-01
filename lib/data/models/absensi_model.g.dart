// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absensi_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AbsensiModel _$AbsensiModelFromJson(Map<String, dynamic> json) => AbsensiModel(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  checkInTime: json['check_in_time'] as String?,
  checkOutTime: json['check_out_time'] as String?,
  checkInLatitude: AbsensiModel._parseDouble(json['check_in_latitude']),
  checkInLongitude: AbsensiModel._parseDouble(json['check_in_longitude']),
  checkOutLatitude: AbsensiModel._parseDouble(json['check_out_latitude']),
  checkOutLongitude: AbsensiModel._parseDouble(json['check_out_longitude']),
  date: json['attendance_date'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$AbsensiModelToJson(AbsensiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'check_in_time': instance.checkInTime,
      'check_out_time': instance.checkOutTime,
      'check_in_latitude': instance.checkInLatitude,
      'check_in_longitude': instance.checkInLongitude,
      'check_out_latitude': instance.checkOutLatitude,
      'check_out_longitude': instance.checkOutLongitude,
      'attendance_date': instance.date,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
