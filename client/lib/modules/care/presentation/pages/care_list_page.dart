import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/geo/geo_point.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_async_list.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_card_actions.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/care_case.dart';
import '../../domain/entities/care_filter.dart';
import '../stores/care_list_store.dart';
import '../widgets/care_widgets.dart';

class CareListPage extends StatefulWidget {
  const CareListPage({
    required this.mode,
    super.key,
    this.store,
    this.token,
    this.initialFilter,
  });

  final CareListMode mode;
  final CareFilter? initialFilter;
  final CareListStore? store;
  final String? token;

  @override
  State<CareListPage> createState() => _CareListPageState();
}

class _CareListPageState extends State<CareListPage> {
  late final CareListStore _store;
  final _search = TextEditingController();

  String? get _token => widget.token ?? Modular.get<LoginStore>().authToken;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<CareListStore>();
    final filter = widget.initialFilter;
    if (filter != null) _store.applyFilter(filter);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }
    await _store.load(token, mode: widget.mode);
  }

  Future<void> _openFilters() async {
    final filter = await Modular.to.pushNamed<CareFilter>(
      AppRoutes.careFilter,
      arguments: (_store.filter, _store.options, widget.mode),
    );
    if (filter != null) _store.applyFilter(filter);
  }

  Future<void> _open(CareCase person) async {
    await Modular.to.pushNamed(AppRoutes.careCase, arguments: person.id);
    if (mounted) await _load();
  }

  Future<void> _assume(CareCase person) async {
    final token = _token;
    if (token == null) return;
    final success = await _store.assume(person.id, token);
    if (!mounted) return;
    showAppSnackBar(
      context,
      success
          ? 'Você assumiu o atendimento de ${person.fullName}.'
          : _store.errorMessage ?? 'Não foi possível assumir o atendimento.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final nominated = widget.mode == CareListMode.nominated;

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
              builder: (_) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: AppSearchField(
                      controller: _search,
                      hintText: nominated
                          ? 'Nome, necessidade, região...'
                          : 'Nome, responsável, região...',
                      onSearch: () => _store.setSearch(_search.text),
                      onFilter: _openFilters,
                      isFiltering: !_store.filter.isEmpty,
                    ),
                  ),
                  Expanded(
                    child: AppAsyncList<CareCase>(
                      items: _store.visibleCases,
                      isLoading: _store.isLoading,
                      errorMessage: _store.errorMessage,
                      emptyMessage: nominated
                          ? 'Nenhuma pessoa indicada aguardando uma ONG.'
                          : 'Sua ONG ainda não assumiu nenhum atendimento.',
                      onRefresh: _load,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemBuilder: (_, person) => nominated
                          ? _NominatedCard(
                              person: person,
                              isAssuming: _store.isAssuming(person.id),
                              onOpen: () => _open(person),
                              onAssume: () => _assume(person),
                            )
                          : _InCareCard(
                              person: person,
                              onOpen: () => _open(person),
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

class _CardShell extends StatelessWidget {
  const _CardShell({required this.person, required this.children});

  final CareCase person;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  person.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Text(
                'Urgência: ',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              UrgencyBar(urgency: person.urgency, width: 84),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

TextStyle _detail() =>
    GoogleFonts.manrope(color: const Color(0xFF232323), fontSize: 13.5);

class _NominatedCard extends StatelessWidget {
  const _NominatedCard({
    required this.person,
    required this.isAssuming,
    required this.onOpen,
    required this.onAssume,
  });

  final CareCase person;
  final bool isAssuming;
  final VoidCallback onOpen;
  final VoidCallback onAssume;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      person: person,
      children: [
        Text('Região: ${person.region}', style: _detail()),
        if (person.distanceKm case final km?) ...[
          const SizedBox(height: 6),
          Text(
            'Distância aproximada: ${GeoPoint.formatKm(km)}',
            style: _detail(),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          'Necessidades: ${person.needs.isEmpty ? 'não informadas' : person.needs.join(', ')}',
          style: _detail(),
        ),
        const SizedBox(height: 12),
        AppCardActions(
          secondaryLabel: 'Ver detalhes',
          onSecondary: onOpen,
          primaryLabel: 'Assumir atendimento',
          primaryKey: Key('care_assume_${person.id}'),
          isLoading: isAssuming,
          onPrimary: onAssume,
        ),
      ],
    );
  }
}

class _InCareCard extends StatelessWidget {
  const _InCareCard({required this.person, required this.onOpen});

  final CareCase person;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final started = person.careStartedAt;
    final days = person.daysWithoutUpdate(DateTime.now());
    final finished = person.status == CareStatus.finished;
    final stale = !finished && (days ?? 0) >= 3;

    return _CardShell(
      person: person,
      children: [
        if (started != null)
          Text(
            'Início: ${DateInputFormatter.display(started)}',
            style: _detail(),
          ),
        const SizedBox(height: 6),
        Text(
          'Responsável: ${person.organizationName ?? '—'}',
          style: _detail(),
        ),
        const SizedBox(height: 12),
        AppCardActions(
          secondaryLabel: finished
              ? (person.finishReason?.label ?? 'Finalizado')
              : days == null || days == 0
              ? 'Atualizado hoje'
              : '$days ${days == 1 ? 'dia' : 'dias'} sem atualização',
          secondaryLeading: Icon(
            finished ? Icons.check_circle_outline : Icons.info_outline,
            size: 18,
            color: stale ? const Color(0xFFE07B00) : null,
          ),
          onSecondary: onOpen,
          primaryLabel: 'Ver caso',
          onPrimary: onOpen,
        ),
      ],
    );
  }
}
