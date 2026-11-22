import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/formatters/time_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/tags/tags_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_choice_chip.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_filter_scaffold.dart';
import '../../../../core/widgets/app_form_parts.dart';
import '../../../../core/widgets/app_labeled_field.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/care_case.dart';
import '../stores/care_record_form_store.dart';
import '../widgets/care_widgets.dart';

class CareRecordFormPage extends StatefulWidget {
  const CareRecordFormPage({
    required this.detail,
    super.key,
    this.store,
    this.tagsStore,
    this.token,
  });

  final CareCaseDetail detail;
  final CareRecordFormStore? store;
  final TagsStore? tagsStore;
  final String? token;

  @override
  State<CareRecordFormPage> createState() => _CareRecordFormPageState();
}

class _CareRecordFormPageState extends State<CareRecordFormPage> {
  late final CareRecordFormStore _store;
  late final TagsStore _tags;

  bool get _firstRecord => widget.detail.records.isEmpty;

  String? get _token => widget.token ?? Modular.get<LoginStore>().authToken;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<CareRecordFormStore>();
    _tags = widget.tagsStore ?? Modular.get<TagsStore>();
    _store.startWith(widget.detail.person, firstRecord: _firstRecord);
    final token = _token;
    if (token != null) _tags.ensureLoaded(token);
  }

  Future<void> _submit() async {
    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }
    final updated = await _store.submit(
      widget.detail.person.id,
      token,
      tagIdsOf: _tags.idsOf,
    );
    if (!mounted) return;
    if (updated == null) {
      showAppSnackBar(
        context,
        _store.errorMessage ?? 'Não foi possível salvar o andamento.',
      );
      return;
    }
    showAppSnackBar(context, 'Andamento registrado.');
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final finishing = _store.finishing;
        final status = _store.status;
        final needOptions = {
          ..._tags.tags.map((tag) => tag.name),
          ..._store.needs,
        }.toList()..sort();

        return AppPageScaffold(
          currentItem: AppNavigationItem.ong,
          bottomBar: finishing
              ? AppBottomActions(
                  secondaryKey: const Key('care_record_back_button'),
                  secondaryLabel: 'Voltar',
                  onSecondary: _store.cancelFinishing,
                  primaryKey: const Key('care_record_submit_button'),
                  primaryLabel: 'Finalizar',
                  isLoading: _store.isSaving,
                  onPrimary: _store.canSubmit ? _submit : null,
                )
              : AppBottomActions(
                  secondaryKey: const Key('care_record_finish_button'),
                  secondaryLabel: 'Finalizar',
                  onSecondary: _store.startFinishing,
                  primaryKey: const Key('care_record_submit_button'),
                  primaryLabel: 'Salvar',
                  isLoading: _store.isSaving,
                  onPrimary: _store.canSubmit ? _submit : null,
                ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Atendimento #${widget.detail.records.length + 1}',
                  style: GoogleFonts.manrope(
                    color: AppColors.textStrong,
                    fontSize: AppTextSize.heading,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  widget.detail.person.fullName,
                  style: GoogleFonts.manrope(
                    color: AppColors.textSecondary,
                    fontSize: AppTextSize.small,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 10),
                CareActionSelector(
                  key: const Key('care_record_action'),
                  value: status,
                  options: finishing
                      ? const []
                      : CareRecordStatus.actionsFor(firstRecord: _firstRecord),
                  onChanged: _store.setStatus,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppLabeledField(
                        key: const Key('care_record_date_field'),
                        label: 'Data',
                        initialValue: _store.date,
                        hintText: '14/10/2026',
                        keyboardType: TextInputType.number,
                        inputFormatters: [DateInputFormatter()],
                        onChanged: _store.setDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppLabeledField(
                        key: const Key('care_record_time_field'),
                        label: 'Horário',
                        initialValue: _store.time,
                        hintText: '14:30',
                        keyboardType: TextInputType.number,
                        inputFormatters: [TimeInputFormatter()],
                        onChanged: _store.setTime,
                      ),
                    ),
                  ],
                ),
                if (_store.occurredAt == null) ...[
                  const SizedBox(height: 6),
                  const AppFormError('Informe uma data e um horário válidos.'),
                ] else if (_store.occurredAt!.isAfter(DateTime.now())) ...[
                  const SizedBox(height: 6),
                  const AppFormError('O atendimento não pode estar no futuro.'),
                ],
                if (_firstRecord && !finishing && needOptions.isNotEmpty)
                  AppFilterSection(
                    title: 'Necessidades identificadas',
                    child: AppChoiceChipGroup<String>(
                      options: needOptions,
                      labelOf: (need) => need,
                      isSelected: _store.needs.contains,
                      onToggle: _store.toggleNeed,
                    ),
                  ),
                const SizedBox(height: 16),
                if (finishing) ...[
                  _TextArea(
                    label: 'Resumo do atendimento',
                    value: _store.summary,
                    onChanged: _store.setSummary,
                  ),
                  _TextArea(
                    label: 'Observação',
                    value: _store.note,
                    onChanged: _store.setNote,
                  ),
                  AppLabeledDropdown<FinishReason>(
                    key: const Key('care_record_finish_reason'),
                    label: 'Resultado do atendimento',
                    required: true,
                    hintText: 'Selecione',
                    value: _store.finishReason,
                    options: FinishReason.values,
                    labelOf: (reason) => reason.label,
                    onChanged: _store.setFinishReason,
                  ),
                ] else ...[
                  if (status.asksSituation)
                    _TextArea(
                      label: 'Situação identificada',
                      value: _store.situation,
                      onChanged: _store.setSituation,
                    ),
                  if (status.asksActionTaken)
                    _TextArea(
                      label: status.actionTakenLabel,
                      value: _store.actionTaken,
                      onChanged: _store.setActionTaken,
                    ),
                  if (status.asksReferral)
                    _TextArea(
                      label: status.referralLabel,
                      value: _store.referral,
                      onChanged: _store.setReferral,
                    ),
                  if (status.asksNextStep)
                    _TextArea(
                      label: status.nextStepLabel,
                      value: _store.nextStep,
                      onChanged: _store.setNextStep,
                    ),
                  _TextArea(
                    label: 'Observação',
                    value: _store.note,
                    onChanged: _store.setNote,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TextArea extends StatelessWidget {
  const _TextArea({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppLabeledField(
        key: Key('care_record_$label'),
        label: label,
        initialValue: value,
        maxLines: 4,
        onChanged: onChanged,
      ),
    );
  }
}
