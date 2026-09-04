import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/modules/auth/domain/entities/auth_session.dart';
import 'package:ajuda_bem/modules/auth/domain/entities/register_user_params.dart';
import 'package:ajuda_bem/modules/auth/domain/entities/sign_in_params.dart';
import 'package:ajuda_bem/modules/auth/domain/repositories/auth_repository.dart';
import 'package:ajuda_bem/modules/auth/domain/usecases/sign_in_usecase.dart';
import 'package:ajuda_bem/modules/auth/presentation/stores/login_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';

void main() {
  group('LoginStore', () {
    test('starts with empty credentials and obscured password', () {
      final store = _store();

      expect(store.email, isEmpty);
      expect(store.password, isEmpty);
      expect(store.isPasswordObscured, isTrue);
      expect(store.canSubmit, isFalse);
    });

    test('updates email and password values', () {
      final store = _store();

      store.setEmail('ong@ajudabem.com');
      store.setPassword('123456');

      expect(store.email, 'ong@ajudabem.com');
      expect(store.password, '123456');
    });

    test('keeps submit disabled with only email', () {
      final store = _store();

      store.setEmail('ong@ajudabem.com');

      expect(store.canSubmit, isFalse);
    });

    test('keeps submit disabled with only password', () {
      final store = _store();

      store.setPassword('123456');

      expect(store.canSubmit, isFalse);
    });

    test('enables submit when email and password are filled', () {
      final store = _store();

      store.setEmail('ong@ajudabem.com');
      store.setPassword('123456');

      expect(store.canSubmit, isTrue);
    });

    test('disables submit again when a required field is cleared', () {
      final store = _store()
        ..setEmail('ong@ajudabem.com')
        ..setPassword('123456');

      store.setPassword('');

      expect(store.canSubmit, isFalse);
    });

    test('toggles password visibility', () {
      final store = _store();

      store.togglePasswordVisibility();
      expect(store.isPasswordObscured, isFalse);

      store.togglePasswordVisibility();
      expect(store.isPasswordObscured, isTrue);
    });

    test('reacts when submit availability changes', () {
      final store = _store();
      final values = <bool>[];
      final dispose = autorun((_) => values.add(store.canSubmit));

      store.setEmail('ong@ajudabem.com');
      store.setPassword('123456');
      store.setEmail('');

      dispose();

      expect(values, [false, true, false]);
    });

    test('signs in with normalized email and keeps the session', () async {
      final repository = _FakeAuthRepository();
      final store = _store(repository)
        ..setEmail('  ONG@AJUDABEM.COM ')
        ..setPassword('123456');

      final success = await store.submit();

      expect(success, isTrue);
      expect(repository.receivedParams?.email, 'ong@ajudabem.com');
      expect(repository.receivedParams?.password, '123456');
      expect(store.isAuthenticated, isTrue);
      expect(store.authToken, 'jwt-token');
      expect(store.authenticatedUserName, 'ONG AjudaBem');
      expect(store.errorMessage, isNull);
      expect(store.isLoading, isFalse);
    });

    test('exposes invalid credentials to the page', () async {
      final repository = _FakeAuthRepository(
        error: const AppException('E-mail ou senha inválidos.'),
      );
      final store = _store(repository)
        ..setEmail('ong@ajudabem.com')
        ..setPassword('errada');

      final success = await store.submit();

      expect(success, isFalse);
      expect(store.isAuthenticated, isFalse);
      expect(store.errorMessage, 'E-mail ou senha inválidos.');
      expect(store.isLoading, isFalse);
    });

    test('clears the authenticated session on sign out', () async {
      final store = _store()
        ..setEmail('ong@ajudabem.com')
        ..setPassword('123456');
      await store.submit();

      store.signOut();

      expect(store.isAuthenticated, isFalse);
      expect(store.authToken, isNull);
      expect(store.authenticatedUserName, isNull);
      expect(store.password, isEmpty);
    });
  });
}

LoginStore _store([_FakeAuthRepository? repository]) {
  return LoginStore(SignInUsecase(repository ?? _FakeAuthRepository()));
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.error});

  final Object? error;
  SignInParams? receivedParams;

  @override
  Future<AuthSession> signIn(SignInParams params) async {
    receivedParams = params;

    if (error != null) {
      throw error!;
    }

    return const AuthSession(name: 'ONG AjudaBem', token: 'jwt-token');
  }

  @override
  Future<AuthSession> register(RegisterUserParams params) {
    throw UnimplementedError();
  }
}
