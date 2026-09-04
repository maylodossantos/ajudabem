import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/modules/profile/domain/entities/user_profile.dart';
import 'package:ajuda_bem/modules/profile/domain/repositories/profile_repository.dart';
import 'package:ajuda_bem/modules/profile/domain/usecases/get_current_user_usecase.dart';
import 'package:ajuda_bem/modules/profile/presentation/stores/profile_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads and exposes the authenticated user profile', () async {
    final repository = _FakeProfileRepository();
    final store = ProfileStore(GetCurrentUserUsecase(repository));

    await store.load('jwt-token');

    expect(repository.receivedToken, 'jwt-token');
    expect(store.profile?.id, 7);
    expect(store.profile?.name, 'Maylo Dos Santos');
    expect(store.errorMessage, isNull);
    expect(store.isLoading, isFalse);
  });

  test('exposes profile loading errors', () async {
    final store = ProfileStore(
      GetCurrentUserUsecase(
        _FakeProfileRepository(
          error: const AppException('Não foi possível carregar seu perfil.'),
        ),
      ),
    );

    await store.load('jwt-token');

    expect(store.profile, isNull);
    expect(store.errorMessage, 'Não foi possível carregar seu perfil.');
    expect(store.isLoading, isFalse);
  });
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.error});

  final Object? error;
  String? receivedToken;

  @override
  Future<UserProfile> getCurrentUser(String token) async {
    receivedToken = token;

    if (error != null) {
      throw error!;
    }

    return const UserProfile(
      id: 7,
      name: 'Maylo Dos Santos',
      email: 'maylo@email.com',
      phone: '11999999999',
    );
  }
}
