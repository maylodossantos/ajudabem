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

  /// Digits only; null for accounts created before it was required.
  final String? cpf;
  final DateTime? birthDate;
  final String role;

  bool get canPublishNews => role == 'ADMIN';
}
