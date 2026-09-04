import '../../domain/entities/auth_session.dart';

class AuthSessionModel {
  const AuthSessionModel({required this.name, required this.token});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      name: json['name'] as String? ?? '',
      token: json['token'] as String? ?? '',
    );
  }

  final String name;
  final String token;

  AuthSession toEntity() => AuthSession(name: name, token: token);
}
