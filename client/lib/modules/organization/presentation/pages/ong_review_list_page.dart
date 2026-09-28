import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/formatters/cnpj_input_formatter.dart';
import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_async_list.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/organization.dart';
import '../stores/organization_review_list_store.dart';
import '../widgets/organization_status_pill.dart';

class OngReviewListPage extends StatefulWidget {
  const OngReviewListPage({super.key});

  @override
  State<OngReviewListPage> createState() => _OngReviewListPageState();
}

class _OngReviewListPageState extends State<OngReviewListPage> {
  late final OrganizationReviewListStore _store;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _store = Modular.get<OrganizationReviewListStore>();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? get _token {
    final token = Modular.get<LoginStore>().authToken;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
    }
    return token;
  }

  Future<void> _load() async {
    final token = _token;
    if (token != null) {
      await _store.load(token);
    }
  }

  Future<void> _search() {
    _store.setSearch(_searchController.text);
    return _load();
  }

  Future<void> _filter(OrganizationStatus? status) async {
    final token = _token;
    if (token != null) {
      await _store.setFilter(status, token);
    }
  }

  Future<void> _open(Organization organization) async {
    final reviewed = await Modular.to.pushNamed<bool>(
      AppRoutes.ongReviewDetail,
      arguments: organization,
    );
    if (reviewed == true && mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.manrope(
      color: const Color(0xFF232323),
      fontSize: 18,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
    );

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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Validações de ONGs', style: titleStyle),
                  const SizedBox(height: 4),
                  Text(
                    'Analise e aprove as solicitações de cadastro enviadas '
                    'pelas organizações.',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF232323),
                      fontSize: 13,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppSearchField(
                    key: const Key('ong_review_search_field'),
                    controller: _searchController,
                    hintText: 'CNPJ, Nome',
                    onSearch: _search,
                  ),
                  const SizedBox(height: 12),
                  Observer(
                    builder: (_) => _StatusFilters(
                      selected: _store.filter,
                      onSelected: _filter,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Observer(
                      builder: (_) => AppAsyncList<Organization>(
                        items: _store.organizations,
                        isLoading: _store.isLoading,
                        errorMessage: _store.errorMessage,
                        emptyMessage: 'Nenhuma solicitação encontrada.',
                        onRefresh: _load,
                        itemBuilder: (_, organization) => _RequestCard(
                          organization: organization,
                          onTap: () => _open(organization),
                        ),
                      ),
                    ),
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

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({required this.selected, required this.onSelected});

  final OrganizationStatus? selected;
  final ValueChanged<OrganizationStatus?> onSelected;

  static const _options = <(OrganizationStatus?, String)>[
    (null, 'Todas'),
    (OrganizationStatus.pending, 'Pendentes'),
    (OrganizationStatus.approved, 'Aprovadas'),
    (OrganizationStatus.rejected, 'Reprovadas'),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (status, label) in _options) ...[
            Material(
              color: status == selected ? primary : Colors.white,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () => onSelected(status),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.manrope(
                      color: status == selected ? Colors.white : primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.organization, required this.onTap});

  final Organization organization;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final detailStyle = GoogleFonts.manrope(
      color: const Color(0xFF454545),
      fontSize: 13,
      letterSpacing: 0,
    );
    final submittedAt = organization.submittedAt;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
          decoration: BoxDecoration(
            border: Border.all(color: primary),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      organization.tradeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  OrganizationStatusPill(status: organization.status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'CNPJ: ${CnpjInputFormatter.display(organization.cnpj)}',
                      style: detailStyle,
                    ),
                  ),
                  if (submittedAt != null)
                    Text(
                      DateInputFormatter.display(submittedAt),
                      style: detailStyle,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ver solicitação',
                      style: GoogleFonts.manrope(
                        color: primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
