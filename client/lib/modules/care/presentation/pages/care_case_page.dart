import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/geo/geo_point.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card_actions.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_info_card.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/app_status_pill.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/care_case.dart';
import '../stores/care_case_store.dart';
import '../widgets/care_widgets.dart';

class CareCasePage extends StatefulWidget {
  const CareCasePage({
    required this.personId,
    super.key,
    this.store,
    this.token,
  });

  final int personId;
  final CareCaseStore? store;
  final String? token;

  @override
  State<CareCasePage> createState() => _CareCasePageState();
}

class _CareCasePageState extends State<CareCasePage> {
  late final CareCaseStore _store;

  String? get _token => widget.token ?? Modular.get<LoginStore>().authToken;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<CareCaseStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }
    await _store.load(widget.personId, token);
  }

  Future<void> _assume() async {
    final token = _token;
    if (token == null) return;
    final success = await _store.assume(token);
    if (!mounted) return;
    showAppSnackBar(
      context,
      success
          ? 'Atendimento assumido. Registre o primeiro andamento.'
          : _store.errorMessage ?? 'Não foi possível assumir o atendimento.',
    );
  }

  Future<void> _addRecord(CareCaseDetail detail) async {
    final updated = await Modular.to.pushNamed<CareCaseDetail>(
      AppRoutes.careRecord,
      arguments: detail,
    );
    if (updated != null) _store.show(updated);
  }

  @override
  Widget build(BuildContext context) {
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
                final detail = _store.detail;
                if (detail == null) {
                  final error = _store.errorMessage;
                  return error != null && !_store.isLoading
                      ? AppErrorView(message: error, onRetry: _load)
                      : const Center(child: CircularProgressIndicator());
                }

                final person = detail.person;
                final nominated = person.status == CareStatus.nominated;
                return RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CareCaseHeader(person: person),
                        const SizedBox(height: 14),
                        if (!nominated) ...[
                          CareStatusBanner(status: person.status),
                          if (person.finishReason case final reason?) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Resultado: ${reason.label}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                        ],
                        _PersonInfo(person: person),
                        const SizedBox(height: 14),
                        AppInfoCard(
                          title: 'Necessidades',
                          child: NeedChips(needs: person.needs),
                        ),
                        if (AppBulletList.linesOf(person.notes) case final notes
                            when notes.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          AppInfoCard(
                            title: 'Observações',
                            child: AppBulletList(lines: notes),
                          ),
                        ],
                        if (detail.referrals.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          AppInfoCard(
                            title: 'Encaminhamentos',
                            child: AppBulletList(lines: detail.referrals),
                          ),
                        ],
                        if (!nominated) ...[
                          const SizedBox(height: 14),
                          AppInfoCard(
                            title: 'Histórico',
                            child: detail.records.isEmpty
                                ? Text(
                                    'Nenhum andamento registrado ainda.',
                                    style: GoogleFonts.manrope(fontSize: 13),
                                  )
                                : Column(
                                    children: [
                                      for (final record
                                          in detail.records.reversed)
                                        _RecordTile(record: record),
                                    ],
                                  ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        if (nominated)
                          AppCardActions(
                            secondaryLabel: 'Voltar',
                            onSecondary: () => Navigator.of(context).pop(),
                            primaryLabel: 'Ajudar',
                            primaryKey: const Key('care_case_assume_button'),
                            isLoading: _store.isAssuming,
                            onPrimary: _assume,
                          )
                        else if (person.status == CareStatus.inCare)
                          AppPrimaryButton(
                            key: const Key('care_case_add_record_button'),
                            label: 'Adicionar Andamento',
                            onPressed: () => _addRecord(detail),
                          ),
                      ],
                    ),
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

class _PersonInfo extends StatelessWidget {
  const _PersonInfo({required this.person});

  final CareCase person;

  @override
  Widget build(BuildContext context) {
    final created = person.createdAt;
    final started = person.careStartedAt;

    return AppInfoCard(
      title: 'Informações',
      child: AppFieldGrid(
        fields: [
          ('Idade', person.age == null ? '' : '${person.age} anos'),
          ('Gênero', person.genderLabel),
          ('Região', person.region),
          (
            'Distância',
            person.distanceKm == null
                ? ''
                : GeoPoint.formatKm(person.distanceKm!),
          ),
          ('Endereço', person.addressLabel),
          ('Indicado em', DateInputFormatter.display(created)),
          if (person.organizationName case final name?) ('Responsável', name),
          if (started != null)
            ('Início do atendimento', DateInputFormatter.display(started)),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final CareRecord record;

  @override
  Widget build(BuildContext context) {
    final details = [
      ('Situação encontrada', record.situation),
      ('Ação realizada', record.actionTaken),
      ('Encaminhamento', record.referral),
      ('Próximo passo', record.nextStep),
      ('Resumo', record.summary),
      ('Observação', record.note),
      ('Motivo da finalização', record.finishReason?.label),
    ].where((field) => field.$2?.trim().isNotEmpty ?? false).toList();

    return Material(
      type: MaterialType.transparency,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: Key('care_record_${record.id}'),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(left: 24, bottom: 8),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: Icon(Icons.circle, size: 14, color: record.status.dot),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Andamento #${record.number}',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppStatusPill(
                label: record.status.label,
                color: const Color(0xFF232323),
                background: record.status.background,
              ),
            ],
          ),
          subtitle: Text(
            '${DateInputFormatter.displayWithTime(record.occurredAt)}\n'
            '${record.headline}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: const Color(0xFF454545),
              fontSize: 13,
            ),
          ),
          children: [
            for (final (label, value) in details)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$label: ',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: value),
                    ],
                  ),
                  style: GoogleFonts.manrope(fontSize: 13.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
