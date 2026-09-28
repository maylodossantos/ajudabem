import '../entities/care_case.dart';
import '../entities/care_record_params.dart';

abstract interface class CareRepository {
  Future<List<CareCase>> nominated(String token);

  Future<List<CareCase>> myCases(String token);

  Future<List<CareCase>> map(String token);

  Future<CareCaseDetail> get(int personId, String token);

  Future<CareCase> assume(int personId, String token);

  Future<CareCaseDetail> addRecord(
    int personId,
    CareRecordParams params,
    String token,
  );
}
