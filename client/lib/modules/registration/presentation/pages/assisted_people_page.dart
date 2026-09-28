import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_async_list.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_item_actions_menu.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/assisted_person.dart';
import '../stores/assisted_people_store.dart';

class AssistedPeoplePage extends StatefulWidget {
  const AssistedPeoplePage({super.key, this.store, this.authToken});

  final AssistedPeopleStore? store;
  final String? authToken;

  @override
  State<AssistedPeoplePage> createState() => _AssistedPeoplePageState();
}

class _AssistedPeoplePageState extends State<AssistedPeoplePage> {
  late final AssistedPeopleStore _store;
  String? _token;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<AssistedPeopleStore>();
    _token = widget.authToken ?? Modular.get<LoginStore>().authToken;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

    await _store.load(token);
  }

  void _edit(AssistedPerson person) {
    Modular.to.pushNamed(
      AppRoutes.vulnerablePersonRegistration,
      arguments: person,
    );
  }

  Future<void> _confirmDelete(AssistedPerson person) async {
    final shouldDelete = await showAppConfirmDialog(
      context,
      title: 'Excluir cadastro?',
      message:
          'O cadastro de ${person.fullName} será excluído permanentemente.',
      confirmLabel: 'Excluir',
    );

    if (!shouldDelete || !mounted) return;

    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

    final deleted = await _store.deletePerson(person.id, token);
    if (!mounted) return;

    showAppSnackBar(
      context,
      deleted
          ? 'Cadastro excluído com sucesso.'
          : _store.errorMessage ?? 'Não foi possível excluir o cadastro.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AuthAppBar(
        showBackButton: true,
        onBack: () => Modular.to.pushReplacementNamed(AppRoutes.profile),
      ),
      bottomNavigationBar: const AppMainNavigation(
        key: Key('assisted_people_bottom_navigation'),
        currentItem: AppNavigationItem.profile,
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionTitle('Pessoas cadastradas'),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Observer(
                      builder: (_) => AppAsyncList(
                        items: _store.people,
                        isLoading: _store.isLoading,
                        errorMessage: _store.errorMessage,
                        emptyMessage: 'Nenhuma pessoa cadastrada.',
                        onRefresh: _load,
                        spacing: 9,
                        itemBuilder: (_, person) => Observer(
                          builder: (_) => _PersonCard(
                            person: person,
                            isDeleting: _store.isDeleting(person.id),
                            onEdit: () => _edit(person),
                            onDelete: () => _confirmDelete(person),
                          ),
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

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.person,
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  final AssistedPerson person;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF232323),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  person.statusLabel,
                  style: GoogleFonts.manrope(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          AppItemActionsMenu(
            tooltip: 'Opções do cadastro',
            isBusy: isDeleting,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}
