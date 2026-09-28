class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.cpf,
    this.birthDate,
    this.role = 'USER',
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;

  final String? cpf;
  final DateTime? birthDate;
  final String role;

  bool get isAdmin => role == 'ADMIN';

  bool get isOng => role == 'USER_ONG';

  bool get canPublishNews => isAdmin;
}
