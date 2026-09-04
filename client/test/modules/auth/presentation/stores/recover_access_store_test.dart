import 'package:ajuda_bem/modules/auth/presentation/stores/recover_access_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';

void main() {
  group('RecoverAccessStore', () {
    test('starts with empty email and disabled submit', () {
      final store = RecoverAccessStore();

      expect(store.email, isEmpty);
      expect(store.canSubmit, isFalse);
    });

    test('updates email and enables submit', () {
      final store = RecoverAccessStore();

      store.setEmail('contato@instituto.org');

      expect(store.email, 'contato@instituto.org');
      expect(store.canSubmit, isTrue);
    });

    test('disables submit when email is cleared', () {
      final store = RecoverAccessStore()
        ..setEmail('contato@instituto.org')
        ..setEmail('');

      expect(store.canSubmit, isFalse);
    });

    test('reacts when submit availability changes', () {
      final store = RecoverAccessStore();
      final values = <bool>[];
      final dispose = autorun((_) => values.add(store.canSubmit));

      store.setEmail('contato@instituto.org');
      store.setEmail('');
      dispose();

      expect(values, [false, true, false]);
    });
  });
}
