import '../entities/campaign.dart';
import '../entities/volunteer_action.dart';

abstract interface class CampaignRepository {
  Future<List<Campaign>> active();

  Future<Campaign> get(int id);

  Future<List<Campaign>> mine(String token);

  Future<Campaign> save(CampaignParams params, String token, {int? id});

  Future<Campaign> finish(int id, String token);
}

abstract interface class VolunteerActionRepository {
  Future<List<VolunteerAction>> open(String token);

  Future<VolunteerAction> get(int id, String token);

  Future<List<VolunteerAction>> mine(String token);

  Future<VolunteerAction> save(
    VolunteerActionParams params,
    String token, {
    int? id,
  });

  Future<VolunteerAction> finish(int id, String token);

  Future<VolunteerAction> apply(int id, String token);

  Future<VolunteerAction> withdraw(int id, String token);

  Future<List<VolunteerApplication>> volunteers(int id, String token);

  Future<VolunteerApplication> accept(
    int actionId,
    int applicationId,
    String token,
  );
}
