import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/core/services/image_upload_service.dart';
import 'package:ajuda_bem/modules/initiatives/domain/entities/campaign.dart';
import 'package:ajuda_bem/modules/initiatives/domain/entities/volunteer_action.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/stores/action_form_store.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/stores/action_stores.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/stores/campaign_form_store.dart';
import 'package:ajuda_bem/modules/initiatives/presentation/stores/initiatives_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import '../../initiative_test_doubles.dart';

class _NoUpload implements ImageUploadService {
  @override
  Future<String> uploadImage(XFile file) async => 'https://i.ibb.co/x.png';
}

void main() {
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  String day(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  group('CampaignFormStore', () {
    test('requires title and description and a deadline from today', () {
      final store = CampaignFormStore(FakeCampaignRepository(), _NoUpload());
      expect(store.canSubmit, isFalse);

      store
        ..setTitle('Inverno Solidário')
        ..setDescription('Agasalhos');
      expect(store.canSubmit, isTrue);

      store.setDeadline('01/01/2020');
      expect(store.deadlineValid, isFalse);
      expect(store.canSubmit, isFalse);

      store.setDeadline(day(tomorrow));
      expect(store.canSubmit, isTrue);
    });

    test('sends the goal in reais and keeps the id when editing', () async {
      final repository = FakeCampaignRepository();
      final store = CampaignFormStore(repository, _NoUpload())
        ..populate(campaignWith(id: 4))
        ..setGoal('1.500,50');

      final saved = await store.submit('jwt');

      expect(saved?.id, 4);
      expect(repository.savedId, 4);
      expect(repository.saved?.goalAmount, 1500.5);
      expect(repository.saved?.category, CampaignCategory.food);
    });
  });

  group('ActionFormStore', () {
    test('validates date, schedule and number of volunteers', () {
      final store = ActionFormStore(FakeActionRepository())
        ..setTitle('Distribuição')
        ..setDate(day(tomorrow))
        ..setStartTime('18:00')
        ..setEndTime('17:00')
        ..setVolunteers('6')
        ..setStreet('Praça')
        ..setCity('Cascavel')
        ..setDescription('Entrega');
      expect(store.timesValid, isFalse);
      expect(store.canSubmit, isFalse);

      store.setEndTime('21:00');
      expect(store.canSubmit, isTrue);

      store.setVolunteers('0');
      expect(store.canSubmit, isFalse);

      store
        ..setVolunteers('6')
        ..setDate('01/01/2020');
      expect(store.canSubmit, isFalse);
    });
  });

  group('InitiativesStore', () {
    test('is empty only after loading nothing, and searches per tab', () async {
      final empty = InitiativesStore(
        FakeCampaignRepository(),
        FakeActionRepository(),
      );
      expect(empty.isEmpty, isFalse);
      await empty.load('jwt');
      expect(empty.isEmpty, isTrue);

      final store = InitiativesStore(
        FakeCampaignRepository(
          campaigns: [
            campaignWith(id: 1, title: 'Cestas'),
            campaignWith(id: 2, title: 'Inverno'),
          ],
        ),
        FakeActionRepository(actions: [actionWith()]),
      );
      await store.load('jwt');
      store.setSearch('invern');
      expect(store.visibleCampaigns.map((c) => c.id), [2]);
      expect(store.visibleActions, isEmpty);
    });
  });

  group('volunteer stores', () {
    test('applying from the list marks the action as pending', () async {
      final repository = FakeActionRepository(actions: [actionWith(id: 5)]);
      final store = OpenActionsStore(repository);
      await store.load('jwt');

      expect(await store.apply(store.actions.single, 'jwt'), isTrue);
      expect(store.actions.single.myApplication, ApplicationStatus.pending);
    });

    test('accepting a volunteer updates the count', () async {
      final repository = FakeActionRepository(
        actions: [actionWith(id: 5, accepted: 0, needed: 1)],
        applications: const [
          VolunteerApplication(
            id: 1,
            name: 'Maria',
            status: ApplicationStatus.pending,
          ),
        ],
      );
      final store = VolunteersStore(repository);
      await store.load(5, 'jwt');
      expect(store.acceptedCount, 0);

      expect(await store.accept(store.volunteers.single, 'jwt'), isTrue);
      expect(store.acceptedCount, 1);

      repository.failure = const AppException('Não há mais vagas nesta ação.');
      expect(await store.accept(store.volunteers.single, 'jwt'), isFalse);
      expect(store.errorMessage, 'Não há mais vagas nesta ação.');
    });
  });
}
