import 'package:ajuda_bem/modules/profile/domain/entities/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile.canPublishNews', () {
    test('is true for admins', () {
      const profile = UserProfile(
        id: 1,
        name: 'Admin',
        email: 'admin@ajudabem.com',
        phone: '',
        role: 'ADMIN',
      );

      expect(profile.canPublishNews, isTrue);
    });

    test('is false for ONGs', () {
      const profile = UserProfile(
        id: 1,
        name: 'ONG',
        email: 'ong@ajudabem.com',
        phone: '',
        role: 'USER_ONG',
      );

      expect(profile.canPublishNews, isFalse);
    });

    test('is false for regular users', () {
      const profile = UserProfile(
        id: 1,
        name: 'User',
        email: 'user@ajudabem.com',
        phone: '',
        role: 'USER',
      );

      expect(profile.canPublishNews, isFalse);
    });
  });
}
