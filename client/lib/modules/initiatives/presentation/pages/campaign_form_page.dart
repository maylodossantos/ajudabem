import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/formatters/money_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_cover_image_picker.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_form_parts.dart';
import '../../../../core/widgets/app_labeled_field.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/campaign.dart';
import '../stores/campaign_form_store.dart';

class CampaignFormPage extends StatefulWidget {
  const CampaignFormPage({super.key, this.initial, this.store, this.token});

  final Campaign? initial;
  final CampaignFormStore? store;
  final String? token;

  @override
  State<CampaignFormPage> createState() => _CampaignFormPageState();
}

class _CampaignFormPageState extends State<CampaignFormPage> {
  late final CampaignFormStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<CampaignFormStore>();
    final initial = widget.initial;
    if (initial != null) _store.populate(initial);
  }

  Future<void> _submit() async {
    final token = widget.token ?? Modular.get<LoginStore>().authToken;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }
    final saved = await _store.submit(token);
    if (!mounted) return;
    if (saved == null) {
      showAppSnackBar(
        context,
        _store.errorMessage ?? 'Não foi possível salvar a campanha.',
      );
      return;
    }
    showAppSnackBar(
      context,
      widget.initial == null ? 'Campanha publicada!' : 'Campanha atualizada.',
    );
    Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      currentItem: AppNavigationItem.ong,
      bottomBar: Observer(
        builder: (_) => AppPrimaryButton(
          key: const Key('campaign_form_submit'),
          label: widget.initial == null ? 'Publicar' : 'Salvar',
          isLoading: _store.isSaving,
          onPressed: _store.canSubmit ? _submit : null,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Observer(
          builder: (_) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppFormHeading('Preencha as informações abaixo'),
              AppCoverImagePicker(store: _store.cover),
              const SizedBox(height: 16),
              AppFormGap(
                AppLabeledField(
                  key: const Key('campaign_title'),
                  label: 'Título:',
                  initialValue: _store.title,
                  onChanged: _store.setTitle,
                ),
              ),
              AppFormGap(
                AppLabeledField(
                  key: const Key('campaign_donations'),
                  label: 'Doações:',
                  hintText: 'Descreva como as pessoas podem contribuir.',
                  initialValue: _store.donationInfo,
                  maxLines: 4,
                  onChanged: _store.setDonationInfo,
                ),
              ),
              AppFormGap(
                AppLabeledField(
                  label: 'Título Auxiliar:',
                  hintText: 'Descreva resumidamente a campanha.',
                  initialValue: _store.subtitle,
                  maxLines: 2,
                  onChanged: _store.setSubtitle,
                ),
              ),
              AppFormGap(
                AppLabeledField(
                  key: const Key('campaign_description'),
                  label: 'Descrição:',
                  hintText: 'Descreva o objetivo e como ela será realizada.',
                  initialValue: _store.description,
                  maxLines: 6,
                  onChanged: _store.setDescription,
                ),
              ),
              AppFormGap(
                AppLabeledDropdown<CampaignCategory>(
                  label: 'Categoria:',
                  value: _store.category,
                  options: CampaignCategory.values,
                  labelOf: (category) => category.label,
                  onChanged: _store.setCategory,
                ),
              ),
              AppFormGap(
                AppLabeledField(
                  key: const Key('campaign_goal'),
                  label: 'Meta financeira (R\$):',
                  hintText: '1.000,00',
                  initialValue: _store.goal,
                  keyboardType: TextInputType.number,
                  inputFormatters: [MoneyInputFormatter()],
                  onChanged: _store.setGoal,
                ),
              ),
              AppLabeledField(
                key: const Key('campaign_deadline'),
                label: 'Prazo da campanha:',
                hintText: 'dd/mm/aaaa',
                initialValue: _store.deadline,
                keyboardType: TextInputType.number,
                inputFormatters: [DateInputFormatter()],
                onChanged: _store.setDeadline,
              ),
              if (!_store.deadlineValid)
                const AppFormError('Informe uma data de hoje em diante.'),
            ],
          ),
        ),
      ),
    );
  }
}
