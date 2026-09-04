import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/modules/auth/domain/entities/auth_session.dart';
import 'package:ajuda_bem/modules/auth/domain/entities/register_user_params.dart';
import 'package:ajuda_bem/modules/auth/domain/entities/sign_in_params.dart';
import 'package:ajuda_bem/modules/auth/domain/repositories/auth_repository.dart';
import 'package:ajuda_bem/modules/auth/domain/usecases/register_user_usecase.dart';
import 'package:ajuda_bem/modules/auth/presentation/stores/register_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';

void main() {
  group('RegisterStore', () {
    test('starts with empty fields and disabled submit', () {
      final store = _store();

      expect(store.name, isEmpty);
      expect(store.email, isEmpty);
      expect(store.phone, isEmpty);
      expect(store.password, isEmpty);
      expect(store.confirmPassword, isEmpty);
      expect(store.acceptedTerms, isFalse);
      expect(store.isPasswordObscured, isTrue);
      expect(store.isConfirmPasswordObscured, isTrue);
      expect(store.passwordsMatch, isFalse);
      expect(store.canSubmit, isFalse);
    });

    test('updates all form fields', () {
      final store = _store();

      store.setName('Instituto Esperança');
      store.setEmail('contato@instituto.org');
      store.setPhone('(11) 99999-9999');
      store.setPassword('123456');
      store.setConfirmPassword('123456');
      store.setAcceptedTerms(true);

      expect(store.name, 'Instituto Esperança');
      expect(store.email, 'contato@instituto.org');
      expect(store.phone, '(11) 99999-9999');
      expect(store.password, '123456');
      expect(store.confirmPassword, '123456');
      expect(store.acceptedTerms, isTrue);
    });

    test('enables submit when required fields are valid', () {
      final store = _validStore();

      expect(store.passwordsMatch, isTrue);
      expect(store.canSubmit, isTrue);
    });

    test('keeps submit disabled when name is missing', () {
      final store = _validStore()..setName('');

      expect(store.canSubmit, isFalse);
    });

    test('keeps submit disabled when email is missing', () {
      final store = _validStore()..setEmail('');

      expect(store.canSubmit, isFalse);
    });

    test('keeps submit disabled when phone is missing', () {
      final store = _validStore()..setPhone('');

      expect(store.canSubmit, isFalse);
    });

    test('keeps submit disabled when terms are not accepted', () {
      final store = _validStore()..setAcceptedTerms(false);

      expect(store.canSubmit, isFalse);
    });

    test('keeps submit disabled when passwords do not match', () {
      final store = _validStore()..setConfirmPassword('654321');

      expect(store.passwordsMatch, isFalse);
      expect(store.canSubmit, isFalse);
    });

    test('keeps passwordsMatch false while one password field is empty', () {
      final store = _store();

      store.setPassword('123456');
      expect(store.passwordsMatch, isFalse);

      store.setPassword('');
      store.setConfirmPassword('123456');
      expect(store.passwordsMatch, isFalse);
    });

    test('toggles password visibility controls', () {
      final store = _store();

      store.togglePasswordVisibility();
      store.toggleConfirmPasswordVisibility();

      expect(store.isPasswordObscured, isFalse);
      expect(store.isConfirmPasswordObscured, isFalse);
    });

    test('reacts when terms acceptance changes submit availability', () {
      final store = _validStore()..setAcceptedTerms(false);
      final values = <bool>[];
      final dispose = autorun((_) => values.add(store.canSubmit));

      store.setAcceptedTerms(true);
      store.setAcceptedTerms(false);

      dispose();

      expect(values, [false, true, false]);
    });

    test('submits normalized data through the registration usecase', () async {
      final repository = _FakeAuthRepository();
      final store = _validStore(repository)
        ..setName('  Instituto Esperança  ')
        ..setEmail('  CONTATO@INSTITUTO.ORG ');

      final success = await store.submit();

      expect(success, isTrue);
      expect(store.errorMessage, isNull);
      expect(store.isLoading, isFalse);
      expect(repository.receivedParams?.name, 'Instituto Esperança');
      expect(repository.receivedParams?.email, 'contato@instituto.org');
      expect(repository.receivedParams?.phone, '(11) 99999-9999');
      expect(repository.receivedParams?.password, '123456');
    });

    test('exposes the registration error to the page', () async {
      final repository = _FakeAuthRepository(
        error: const AppException('E-mail já cadastrado.'),
      );
      final store = _validStore(repository);

      final success = await store.submit();

      expect(success, isFalse);
      expect(store.errorMessage, 'E-mail já cadastrado.');
      expect(store.isLoading, isFalse);
    });
  });
}

RegisterStore _store([_FakeAuthRepository? repository]) {
  return RegisterStore(
    RegisterUserUsecase(repository ?? _FakeAuthRepository()),
  );
}

RegisterStore _validStore([_FakeAuthRepository? repository]) {
  return _store(repository)
    ..setName('Instituto Esperança')
    ..setEmail('contato@instituto.org')
    ..setPhone('(11) 99999-9999')
    ..setPassword('123456')
    ..setConfirmPassword('123456')
    ..setAcceptedTerms(true);
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.error});

  final Object? error;
  RegisterUserParams? receivedParams;

  @override
  Future<AuthSession> register(RegisterUserParams params) async {
    receivedParams = params;

    if (error != null) {
      throw error!;
    }

    return const AuthSession(name: 'Instituto Esperança', token: 'token');
  }

  @override
  Future<AuthSession> signIn(SignInParams params) {
    throw UnimplementedError();
  }
}
