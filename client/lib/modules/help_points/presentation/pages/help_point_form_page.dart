import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/brazilian_states.dart';
import '../../../../core/formatters/cep_input_formatter.dart';
import '../../../../core/formatters/phone_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_choice_chip.dart';
import '../../../../core/widgets/app_cover_image_picker.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_labeled_field.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/help_point.dart';
import '../stores/help_point_form_store.dart';

class HelpPointFormPage extends StatefulWidget {
  const HelpPointFormPage({super.key, this.initial, this.store});

  final HelpPoint? initial;

  final HelpPointFormStore? store;

  @override
  State<HelpPointFormPage> createState() => _HelpPointFormPageState();
}

class _HelpPointFormPageState extends State<HelpPointFormPage> {
  late final HelpPointFormStore _store;

  static const _gap = SizedBox(height: 10);

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<HelpPointFormStore>();
    final initial = widget.initial;
    if (initial != null) {
      _store.populate(initial);
    }
  }

  Future<void> _submit() async {
    final token = Modular.get<LoginStore>().authToken;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

    final wasEditing = _store.isEditing;
    final success = await _store.submit(token);
    if (!mounted) return;

    showAppSnackBar(
      context,
      success
          ? wasEditing
                ? 'Ponto de ajuda atualizado!'
                : 'Ponto de ajuda cadastrado!'
          : _store.errorMessage ?? 'Não foi possível salvar.',
    );
    if (success) {
      Navigator.of(context).pop(wasEditing ? _store.saved : true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(showBackButton: true),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Observer(
              builder: (_) => ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  Text(
                    _store.isEditing
                        ? 'Editar ponto de ajuda'
                        : 'Novo ponto de ajuda',
                    style: GoogleFonts.manrope(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCoverImagePicker(store: _store.cover),
                  const SizedBox(height: 16),
                  AppLabeledField(
                    key: const Key('help_point_form_name'),
                    label: 'Nome:',
                    initialValue: _store.name,
                    onChanged: _store.setName,
                  ),
                  _gap,
                  AppLabeledDropdown<HelpPointOrganizationType>(
                    label: 'Tipo de organização:',
                    hintText: 'Selecione',
                    value: _store.organizationType,
                    options: HelpPointOrganizationType.values,
                    labelOf: (type) => type.label,
                    onChanged: _store.setOrganizationType,
                  ),
                  _gap,
                  Text('O que oferece:', style: AppFieldStyles.label),
                  const SizedBox(height: 8),
                  AppChoiceChipGroup<AssistanceType>(
                    options: AssistanceType.values,
                    labelOf: (type) => type.label,
                    isSelected: _store.services.contains,
                    onToggle: _store.toggleService,
                  ),
                  _gap,
                  AppLabeledField(
                    label: 'Descrição:',
                    initialValue: _store.description,
                    maxLines: 4,
                    onChanged: _store.setDescription,
                  ),
                  const SizedBox(height: 20),
                  const AppSectionTitle('Endereço'),
                  const SizedBox(height: 8),
                  AppLabeledField(
                    label: 'Rua:',
                    initialValue: _store.street,
                    onChanged: _store.setStreet,
                  ),
                  _gap,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppLabeledField(
                          label: 'Número:',
                          initialValue: _store.number,
                          onChanged: _store.setNumber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: AppLabeledField(
                          label: 'Bairro:',
                          initialValue: _store.neighborhood,
                          onChanged: _store.setNeighborhood,
                        ),
                      ),
                    ],
                  ),
                  _gap,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppLabeledField(
                          label: 'Cidade:',
                          initialValue: _store.city,
                          onChanged: _store.setCity,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppLabeledDropdown<String>(
                          label: 'Estado:',
                          hintText: 'UF',
                          value: _store.state,
                          options: BrazilianStates.codes,
                          labelOf: BrazilianStates.nameOf,
                          onChanged: _store.setState,
                        ),
                      ),
                    ],
                  ),
                  _gap,
                  AppLabeledField(
                    label: 'CEP:',
                    hintText: '00000-000',
                    initialValue: _store.zipCode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CepInputFormatter()],
                    onChanged: _store.setZipCode,
                  ),
                  const SizedBox(height: 20),
                  const AppSectionTitle('Contato'),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppLabeledField(
                          label: 'Telefone:',
                          initialValue: _store.phone,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [PhoneInputFormatter()],
                          onChanged: _store.setPhone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppLabeledField(
                          label: 'WhatsApp:',
                          initialValue: _store.whatsapp,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [PhoneInputFormatter()],
                          onChanged: _store.setWhatsapp,
                        ),
                      ),
                    ],
                  ),
                  _gap,
                  AppLabeledField(
                    label: 'E-mail:',
                    initialValue: _store.email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: _store.setEmail,
                  ),
                  _gap,
                  AppLabeledField(
                    label: 'Responsável:',
                    initialValue: _store.responsible,
                    onChanged: _store.setResponsible,
                  ),
                  const SizedBox(height: 20),
                  const AppSectionTitle('Horário de Funcionamento'),
                  const SizedBox(height: 4),
                  for (var day = DateTime.monday; day <= DateTime.sunday; day++)
                    _DayHoursRow(store: _store, weekday: day),
                  _gap,
                  AppLabeledField(
                    label: 'Observação do horário:',
                    hintText: 'Ex.: Feriados: 18h00 às 08h00',
                    initialValue: _store.scheduleNote,
                    onChanged: _store.setScheduleNote,
                  ),
                  _gap,
                  AppLabeledField(
                    label: 'Observações (uma por linha):',
                    initialValue: _store.notes,
                    maxLines: 4,
                    onChanged: _store.setNotes,
                  ),
                  const SizedBox(height: 28),
                  AppPrimaryButton(
                    key: const Key('help_point_form_submit'),
                    label: _store.isEditing ? 'Salvar alterações' : 'Cadastrar',
                    isLoading: _store.isLoading,
                    onPressed: _store.canSubmit ? _submit : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayHoursRow extends StatelessWidget {
  const _DayHoursRow({required this.store, required this.weekday});

  final HelpPointFormStore store;
  final int weekday;

  Future<void> _pickTime(BuildContext context, {required bool opening}) async {
    final hours = store.hours[weekday];
    if (hours == null) return;
    final current = opening ? hours.opensAt : hours.closesAt;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    store.setDayTimes(
      weekday,
      opensAt: opening ? minutes : null,
      closesAt: opening ? null : minutes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final hours = store.hours[weekday];
        final style = GoogleFonts.manrope(fontSize: 14, letterSpacing: 0);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Switch(
                value: hours != null,
                onChanged: (open) => store.setDayOpen(weekday, open),
              ),
              SizedBox(
                width: 64,
                child: Text(OpeningHours.dayNames[weekday - 1], style: style),
              ),
              if (hours == null)
                Expanded(child: Text('Fechado', style: style))
              else ...[
                if (!hours.isAllDay) ...[
                  TextButton(
                    onPressed: () => _pickTime(context, opening: true),
                    child: Text(OpeningHours.formatMinutes(hours.opensAt)),
                  ),
                  Text('às', style: style),
                  TextButton(
                    onPressed: () => _pickTime(context, opening: false),
                    child: Text(OpeningHours.formatMinutes(hours.closesAt)),
                  ),
                ] else
                  Text('24 horas', style: style),
                const Spacer(),
                PopupMenuButton<String>(
                  tooltip: 'Mais opções',
                  onSelected: (action) => action == 'all-day'
                      ? store.setDayAllDay(weekday, !hours.isAllDay)
                      : store.applyToAllDays(weekday),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'all-day',
                      child: Text(
                        hours.isAllDay ? 'Definir horário' : 'Aberto 24 horas',
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'repeat',
                      child: Text('Repetir em todos os dias'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
