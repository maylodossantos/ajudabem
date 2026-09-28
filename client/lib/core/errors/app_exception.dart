class AppException implements Exception {
  const AppException(this.message);

  final String message;

  static String messageOf(Object error, String fallback) =>
      error is AppException ? error.message : fallback;

  @override
  String toString() => message;
}
