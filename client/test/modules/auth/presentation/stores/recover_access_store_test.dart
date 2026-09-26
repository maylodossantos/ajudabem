import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/modules/auth/domain/entities/auth_session.dart';
import 'package:ajuda_bem/modules/auth/domain/entities/register_user_params.dart';
import 'package:ajuda_bem/modules/auth/domain/entities/sign_in_params.dart';
import 'package:ajuda_bem/modules/auth/domain/repositories/auth_repository.dart';
import 'package:ajuda_bem/modules/auth/presentation/stores/recover_access_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';

void main() {
  group('RecoverAccessStore', () {
    test('starts with empty fields and every step disabled', () {
      final store = _store();

      expect(store.email, isEmpty);
      expect(store.code, isEmpty);
      expect(store.resetToken, isNull);
      expect(store.canSubmitEmail, isFalse);
      expect(store.canSubmitCode, isFalse);
      expect(store.canSubmitNewPassword, isFalse);
    });

    test('enables the email step once an email is typed', () {
      final store = _store()..setEmail('contato@instituto.org');

      expect(store.canSubmitEmail, isTrue);
    });

    test('reacts when email submit availability changes', () {
      final store = _store();
      final values = <bool>[];
      final dispose = autorun((_) => values.add(store.canSubmitEmail));

      store.setEmail('contato@instituto.org');
      store.setEmail('');
      dispose();

      expect(values, [false, true, false]);
    });

    test('sends the code and keeps loading false afterwards', () async {
      final repository = _FakeAuthRepository();
      final store = _store(repository)..setEmail('contato@instituto.org');

      final success = await store.sendCode();

      expect(success, isTrue);
      expect(repository.forgotPasswordEmail, 'contato@instituto.org');
      expect(store.errorMessage, isNull);
      expect(store.isLoading, isFalse);
    });

    test('exposes the error when sending the code fails', () async {
      final repository = _FakeAuthRepository(
        forgotPasswordError: const AppException('E-mail não encontrado.'),
      );
      final store = _store(repository)..setEmail('contato@instituto.org');

      final success = await store.sendCode();

      expect(success, isFalse);
      expect(store.errorMessage, 'E-mail não encontrado.');
      expect(store.isLoading, isFalse);
    });

    test('requires a 4-digit code before allowing confirmation', () {
      final store = _store()
        ..setEmail('contato@instituto.org')
        ..setCode('123');

      expect(store.canSubmitCode, isFalse);

      store.setCode('1234');

      expect(store.canSubmitCode, isTrue);
    });

    test('confirms the code and stores the reset token', () async {
      final repository = _FakeAuthRepository(resetToken: 'the-reset-token');
      final store = _store(repository)
        ..setEmail('contato@instituto.org')
        ..setCode('1234');

      final success = await store.confirmCode();

      expect(success, isTrue);
      expect(store.resetToken, 'the-reset-token');
      expect(repository.verifyCodeArgs, ('contato@instituto.org', '1234'));
    });

    test('exposes the error when the code is invalid', () async {
      final repository = _FakeAuthRepository(
        verifyCodeError: const AppException('Código inválido ou expirado.'),
      );
      final store = _store(repository)
        ..setEmail('contato@instituto.org')
        ..setCode('9999');

      final success = await store.confirmCode();

      expect(success, isFalse);
      expect(store.resetToken, isNull);
      expect(store.errorMessage, 'Código inválido ou expirado.');
    });

    test('requires both password fields before allowing submission', () {
      final store = _store()..setPassword('newPassword123');

      expect(store.canSubmitNewPassword, isFalse);

      store.setConfirmPassword('newPassword123');

      expect(store.canSubmitNewPassword, isTrue);
    });

    test('submits the new password using the stored reset token', () async {
      final repository = _FakeAuthRepository(resetToken: 'the-reset-token');
      final store = _store(repository)
        ..setEmail('contato@instituto.org')
        ..setCode('1234');
      await store.confirmCode();

      store
        ..setPassword('newPassword123')
        ..setConfirmPassword('newPassword123');

      final success = await store.submitNewPassword();

      expect(success, isTrue);
      expect(repository.resetPasswordArgs, (
        'contato@instituto.org',
        'the-reset-token',
        'newPassword123',
        'newPassword123',
      ));
    });

    test('does not submit the new password without a reset token', () async {
      final store = _store()
        ..setEmail('contato@instituto.org')
        ..setPassword('newPassword123')
        ..setConfirmPassword('newPassword123');

      final success = await store.submitNewPassword();

      expect(success, isFalse);
    });

    test('exposes the error when resetting the password fails', () async {
      final repository = _FakeAuthRepository(
        resetToken: 'the-reset-token',
        resetPasswordError: const AppException('As senhas não coincidem.'),
      );
      final store = _store(repository)
        ..setEmail('contato@instituto.org')
        ..setCode('1234');
      await store.confirmCode();

      store
        ..setPassword('newPassword123')
        ..setConfirmPassword('somethingElse');

      final success = await store.submitNewPassword();

      expect(success, isFalse);
      expect(store.errorMessage, 'As senhas não coincidem.');
    });

    test('clear resets every field', () async {
      final repository = _FakeAuthRepository(resetToken: 'the-reset-token');
      final store = _store(repository)
        ..setEmail('contato@instituto.org')
        ..setCode('1234');
      await store.confirmCode();
      store
        ..setPassword('newPassword123')
        ..setConfirmPassword('newPassword123');

      store.clear();

      expect(store.email, isEmpty);
      expect(store.code, isEmpty);
      expect(store.password, isEmpty);
      expect(store.confirmPassword, isEmpty);
      expect(store.resetToken, isNull);
      expect(store.errorMessage, isNull);
    });
  });
}

RecoverAccessStore _store([_FakeAuthRepository? repository]) {
  return RecoverAccessStore(repository ?? _FakeAuthRepository());
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.forgotPasswordError,
    this.verifyCodeError,
    this.resetPasswordError,
    this.resetToken = 'reset-token',
  });

  final Object? forgotPasswordError;
  final Object? verifyCodeError;
  final Object? resetPasswordError;
  final String resetToken;

  String? forgotPasswordEmail;
  (String, String)? verifyCodeArgs;
  (String, String, String, String)? resetPasswordArgs;

  @override
  Future<void> forgotPassword(String email) async {
    forgotPasswordEmail = email;

    if (forgotPasswordError != null) {
      throw forgotPasswordError!;
    }
  }

  @override
  Future<String> verifyCode(String email, String code) async {
    verifyCodeArgs = (email, code);

    if (verifyCodeError != null) {
      throw verifyCodeError!;
    }

    return resetToken;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String confirmPassword,
  }) async {
    resetPasswordArgs = (email, resetToken, password, confirmPassword);

    if (resetPasswordError != null) {
      throw resetPasswordError!;
    }
  }

  @override
  Future<AuthSession> register(RegisterUserParams params) {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession> signIn(SignInParams params) {
    throw UnimplementedError();
  }
}
