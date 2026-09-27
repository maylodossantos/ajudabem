class RegisterUserParams {
  const RegisterUserParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.cpf,
    required this.birthDate,
    required this.password,
    required this.acceptedTerms,
  });

  final String name;
  final String email;
  final String phone;

  /// Digits only.
  final String cpf;
  final DateTime birthDate;
  final String password;
  final bool acceptedTerms;
}
