import 'package:mobx/mobx.dart';

part 'recover_access_store.g.dart';

class RecoverAccessStore = RecoverAccessStoreBase with _$RecoverAccessStore;

abstract class RecoverAccessStoreBase with Store {
  @observable
  String email = '';

  @computed
  bool get canSubmit => email.isNotEmpty;

  @action
  void setEmail(String value) {
    email = value;
  }
}
