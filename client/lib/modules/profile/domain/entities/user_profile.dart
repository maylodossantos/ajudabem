class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
}
