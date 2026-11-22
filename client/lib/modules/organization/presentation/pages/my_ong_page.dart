import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/formatters/cep_input_formatter.dart';
import '../../../../core/formatters/cnpj_input_formatter.dart';
import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_info_card.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/organization.dart';
import '../stores/organization_validation_store.dart';
import '../widgets/organization_widgets.dart';

class MyOngPage extends StatefulWidget {
  const MyOngPage({super.key, this.store, this.token});

  final OrganizationValidationStore? store;
  final String? token;

  @override
  State<MyOngPage> createState() => _MyOngPageState();
}

class _MyOngPageState extends State<MyOngPage> {
  late final OrganizationValidationStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<OrganizationValidationStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  String? get _token => widget.token ?? Modular.get<LoginStore>().authToken;

  Future<void> _load() async {
    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }
    await _store.load(token);
  }

  Future<void> _editContact(Organization organization) async {
    final saved = await Modular.to.pushNamed<bool>(
      AppRoutes.ongContactForm,
      arguments: organization,
    );
    if (saved == true && mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      currentItem: AppNavigationItem.profile,
      body: Observer(
        builder: (_) {
          final organization = _store.organization;
          if (organization == null) {
            final error = _store.errorMessage;
            if (error != null) {
              return AppErrorView(message: error, onRetry: _load);
            }
            if (_store.hasLoaded) {
              return AppErrorView(
                message: 'Nenhuma ONG vinculada a esta conta.',
                onRetry: _load,
              );
            }
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _Header(organization: organization),
              const SizedBox(height: 20),
              _Section(
                title: 'Dados oficiais',
                trailing: const Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                note: 'Para alterar estes dados é preciso uma nova validação.',
                child: OrganizationFieldGrid(
                  fields: [
                    ('Razão social', organization.corporateName),
                    ('Nome fantasia', organization.tradeName),
                    ('CNPJ', CnpjInputFormatter.display(organization.cnpj)),
                    ('Área de atuação', organization.activityArea),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: 'Contato e endereço',
                trailing: IconButton(
                  key: const Key('my_ong_edit_contact'),
                  tooltip: 'Editar contato e endereço',
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => _editContact(organization),
                ),
                child: OrganizationFieldGrid(
                  fields: _contactFields(organization),
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: 'Documentos',
                child: Column(
                  children: [
                    for (final type in OrganizationDocumentType.values) ...[
                      OrganizationDocumentTile(
                        organizationId: organization.id,
                        type: type,
                        document: organization.documentOf(type),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static List<(String, String)> _contactFields(Organization organization) {
    final address = [
      organization.street,
      organization.number,
    ].where((part) => part.isNotEmpty).join(', ');

    return [
      ('Endereço', address),
      ('Bairro', organization.neighborhood),
      ('Cidade / Estado', '${organization.city} / ${organization.state}'),
      ('CEP', CepInputFormatter.display(organization.zipCode)),
      ('Site', organization.website ?? ''),
      ('Instagram', organization.instagram ?? ''),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.organization});

  final Organization organization;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final reviewedAt = organization.reviewedAt;
    final approved = organization.status == OrganizationStatus.approved;

    return Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.white,
          child: Icon(Icons.diversity_3_outlined, size: 36, color: primary),
        ),
        const SizedBox(height: 10),
        Text(
          organization.tradeName,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: AppColors.textStrong,
            fontSize: AppTextSize.display,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        AppBadge(
          label: approved && reviewedAt != null
              ? 'Verificada desde ${DateInputFormatter.display(reviewedAt)}'
              : organization.status.label,
          tone: approved ? AppTone.success : AppTone.warning,
          icon: approved ? Icons.verified_outlined : null,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.trailing,
    this.note,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return AppInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.manrope(
                      color: AppColors.textStrong,
                      fontSize: AppTextSize.title,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          const SizedBox(height: 6),
          child,
          if (note case final note?) ...[
            const SizedBox(height: 12),
            Text(
              note,
              style: GoogleFonts.manrope(
                color: AppColors.textMuted,
                fontSize: AppTextSize.caption,
                letterSpacing: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
