import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_status_view.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../../profile/presentation/stores/profile_store.dart';
import '../../domain/entities/organization.dart';
import '../stores/organization_validation_store.dart';

class OngValidationPage extends StatefulWidget {
  const OngValidationPage({super.key});

  @override
  State<OngValidationPage> createState() => _OngValidationPageState();
}

class _OngValidationPageState extends State<OngValidationPage> {
  late final LoginStore _loginStore;
  late final OrganizationValidationStore _store;

  @override
  void initState() {
    super.initState();
    _loginStore = Modular.get<LoginStore>();
    _store = Modular.get<OrganizationValidationStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = _loginStore.authToken;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

    await _store.load(token);

    final profileStore = Modular.get<ProfileStore>();
    if (_store.organization?.status == OrganizationStatus.approved &&
        profileStore.profile?.isOng != true) {
      await profileStore.load(token);
    }
  }

  Future<void> _openForm([Organization? previous]) async {
    await Modular.to.pushNamed(
      AppRoutes.ongValidationForm,
      arguments: previous,
    );
    if (mounted) {
      await _load();
    }
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
        child: Observer(
          builder: (_) {
            if (_store.isLoading && !_store.hasLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final error = _store.errorMessage;
            if (error != null && !_store.hasLoaded) {
              return AppErrorView(message: error, onRetry: _load);
            }

            return _statusFor(_store.organization);
          },
        ),
      ),
    );
  }

  Widget _statusFor(Organization? organization) {
    if (organization == null) {
      return AppStatusView(
        key: const Key('ong_validation_start'),
        illustration: Image.asset('assets/illustrations/ong_retry.png'),
        title: 'Valide sua ONG',
        message:
            'Envie os dados e os documentos da sua organização para liberar '
            'os recursos exclusivos para ONGs.',
        actionLabel: 'Validar ONG',
        onAction: _openForm,
      );
    }

    final now = DateTime.now();
    return switch (organization.status) {
      OrganizationStatus.pending => AppStatusView(
        key: const Key('ong_validation_pending'),
        illustration: Icon(
          Icons.hourglass_top_rounded,
          size: 140,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: 'Solicitação em análise',
        message:
            'Recebemos os dados da ${organization.tradeName}. Assim que a '
            'análise terminar, o resultado aparece aqui.',
      ),
      OrganizationStatus.approved => AppStatusView(
        key: const Key('ong_validation_approved'),
        illustration: Image.asset('assets/illustrations/ong_approved.png'),
        title: 'Sua ONG foi aprovada!',
        message:
            'Agora você já pode acessar as funcionalidades da área de ONGs.',
        actionLabel: 'Ir para ONGs',
        onAction: () => Modular.to.navigate(AppRoutes.ong),
      ),
      OrganizationStatus.rejected when organization.canResubmitAt(now) =>
        AppStatusView(
          key: const Key('ong_validation_retry'),
          illustration: Image.asset('assets/illustrations/ong_retry.png'),
          title: 'Você já pode solicitar a validação!',
          message:
              'Revise os documentos indicados e envie uma nova solicitação de '
              'validação.',
          footer: _RejectionReasonCard(organization: organization),
          actionLabel: 'Validar ONG',
          onAction: () => _openForm(organization),
        ),
      OrganizationStatus.rejected => AppStatusView(
        key: const Key('ong_validation_rejected'),
        illustration: Image.asset('assets/illustrations/ong_rejected.png'),
        title: 'Sua ONG não foi aprovada',
        message: 'Aguarde para solicitar uma nova validação.',
        footer: Column(
          children: [
            _WaitingTime(days: organization.daysUntilResubmit(now)),
            const SizedBox(height: 16),
            _RejectionReasonCard(organization: organization),
          ],
        ),
      ),
    };
  }
}

class _WaitingTime extends StatelessWidget {
  const _WaitingTime({required this.days});

  final int days;

  static const _totalDays = 7;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: 56,
          child: CircularProgressIndicator(
            value: 1 - (days / _totalDays).clamp(0, 1),
            strokeWidth: 28,
            color: primary,
            backgroundColor: const Color(0xFFE9E9E9),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          days == 1 ? '1 dia' : '$days dias',
          style: GoogleFonts.manrope(
            color: primary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _RejectionReasonCard extends StatelessWidget {
  const _RejectionReasonCard({required this.organization});

  final Organization organization;

  @override
  Widget build(BuildContext context) {
    final reason = organization.rejectionReason;
    final note = organization.rejectionNote;
    if (reason == null && (note == null || note.isEmpty)) {
      return const SizedBox.shrink();
    }

    final textStyle = GoogleFonts.manrope(
      color: const Color(0xFF454545),
      fontSize: 13,
      height: 1.35,
      letterSpacing: 0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reason != null)
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Motivo: ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: reason.label),
                ],
              ),
              style: textStyle,
            ),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(note, style: textStyle),
          ],
        ],
      ),
    );
  }
}
