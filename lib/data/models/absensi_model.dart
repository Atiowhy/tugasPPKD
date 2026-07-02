import 'package:json_annotation/json_annotation.dart';

part 'absensi_model.g.dart';

@JsonSerializable()
class AbsensiModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'check_in_time')
  final String? checkInTime;
  @JsonKey(name: 'check_out_time')
  final String? checkOutTime;
  @JsonKey(name: 'check_in_latitude', fromJson: _parseDouble)
  final double? checkInLatitude;
  @JsonKey(name: 'check_in_longitude', fromJson: _parseDouble)
  final double? checkInLongitude;
  @JsonKey(name: 'check_out_latitude', fromJson: _parseDouble)
  final double? checkOutLatitude;
  @JsonKey(name: 'check_out_longitude', fromJson: _parseDouble)
  final double? checkOutLongitude;
  @JsonKey(name: 'attendance_date')
  final String? date;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'alasan_izin')
  final String? alasanIzin;

  AbsensiModel({
    required this.id,
    this.userId,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.date,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.alasanIzin,
  });

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  factory AbsensiModel.fromJson(Map<String, dynamic> json) => _$AbsensiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AbsensiModelToJson(this);
}
