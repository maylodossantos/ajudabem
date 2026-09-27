import 'dart:typed_data';

import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/core/services/image_upload_service.dart';
import 'package:ajuda_bem/modules/profile/domain/entities/user_profile.dart';
import 'package:ajuda_bem/modules/profile/domain/repositories/profile_repository.dart';
import 'package:ajuda_bem/modules/profile/presentation/stores/profile_edit_store.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileEditStore', () {
    test('init prefills the form from the current profile', () {
      final store = _store();

      store.init(
        UserProfile(
          id: 7,
          name: 'Maylo Dos Santos',
          email: 'maylo@email.com',
          phone: '11999999999',
          profileImage: 'https://i.ibb.co/abc/photo.png',
          cpf: '52998224725',
          birthDate: DateTime(2000, 5, 10),
        ),
      );

      expect(store.name, 'Maylo Dos Santos');
      expect(store.phone, '11999999999');
      expect(store.cpf, '529.982.247-25');
      expect(store.birthDate, '10/05/2000');
      expect(store.photo.imageUrl, 'https://i.ibb.co/abc/photo.png');
      expect(store.canSubmit, isTrue);
    });

    test('cannot submit with an empty name', () {
      final store = _store();

      store.setName('');

      expect(store.canSubmit, isFalse);
    });

    test('saves the photo that was just uploaded', () async {
      final repository = _FakeProfileRepository();
      final store = ProfileEditStore(
        repository,
        _FakeImageUploadService(url: 'https://i.ibb.co/new/photo.png'),
      )..setName('Maylo');

      await store.photo.upload(XFile.fromData(Uint8List(0), name: 'a.png'));
      await store.save('jwt-token');

      expect(repository.receivedProfileImage, 'https://i.ibb.co/new/photo.png');
    });

    test('saves the trimmed name and phone through the repository', () async {
      final repository = _FakeProfileRepository();
      final store = ProfileEditStore(repository, _FakeImageUploadService());
      store.setName('  New Name  ');
      store.setPhone(' 11988887777 ');

      final success = await store.save('jwt-token');

      expect(success, isTrue);
      expect(repository.receivedToken, 'jwt-token');
      expect(repository.receivedName, 'New Name');
      expect(repository.receivedPhone, '11988887777');
      expect(store.isLoading, isFalse);
      expect(store.savedProfile?.name, 'New Name');
      expect(store.savedProfile?.phone, '11988887777');
    });

    test('can save while CPF and birth date are still blank', () async {
      final repository = _FakeProfileRepository();
      final store = ProfileEditStore(repository, _FakeImageUploadService())
        ..setName('Maylo');

      expect(store.canSubmit, isTrue);
      await store.save('jwt-token');

      expect(repository.receivedCpf, isNull);
      expect(repository.receivedBirthDate, isNull);
    });

    test('blocks saving a half-typed CPF or birth date', () {
      final store = _store()..setName('Maylo');

      store.setCpf('529.982');
      expect(store.canSubmit, isFalse);

      store.setCpf('529.982.247-25');
      store.setBirthDate('10/05');
      expect(store.canSubmit, isFalse);

      store.setBirthDate('10/05/2000');
      expect(store.canSubmit, isTrue);
    });

    test('sends the CPF digits and the parsed birth date', () async {
      final repository = _FakeProfileRepository();
      final store = ProfileEditStore(repository, _FakeImageUploadService())
        ..setName('Maylo')
        ..setCpf('529.982.247-25')
        ..setBirthDate('10/05/2000');

      await store.save('jwt-token');

      expect(repository.receivedCpf, '52998224725');
      expect(repository.receivedBirthDate, DateTime(2000, 5, 10));
    });

    test('exposes an error message when saving fails', () async {
      final repository = _FakeProfileRepository(
        error: const AppException(
          'Não foi possível salvar as alterações do perfil.',
        ),
      );
      final store = ProfileEditStore(repository, _FakeImageUploadService());
      store.setName('New Name');

      final success = await store.save('jwt-token');

      expect(success, isFalse);
      expect(
        store.errorMessage,
        'Não foi possível salvar as alterações do perfil.',
      );
    });
  });
}

ProfileEditStore _store() {
  return ProfileEditStore(_FakeProfileRepository(), _FakeImageUploadService());
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.error});

  final Object? error;
  String? receivedToken;
  String? receivedName;
  String? receivedPhone;
  String? receivedProfileImage;
  String? receivedCpf;
  DateTime? receivedBirthDate;

  @override
  Future<UserProfile> getCurrentUser(String token) {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile> updateProfile(
    String token, {
    String? name,
    String? phone,
    String? profileImage,
    String? cpf,
    DateTime? birthDate,
  }) async {
    receivedToken = token;
    receivedCpf = cpf;
    receivedBirthDate = birthDate;
    receivedName = name;
    receivedPhone = phone;
    receivedProfileImage = profileImage;

    if (error != null) {
      throw error!;
    }

    return UserProfile(
      id: 7,
      name: name ?? 'Maylo Dos Santos',
      email: 'maylo@email.com',
      phone: phone ?? '11999999999',
      profileImage: profileImage,
    );
  }

  @override
  Future<void> deleteAccount(String token) {
    throw UnimplementedError();
  }
}

class _FakeImageUploadService implements ImageUploadService {
  _FakeImageUploadService({this.url = 'https://i.ibb.co/fake/photo.png'});

  final String url;

  @override
  Future<String> uploadImage(XFile file) async => url;
}
