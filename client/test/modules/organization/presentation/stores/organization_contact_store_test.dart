import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/modules/organization/domain/entities/organization.dart';
import 'package:ajuda_bem/modules/organization/presentation/stores/organization_contact_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../organization_test_doubles.dart';

void main() {
  final approved = organizationWith(status: OrganizationStatus.approved);

  test('starts from the current contact of the organization', () {
    final store = OrganizationContactStore(FakeOrganizationRepository())
      ..populate(approved);

    expect(store.street, 'Rua das Flores');
    expect(store.zipCode, '85800-000');
    expect(store.state, 'PR');
    expect(store.instagram, '@rios');
    expect(store.canSave, isTrue);
  });

  test('only saves a complete address', () {
    final store = OrganizationContactStore(FakeOrganizationRepository())
      ..populate(approved)
      ..setZipCode('85800-00');

    expect(store.canSave, isFalse);

    store
      ..setZipCode('85800-000')
      ..setNumber(' ');
    expect(store.canSave, isFalse);
  });

  test('sends the trimmed contact with the CEP digits only', () async {
    final repository = FakeOrganizationRepository();
    final store = OrganizationContactStore(repository)
      ..populate(approved)
      ..setStreet('  Rua Paraná ')
      ..setNumber('120')
      ..setZipCode('85801-000')
      ..setWebsite(' amigos.org ');

    final saved = await store.save('token');

    expect(saved, isNotNull);
    expect(repository.contactParams!.street, 'Rua Paraná');
    expect(repository.contactParams!.zipCode, '85801000');
    expect(repository.contactParams!.website, 'amigos.org');
    expect(repository.contactParams!.state, 'PR');
  });

  test('keeps the server message when saving fails', () async {
    final store = OrganizationContactStore(
      FakeOrganizationRepository(
        error: const AppException('Só ONGs aprovadas podem alterar.'),
      ),
    )..populate(approved);

    expect(await store.save('token'), isNull);
    expect(store.errorMessage, 'Só ONGs aprovadas podem alterar.');
    expect(store.isLoading, isFalse);
  });
}
