import 'package:ajuda_bem/core/errors/app_exception.dart';
import 'package:ajuda_bem/modules/care/domain/entities/care_case.dart';
import 'package:ajuda_bem/modules/care/domain/entities/care_record_params.dart';
import 'package:ajuda_bem/modules/care/domain/repositories/care_repository.dart';

CareCase careCase({
  int id = 1,
  String fullName = 'Maria Souza',
  Urgency urgency = Urgency.high,
  CareStatus status = CareStatus.nominated,
  List<String> needs = const ['Alimentação'],
  double? distanceKm = 2.4,
  String neighborhood = 'Centro',
  String? organizationName,
  FinishReason? finishReason,
  DateTime? careUpdatedAt,
}) => CareCase(
  id: id,
  fullName: fullName,
  urgency: urgency,
  status: status,
  age: 40,
  gender: 'FEMALE',
  needs: needs,
  notes: 'Dorme na praça\nPrecisa de cobertor',
  street: 'Rua Paraná',
  number: '100',
  neighborhood: neighborhood,
  city: 'Cascavel',
  state: 'PR',
  distanceKm: distanceKm,
  organizationName: organizationName,
  finishReason: finishReason,
  createdAt: DateTime(2026, 9, 1),
  careStartedAt: status == CareStatus.nominated ? null : DateTime(2026, 9, 2),
  careUpdatedAt: careUpdatedAt,
);

CareRecord careRecord({
  int number = 1,
  CareRecordStatus status = CareRecordStatus.started,
  String? referral,
}) => CareRecord(
  id: number,
  number: number,
  status: status,
  occurredAt: DateTime(2026, 9, 2, 14, 30),
  situation: 'Sem abrigo',
  actionTaken: 'Entrega de marmita',
  referral: referral,
);

class FakeCareRepository implements CareRepository {
  FakeCareRepository({
    this.nominatedCases = const [],
    this.myCaseList = const [],
    Map<int, CareCaseDetail>? details,
  }) : details = details ?? {};

  List<CareCase> nominatedCases;
  List<CareCase> myCaseList;
  final Map<int, CareCaseDetail> details;
  final assumed = <int>[];
  CareRecordParams? lastRecord;
  AppException? failure;

  @override
  Future<List<CareCase>> nominated(String token) async => nominatedCases;

  @override
  Future<List<CareCase>> myCases(String token) async => myCaseList;

  @override
  Future<List<CareCase>> map(String token) async => [
    ...nominatedCases,
    ...myCaseList,
  ].where((person) => person.hasLocation).toList();

  @override
  Future<CareCaseDetail> get(int personId, String token) async =>
      details[personId]!;

  @override
  Future<CareCase> assume(int personId, String token) async {
    if (failure case final error?) throw error;
    assumed.add(personId);
    final current = details[personId];
    final person = careCase(
      id: personId,
      status: CareStatus.inCare,
      organizationName: 'Amigos dos Rios',
    );
    details[personId] = CareCaseDetail(
      person: person,
      records: current?.records ?? const [],
    );
    return person;
  }

  @override
  Future<CareCaseDetail> addRecord(
    int personId,
    CareRecordParams params,
    String token,
  ) async {
    if (failure case final error?) throw error;
    lastRecord = params;
    final current = details[personId]!;
    final finished = params.status == CareRecordStatus.finished;
    final updated = CareCaseDetail(
      person: careCase(
        id: personId,
        status: finished ? CareStatus.finished : CareStatus.inCare,
        finishReason: params.finishReason,
        organizationName: 'Amigos dos Rios',
      ),
      records: [
        ...current.records,
        careRecord(number: current.records.length + 1, status: params.status),
      ],
    );
    details[personId] = updated;
    return updated;
  }
}
