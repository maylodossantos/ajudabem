import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
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
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir cadastro?'),
        content: Text(
          'O cadastro de ${person.fullName} será excluído permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

    final deleted = await _store.deletePerson(person.id, token);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? 'Cadastro excluído com sucesso.'
              : _store.errorMessage ?? 'Não foi possível excluir o cadastro.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AuthAppBar(showBackButton: true, onBack: () {
        Modular.to.pushReplacementNamed(
            "/profile/"
        );
      }),
      bottomNavigationBar: AppBottomNavigation(
        key: const Key('assisted_people_bottom_navigation'),
        currentItem: AppNavigationItem.profile,
        onProfile: () => Modular.to.navigate(AppRoutes.profile),
        onRegister: () => Modular.to.navigate(AppRoutes.registrationMenu),
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
                  Text(
                    'Pessoas cadastradas',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF232323),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Observer(
                      builder: (_) {
                        if (_store.isLoading && _store.people.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (_store.errorMessage != null &&
                            _store.people.isEmpty) {
                          return _ListError(
                            message: _store.errorMessage!,
                            onRetry: _load,
                          );
                        }

                        if (_store.people.isEmpty) {
                          return Center(
                            child: Text(
                              'Nenhuma pessoa cadastrada.',
                              style: GoogleFonts.manrope(
                                color: const Color(0xFF454545),
                                fontSize: 14,
                              ),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _store.people.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 9),
                            itemBuilder: (_, index) {
                              final person = _store.people[index];
                              return _PersonCard(
                                person: person,
                                isDeleting: _store.isDeleting(person.id),
                                onEdit: () => _edit(person),
                                onDelete: () => _confirmDelete(person),
                              );
                            },
                          ),
                        );
                      },
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
                  _statusByRiskLevel[person.riskLevel] ?? 'Em análise',
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
          if (isDeleting)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            PopupMenuButton<_PersonAction>(
              tooltip: 'Opções do cadastro',
              onSelected: (action) {
                if (action == _PersonAction.edit) {
                  onEdit();
                } else {
                  onDelete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: _PersonAction.edit,
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _PersonAction.delete,
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline),
                      SizedBox(width: 10),
                      Text('Excluir'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static const _statusByRiskLevel = {
    'LOW': 'Informações recebidas.',
    'MEDIUM': 'Em análise',
    'HIGH': 'Atendimento iniciado',
  };
}

enum _PersonAction { edit, delete }

class _ListError extends StatelessWidget {
  const _ListError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
