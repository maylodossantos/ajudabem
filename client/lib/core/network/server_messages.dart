/// Portuguese text for backend error messages (which are in English), keyed
/// by the exact message the API sends. Passed to `ApiRequester.request`.
abstract final class ServerMessages {
  static const userConflicts = {
    'Email is using': 'E-mail já cadastrado.',
    'CPF is using': 'CPF já cadastrado em outra conta.',
  };
}
