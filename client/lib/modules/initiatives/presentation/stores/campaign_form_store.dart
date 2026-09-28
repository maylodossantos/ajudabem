import 'package:mobx/mobx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/formatters/money_input_formatter.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/stores/image_upload_store.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/repositories/initiative_repositories.dart';

part 'campaign_form_store.g.dart';

class CampaignFormStore = CampaignFormStoreBase with _$CampaignFormStore;

abstract class CampaignFormStoreBase with Store {
  CampaignFormStoreBase(this._repository, ImageUploadService imageUpload)
    : cover = ImageUploadStore(imageUpload);

  final CampaignRepository _repository;
  final ImageUploadStore cover;

  @observable
  int? campaignId;

  @observable
  String title = '';

  @observable
  String donationInfo = '';

  @observable
  String subtitle = '';

  @observable
  String description = '';

  @observable
  CampaignCategory category = CampaignCategory.food;

  @observable
  String goal = '';

  @observable
  String deadline = '';

  @observable
  bool isSaving = false;

  @observable
  String? errorMessage;

  @computed
  DateTime? get deadlineDate => DateInputFormatter.parse(deadline);

  @computed
  bool get deadlineValid {
    if (deadline.isEmpty) return true;
    final date = deadlineDate;
    final now = DateTime.now();
    return date != null &&
        !date.isBefore(DateTime(now.year, now.month, now.day));
  }

  @computed
  bool get canSubmit =>
      title.trim().isNotEmpty &&
      description.trim().isNotEmpty &&
      deadlineValid &&
      !isSaving &&
      !cover.isUploading;

  @action
  void populate(Campaign campaign) {
    campaignId = campaign.id;
    title = campaign.title;
    donationInfo = campaign.donationInfo;
    subtitle = campaign.subtitle;
    description = campaign.description;
    category = campaign.category;
    final amount = campaign.goalAmount;
    goal = amount == null ? '' : MoneyInputFormatter.display(amount);
    deadline = DateInputFormatter.display(campaign.deadline);
    cover.setImageUrl(campaign.coverImage);
  }

  @action
  void setTitle(String value) => title = value;

  @action
  void setDonationInfo(String value) => donationInfo = value;

  @action
  void setSubtitle(String value) => subtitle = value;

  @action
  void setDescription(String value) => description = value;

  @action
  void setCategory(CampaignCategory value) => category = value;

  @action
  void setGoal(String value) => goal = value;

  @action
  void setDeadline(String value) => deadline = value;

  @action
  Future<Campaign?> submit(String token) async {
    if (!canSubmit) return null;
    isSaving = true;
    errorMessage = null;

    try {
      return await _repository.save(
        CampaignParams(
          title: title,
          donationInfo: donationInfo,
          subtitle: subtitle,
          description: description,
          category: category,
          goalAmount: MoneyInputFormatter.parse(goal),
          deadline: deadlineDate,
          coverImage: cover.imageUrl,
        ),
        token,
        id: campaignId,
      );
    } catch (error) {
      errorMessage = AppException.messageOf(
        error,
        'Não foi possível salvar a campanha.',
      );
      return null;
    } finally {
      isSaving = false;
    }
  }
}
