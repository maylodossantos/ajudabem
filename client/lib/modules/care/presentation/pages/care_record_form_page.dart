import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/formatters/time_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/tags/tags_store.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_choice_chip.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_filter_scaffold.dart';
import '../../../../core/widgets/app_form_parts.dart';
import '../../../../core/widgets/app_labeled_field.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/auth_app_bar.dart';
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
    final statuses = _firstRecord
        ? const [CareRecordStatus.started, CareRecordStatus.finished]
        : const [CareRecordStatus.inProgress, CareRecordStatus.finished];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(showBackButton: true),
      bottomNavigationBar: const AppMainNavigation(
        currentItem: AppNavigationItem.ong,
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Observer(
              builder: (_) {
                final finishing = _store.status == CareRecordStatus.finished;
                final needOptions = {
                  ..._tags.tags.map((tag) => tag.name),
                  ..._store.needs,
                }.toList()..sort();

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CareCaseHeader(person: widget.detail.person),
                      const SizedBox(height: 8),
                      Text(
                        _firstRecord
                            ? 'Primeiro atendimento'
                            : 'Andamento #${widget.detail.records.length + 1}',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF232323),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      AppFilterSection(
                        title: 'Status',
                        child: AppChoiceChipGroup<CareRecordStatus>(
                          options: statuses,
                          labelOf: (status) => status.label,
                          isSelected: (status) => _store.status == status,
                          onToggle: _store.setStatus,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppLabeledField(
                              key: const Key('care_record_date_field'),
                              label: 'Data',
                              initialValue: _store.date,
                              hintText: 'dd/mm/aaaa',
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
                              hintText: 'hh:mm',
                              keyboardType: TextInputType.number,
                              inputFormatters: [TimeInputFormatter()],
                              onChanged: _store.setTime,
                            ),
                          ),
                        ],
                      ),
                      if (_store.occurredAt == null) ...[
                        const SizedBox(height: 6),
                        const AppFormError(
                          'Informe uma data e um horário válidos.',
                        ),
                      ] else if (_store.occurredAt!.isAfter(
                        DateTime.now(),
                      )) ...[
                        const SizedBox(height: 6),
                        const AppFormError(
                          'O atendimento não pode estar no futuro.',
                        ),
                      ],
                      if (needOptions.isNotEmpty)
                        AppFilterSection(
                          title: 'Necessidades',
                          child: AppChoiceChipGroup<String>(
                            options: needOptions,
                            labelOf: (need) => need,
                            isSelected: _store.needs.contains,
                            onToggle: _store.toggleNeed,
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (_firstRecord) ...[
                        _TextArea(
                          label: 'Situação encontrada',
                          value: _store.situation,
                          onChanged: _store.setSituation,
                        ),
                        _TextArea(
                          label: 'Ação realizada',
                          value: _store.actionTaken,
                          onChanged: _store.setActionTaken,
                        ),
                      ] else
                        _TextArea(
                          label: 'O que foi feito',
                          value: _store.actionTaken,
                          onChanged: _store.setActionTaken,
                        ),
                      _TextArea(
                        label: 'Encaminhamento',
                        value: _store.referral,
                        onChanged: _store.setReferral,
                      ),
                      if (finishing) ...[
                        AppLabeledDropdown<FinishReason>(
                          key: const Key('care_record_finish_reason'),
                          label: 'Motivo da finalização',
                          hintText: 'Selecione',
                          value: _store.finishReason,
                          options: FinishReason.values,
                          labelOf: (reason) => reason.label,
                          onChanged: _store.setFinishReason,
                        ),
                        const SizedBox(height: 14),
                        _TextArea(
                          label: 'Resumo final',
                          value: _store.summary,
                          onChanged: _store.setSummary,
                        ),
                      ] else
                        _TextArea(
                          label: 'Próximo passo',
                          value: _store.nextStep,
                          onChanged: _store.setNextStep,
                        ),
                      _TextArea(
                        label: 'Observação',
                        value: _store.note,
                        onChanged: _store.setNote,
                      ),
                      const SizedBox(height: 8),
                      AppPrimaryButton(
                        key: const Key('care_record_submit_button'),
                        label: finishing ? 'Finalizar atendimento' : 'Salvar',
                        isLoading: _store.isSaving,
                        onPressed: _store.canSubmit ? _submit : null,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
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
