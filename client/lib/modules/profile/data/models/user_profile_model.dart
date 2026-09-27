import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.cpf,
    this.birthDate,
    this.role = 'USER',
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profileImage: json['profile_image'] as String?,
      cpf: json['cpf'] as String?,
      birthDate: DateTime.tryParse(json['birth_date'] as String? ?? ''),
      role: json['role'] as String? ?? 'USER',
    );
  }

  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String? cpf;
  final DateTime? birthDate;
  final String role;

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      phone: phone,
      profileImage: profileImage,
      cpf: cpf,
      birthDate: birthDate,
      role: role,
    );
  }
}
