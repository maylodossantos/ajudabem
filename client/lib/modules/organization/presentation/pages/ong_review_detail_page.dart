import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/formatters/cep_input_formatter.dart';
import '../../../../core/formatters/cnpj_input_formatter.dart';
import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_info_banner.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/organization.dart';
import '../stores/organization_review_store.dart';
import '../widgets/organization_status_pill.dart';
import '../widgets/review_dialogs.dart';
import 'document_viewer_page.dart';

class OngReviewDetailPage extends StatefulWidget {
  const OngReviewDetailPage({required this.organization, super.key});

  final Organization organization;

  @override
  State<OngReviewDetailPage> createState() => _OngReviewDetailPageState();
}

class _OngReviewDetailPageState extends State<OngReviewDetailPage> {
  late final OrganizationReviewStore _store;

  @override
  void initState() {
    super.initState();
    _store = Modular.get<OrganizationReviewStore>()..init(widget.organization);
  }

  String? get _token {
    final token = Modular.get<LoginStore>().authToken;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
    }
    return token;
  }

  Future<void> _approve() async {
    if (!await showApproveOrganizationDialog(context)) return;
    final token = _token;
    if (token == null) return;

    final success = await _store.approve(token);
    if (!mounted) return;

    if (!success) {
      showAppSnackBar(
        context,
        _store.errorMessage ?? 'Não foi possível aprovar.',
      );
      return;
    }
    await showOrganizationApprovedDialog(context);
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _reject() async {
    final decision = await showRejectOrganizationDialog(context);
    if (decision == null) return;
    final token = _token;
    if (token == null) return;

    final (reason, note) = decision;
    final success = await _store.reject(reason, note, token);
    if (!mounted) return;

    showAppSnackBar(
      context,
      success
          ? 'Solicitação reprovada.'
          : _store.errorMessage ?? 'Não foi possível reprovar.',
    );
    if (success) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(showBackButton: true),
      bottomNavigationBar: const AppMainNavigation(
        currentItem: AppNavigationItem.profile,
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Observer(
              builder: (_) {
                final organization = _store.organization!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Detalhes da solicitação',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF232323),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Header(organization: organization),
                      const SizedBox(height: 20),
                      const AppInfoBanner(
                        message:
                            'Revise os dados cadastrais e os documentos '
                            'enviados pela organização para aprovar ou '
                            'reprovar a solicitação.',
                      ),
                      const SizedBox(height: 20),
                      _ReviewStepper(current: _store.step, onTap: _store.goTo),
                      const SizedBox(height: 20),
                      switch (_store.step) {
                        OrganizationReviewStoreBase.dataStep => _DataCard(
                          organization: organization,
                          onContinue: () => _store.goTo(
                            OrganizationReviewStoreBase.documentsStep,
                          ),
                        ),
                        OrganizationReviewStoreBase.documentsStep => _Documents(
                          organization: organization,
                          onContinue: () => _store.goTo(
                            OrganizationReviewStoreBase.decisionStep,
                          ),
                        ),
                        _ => _DecisionCard(
                          organization: organization,
                          isSubmitting: _store.isSubmitting,
                          onApprove: _approve,
                          onReject: _reject,
                        ),
                      },
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

class _Header extends StatelessWidget {
  const _Header({required this.organization});

  final Organization organization;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.manrope(
      color: AppColors.textMuted,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    );
    final valueStyle = GoogleFonts.manrope(
      color: const Color(0xFF454545),
      fontSize: 15,
      letterSpacing: 0,
    );
    final submittedAt = organization.submittedAt;

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: Color(0xFFD9D9D9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.apartment_rounded,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          organization.tradeName,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: const Color(0xFF454545),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        OrganizationStatusPill(status: organization.status),
        const SizedBox(height: 10),
        Text('CNPJ', style: labelStyle),
        Text(CnpjInputFormatter.display(organization.cnpj), style: valueStyle),
        if (submittedAt != null) ...[
          const SizedBox(height: 8),
          Text('Solicitado em', style: labelStyle),
          Text(
            DateInputFormatter.displayWithTime(submittedAt),
            style: valueStyle,
          ),
        ],
      ],
    );
  }
}

class _ReviewStepper extends StatelessWidget {
  const _ReviewStepper({required this.current, required this.onTap});

  final int current;
  final ValueChanged<int> onTap;

  static const _steps = [
    (Icons.description, 'Dados da ong'),
    (Icons.insert_drive_file_outlined, 'Documentos'),
    (Icons.check_circle_outline, 'Revisão'),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.only(top: 22),
                color: const Color(0xFF9E9E9E),
              ),
            ),
          InkWell(
            onTap: () => onTap(i),
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: 86,
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: i <= current ? primary : const Color(0xFF9E9E9E),
                      ),
                    ),
                    child: Icon(
                      _steps[i].$1,
                      size: 20,
                      color: i <= current
                          ? const Color(0xFF454545)
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${i + 1}', style: GoogleFonts.manrope(fontSize: 14)),
                  Text(
                    _steps[i].$2,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: i == current
                          ? FontWeight.w800
                          : FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OutlinedCard extends StatelessWidget {
  const _OutlinedCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF9E9E9E)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard({required this.organization, required this.onContinue});

  final Organization organization;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final address = [
      organization.street,
      organization.number,
    ].where((part) => part.isNotEmpty).join(', ');
    final fields = <(String, String)>[
      ('Razão social', organization.corporateName),
      ('Nome fantasia', organization.tradeName),
      ('CNPJ', CnpjInputFormatter.display(organization.cnpj)),
      ('Área de atuação', organization.activityArea),
      ('Endereço', address),
      ('Bairro', organization.neighborhood),
      ('Cidade / Estado', '${organization.city} / ${organization.state}'),
      ('CEP', CepInputFormatter.display(organization.zipCode)),
      if (organization.website?.isNotEmpty ?? false)
        ('Site', organization.website!),
      if (organization.instagram?.isNotEmpty ?? false)
        ('Instagram', organization.instagram!),
    ];

    return _OutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Dados da organização',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Confira as informações cadastradas pela ONG.',
            style: GoogleFonts.manrope(fontSize: 13, letterSpacing: 0),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < fields.length; i += 2) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Field(fields[i].$1, fields[i].$2)),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < fields.length
                      ? _Field(fields[i + 1].$1, fields[i + 1].$2)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          AppPrimaryButton(label: 'Continuar', onPressed: onContinue),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: AppColors.textMuted,
            fontSize: 13,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '—' : value,
          style: GoogleFonts.manrope(
            color: const Color(0xFF454545),
            fontSize: 13,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _Documents extends StatelessWidget {
  const _Documents({required this.organization, required this.onContinue});

  final Organization organization;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppInfoBanner(
          icon: Icons.description_outlined,
          message:
              'Todos os documentos são obrigatórios para a validação da '
              'organização.',
        ),
        const SizedBox(height: 20),
        Text(
          'Documentos enviados',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 12),
        for (final type in OrganizationDocumentType.values) ...[
          _DocumentTile(
            organizationId: organization.id,
            type: type,
            document: organization.documentOf(type),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        AppPrimaryButton(label: 'Concluir', onPressed: onContinue),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.organizationId,
    required this.type,
    required this.document,
  });

  final int organizationId;
  final OrganizationDocumentType type;
  final OrganizationDocument? document;

  @override
  Widget build(BuildContext context) {
    final document = this.document;
    final sentAt = document?.sentAt;

    return Material(
      color: const Color(0xFFFAFAFA),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: document == null
            ? null
            : () => Modular.to.pushNamed(
                AppRoutes.documentViewer,
                arguments: DocumentViewerArgs(
                  organizationId: organizationId,
                  document: document,
                ),
              ),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF454545),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF454545),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      document == null
                          ? 'Não enviado'
                          : sentAt == null
                          ? 'Enviado'
                          : 'Enviado em ${DateInputFormatter.display(sentAt)}',
                      style: GoogleFonts.manrope(
                        color: document == null
                            ? AppColors.danger
                            : AppColors.textMuted,
                        fontSize: 13,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF9E9E9E)),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({
    required this.organization,
    required this.isSubmitting,
    required this.onApprove,
    required this.onReject,
  });

  final Organization organization;
  final bool isSubmitting;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.manrope(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
    );
    final bodyStyle = GoogleFonts.manrope(fontSize: 14, letterSpacing: 0);
    final reviewedAt = organization.reviewedAt;

    final Widget content = switch (organization.status) {
      OrganizationStatus.pending => Column(
        children: [
          Text(
            'Todos os documentos foram revisados.',
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          const SizedBox(height: 6),
          Text(
            'A solicitação está pronta para ser aprovada ou reprovada.',
            textAlign: TextAlign.center,
            style: bodyStyle,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  key: const Key('ong_reject_button'),
                  label: 'Reprovar',
                  color: AppColors.danger,
                  onPressed: isSubmitting ? null : onReject,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppPrimaryButton(
                  key: const Key('ong_approve_button'),
                  label: 'Aprovar',
                  isLoading: isSubmitting,
                  onPressed: onApprove,
                ),
              ),
            ],
          ),
        ],
      ),
      OrganizationStatus.approved || OrganizationStatus.rejected => Column(
        children: [
          Text(
            organization.status == OrganizationStatus.approved
                ? 'Solicitação aprovada'
                : 'Solicitação reprovada',
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          if (reviewedAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Analisada em ${DateInputFormatter.displayWithTime(reviewedAt)}',
              textAlign: TextAlign.center,
              style: bodyStyle,
            ),
          ],
          if (organization.rejectionReason case final reason?) ...[
            const SizedBox(height: 6),
            Text(
              'Motivo: ${reason.label}',
              textAlign: TextAlign.center,
              style: bodyStyle,
            ),
          ],
          if (organization.rejectionNote?.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Text(
              organization.rejectionNote!,
              textAlign: TextAlign.center,
              style: bodyStyle,
            ),
          ],
        ],
      ),
    };

    return _OutlinedCard(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Icon(
            organization.status == OrganizationStatus.rejected
                ? Icons.highlight_off
                : Icons.check_circle_outline,
            size: 56,
            color: organization.status == OrganizationStatus.rejected
                ? AppColors.danger
                : AppColors.success,
          ),
          const SizedBox(height: 12),
          content,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
