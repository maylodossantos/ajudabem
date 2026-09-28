import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/modules/organization/domain/entities/organization.dart';
import 'package:ajuda_bem/modules/organization/presentation/stores/organization_form_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../organization_test_doubles.dart';

void main() {
  late FakeDocumentPicker picker;

  setUp(() => picker = FakeDocumentPicker());

  OrganizationFormStore store([FakeOrganizationRepository? repository]) =>
      OrganizationFormStore(repository ?? FakeOrganizationRepository(), picker);

  OrganizationFormStore filledData([FakeOrganizationRepository? repository]) {
    return store(repository)
      ..setCorporateName('Associação Amigos dos Rios')
      ..setTradeName('Amigos dos Rios')
      ..setCnpj('44.555.666/0001-81')
      ..setActivityArea('Meio Ambiente')
      ..setStreet('Rua das Flores')
      ..setNumber('123')
      ..setCity('Cascavel')
      ..setState('PR')
      ..setZipCode('85800-000');
  }

  Future<void> pickEveryDocument(OrganizationFormStore form) async {
    for (final type in OrganizationDocumentType.values) {
      picker.next = pdfFile('${type.apiValue}.pdf');
      expect(await form.pickDocument(type), isNull);
    }
  }

  void acceptEverything(OrganizationFormStore form) => form
    ..setAcceptedTerms(true)
    ..setAcceptedDataProcessing(true)
    ..setDeclaredTruthful(true);

  test('only continues to the documents once the data is complete', () {
    final form = filledData()..setZipCode('85800-00');

    expect(form.canContinue, isFalse);
    form.goToDocuments();
    expect(form.step, OrganizationFormStoreBase.dataStep);

    form.setZipCode('85800-000');
    expect(form.canContinue, isTrue);
    form.goToDocuments();
    expect(form.step, OrganizationFormStoreBase.documentsStep);
  });

  test('needs every document and every consent to submit', () async {
    final form = filledData();
    acceptEverything(form);
    expect(form.canSubmit, isFalse, reason: 'no documents yet');

    await pickEveryDocument(form);
    expect(form.canSubmit, isTrue);

    form.setDeclaredTruthful(false);
    expect(form.canSubmit, isFalse);
  });

  test('only accepts PDFs up to 10 MB', () async {
    final form = store();

    picker.next = pdfFile('foto.jpg');
    expect(
      await form.pickDocument(OrganizationDocumentType.bylaws),
      'Selecione um arquivo PDF.',
    );

    picker.next = pdfFile(
      'estatuto.pdf',
      size: OrganizationFormStoreBase.maxDocumentBytes + 1,
    );
    expect(
      await form.pickDocument(OrganizationDocumentType.bylaws),
      'Cada documento pode ter no máximo 10 MB.',
    );
    expect(form.pickedDocuments, isEmpty);

    picker.next = null;
    expect(
      await form.pickDocument(OrganizationDocumentType.bylaws),
      isNull,
      reason: 'cancelling the picker is not an error',
    );
    expect(form.pickedDocuments, isEmpty);
  });

  test('submits digits only and the picked PDFs themselves', () async {
    final repository = FakeOrganizationRepository();
    final form = filledData(repository);
    await pickEveryDocument(form);
    acceptEverything(form);

    expect(await form.submit('jwt'), isTrue);

    final params = repository.submitted!;
    expect(params.cnpj, '44555666000181');
    expect(params.zipCode, '85800000');
    expect(params.state, 'PR');
    expect(
      params.documentFiles,
      hasLength(OrganizationDocumentType.values.length),
    );
    expect(
      params.documentFiles[OrganizationDocumentType.bylaws]!.name,
      'BYLAWS.pdf',
    );
  });

  test('exposes the API error', () async {
    final form = filledData(
      FakeOrganizationRepository(
        error: const AppException('Este CNPJ já está cadastrado em outra ONG.'),
      ),
    );
    await pickEveryDocument(form);
    acceptEverything(form);

    expect(await form.submit('jwt'), isFalse);
    expect(form.errorMessage, 'Este CNPJ já está cadastrado em outra ONG.');
    expect(form.isLoading, isFalse);
  });

  test(
    'a resubmission keeps what was sent and only uploads new picks',
    () async {
      final repository = FakeOrganizationRepository();
      final form = store(repository)
        ..populate(
          organizationWith(
            status: OrganizationStatus.rejected,
            documents: [
              for (final type in OrganizationDocumentType.values)
                OrganizationDocument(type: type, fileName: 'antigo.pdf'),
            ],
          ),
        );

      expect(form.cnpj, '44.555.666/0001-81');
      expect(form.zipCode, '85800-000');
      expect(form.activityArea, 'Meio Ambiente');
      expect(form.allDocumentsSent, isTrue);
      expect(form.acceptedTerms, isFalse, reason: 'consents are given again');

      picker.next = pdfFile('estatuto-corrigido.pdf');
      await form.pickDocument(OrganizationDocumentType.bylaws);
      acceptEverything(form);
      await form.submit('jwt');

      expect(repository.submitted!.documentFiles.keys, [
        OrganizationDocumentType.bylaws,
      ]);
    },
  );
}
