class UserModel {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? profilePhoto;
  final String? jenisKelamin;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.profilePhoto,
    this.jenisKelamin,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? photo = json['profile_photo'];
    if (photo != null && photo.isNotEmpty && !photo.startsWith('http')) {
      if (!photo.startsWith('/')) {
        photo = '/$photo';
      }
      photo = 'https://appabsensi.mobileprojp.com$photo';
    }

    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      profilePhoto: photo,
      jenisKelamin: json['jenis_kelamin'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'profile_photo': profilePhoto,
      'jenis_kelamin': jenisKelamin,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
