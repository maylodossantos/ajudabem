// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recover_access_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RecoverAccessStore on RecoverAccessStoreBase, Store {
  Computed<bool>? _$canSubmitComputed;

  @override
  bool get canSubmit => (_$canSubmitComputed ??= Computed<bool>(
    () => super.canSubmit,
    name: 'RecoverAccessStoreBase.canSubmit',
  )).value;

  late final _$emailAtom = Atom(
    name: 'RecoverAccessStoreBase.email',
    context: context,
  );

  @override
  String get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  late final _$RecoverAccessStoreBaseActionController = ActionController(
    name: 'RecoverAccessStoreBase',
    context: context,
  );

  @override
  void setEmail(String value) {
    final _$actionInfo = _$RecoverAccessStoreBaseActionController.startAction(
      name: 'RecoverAccessStoreBase.setEmail',
    );
    try {
      return super.setEmail(value);
    } finally {
      _$RecoverAccessStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
email: ${email},
canSubmit: ${canSubmit}
    ''';
  }
}
