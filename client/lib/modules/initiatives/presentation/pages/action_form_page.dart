import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/constants/brazilian_states.dart';
import '../../../../core/formatters/cep_input_formatter.dart';
import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/formatters/time_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_form_parts.dart';
import '../../../../core/widgets/app_labeled_field.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/volunteer_action.dart';
import '../stores/action_form_store.dart';

class ActionFormPage extends StatefulWidget {
  const ActionFormPage({super.key, this.initial, this.store, this.token});

  final VolunteerAction? initial;
  final ActionFormStore? store;
  final String? token;

  @override
  State<ActionFormPage> createState() => _ActionFormPageState();
}

class _ActionFormPageState extends State<ActionFormPage> {
  late final ActionFormStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<ActionFormStore>();
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
        _store.errorMessage ?? 'Não foi possível salvar a ação.',
      );
      return;
    }
    showAppSnackBar(
      context,
      widget.initial == null ? 'Ação criada!' : 'Ação atualizada.',
    );
    Navigator.of(context).pop(saved);
  }

  Widget _pair(Widget left, Widget right) => AppFormGap(
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      currentItem: AppNavigationItem.ong,
      bottomBar: Observer(
        builder: (_) => AppPrimaryButton(
          key: const Key('action_form_submit'),
          label: 'Concluir',
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
              AppFormGap(
                AppLabeledField(
                  key: const Key('action_title'),
                  label: 'Título:',
                  hintText: 'Ex.: Distribuição de alimentos',
                  initialValue: _store.title,
                  onChanged: _store.setTitle,
                ),
              ),
              AppFormGap(
                AppLabeledField(
                  key: const Key('action_date'),
                  label: 'Data:',
                  hintText: 'dd/mm/aaaa',
                  initialValue: _store.date,
                  keyboardType: TextInputType.number,
                  inputFormatters: [DateInputFormatter()],
                  onChanged: _store.setDate,
                ),
              ),
              _pair(
                AppLabeledField(
                  key: const Key('action_start'),
                  label: 'Início:',
                  hintText: 'hh:mm',
                  initialValue: _store.startTime,
                  keyboardType: TextInputType.number,
                  inputFormatters: [TimeInputFormatter()],
                  onChanged: _store.setStartTime,
                ),
                AppLabeledField(
                  key: const Key('action_end'),
                  label: 'Término:',
                  hintText: 'hh:mm',
                  initialValue: _store.endTime,
                  keyboardType: TextInputType.number,
                  inputFormatters: [TimeInputFormatter()],
                  onChanged: _store.setEndTime,
                ),
              ),
              if (_store.date.length == 10 && _store.actionDate == null)
                const AppFormError('Informe uma data de hoje em diante.'),
              if (_store.startTime.length == 5 &&
                  _store.endTime.length == 5 &&
                  !_store.timesValid)
                const AppFormError('O término deve ser depois do início.'),
              AppFormGap(
                AppLabeledField(
                  key: const Key('action_volunteers'),
                  label: 'Quantidade de Voluntários:',
                  initialValue: _store.volunteers,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: _store.setVolunteers,
                ),
              ),
              const AppFormHeading('Local da ação:'),
              AppFormGap(
                AppLabeledField(
                  key: const Key('action_street'),
                  label: 'Endereço:',
                  initialValue: _store.street,
                  onChanged: _store.setStreet,
                ),
              ),
              _pair(
                AppLabeledField(
                  key: const Key('action_city'),
                  label: 'Cidade:',
                  initialValue: _store.city,
                  onChanged: _store.setCity,
                ),
                AppLabeledDropdown<String>(
                  label: 'Estado:',
                  value: _store.state,
                  options: BrazilianStates.codes,
                  labelOf: BrazilianStates.nameOf,
                  onChanged: _store.setState,
                ),
              ),
              _pair(
                AppLabeledField(
                  label: 'CEP:',
                  initialValue: CepInputFormatter.display(_store.zipCode),
                  keyboardType: TextInputType.number,
                  inputFormatters: [CepInputFormatter()],
                  onChanged: _store.setZipCode,
                ),
                AppLabeledField(
                  label: 'Número:',
                  initialValue: _store.number,
                  onChanged: _store.setNumber,
                ),
              ),
              AppFormGap(
                AppLabeledField(
                  key: const Key('action_description'),
                  label: 'Descrição:',
                  hintText:
                      'Descreva o objetivo da ação e como ela será feita.',
                  initialValue: _store.description,
                  maxLines: 5,
                  onChanged: _store.setDescription,
                ),
              ),
              AppFormGap(
                AppLabeledField(
                  label: 'Afazeres:',
                  hintText: 'Uma atividade por linha.',
                  initialValue: _store.tasks,
                  maxLines: 5,
                  onChanged: _store.setTasks,
                ),
              ),
              AppFormGap(
                AppLabeledField(
                  label: 'Quem pode ajudar?',
                  hintText: 'Requisitos ou perfis ideais, um por linha.',
                  initialValue: _store.requirements,
                  maxLines: 4,
                  onChanged: _store.setRequirements,
                ),
              ),
              AppLabeledField(
                label: 'Observações:',
                hintText: 'Informações importantes para os voluntários.',
                initialValue: _store.notes,
                maxLines: 4,
                onChanged: _store.setNotes,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
