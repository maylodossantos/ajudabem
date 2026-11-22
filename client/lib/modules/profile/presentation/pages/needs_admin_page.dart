import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/tags/need_tag.dart';
import '../../../../core/tags/tags_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_async_list.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_item_actions_menu.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/app_text_input_dialog.dart';
import '../../../auth/presentation/stores/login_store.dart';

class NeedsAdminPage extends StatefulWidget {
  const NeedsAdminPage({super.key, this.store, this.token});

  final TagsStore? store;
  final String? token;

  @override
  State<NeedsAdminPage> createState() => _NeedsAdminPageState();
}

class _NeedsAdminPageState extends State<NeedsAdminPage> {
  late final TagsStore _store;
  int? _busyId;

  String? get _token => widget.token ?? Modular.get<LoginStore>().authToken;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<TagsStore>();
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

  Future<void> _edit([NeedTag? tag]) async {
    final name = await showAppTextInputDialog(
      context,
      title: tag == null ? 'Nova necessidade' : 'Renomear',
      initialValue: tag?.name ?? '',
      hintText: 'Higiene',
      fieldKey: const Key('need_name_field'),
      confirmKey: const Key('need_name_save'),
    );
    final token = _token;
    if (name == null || name.trim().isEmpty || token == null || !mounted) {
      return;
    }
    setState(() => _busyId = tag?.id);
    final ok = await _store.save(name, token, id: tag?.id);
    if (!mounted) return;
    setState(() => _busyId = null);
    showAppSnackBar(
      context,
      ok
          ? (tag == null ? 'Necessidade criada.' : 'Necessidade renomeada.')
          : _store.errorMessage ?? 'Não foi possível salvar.',
    );
  }

  Future<void> _delete(NeedTag tag) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Excluir "${tag.name}"?',
      message:
          'Ela deixa de aparecer nos cadastros. Pessoas já cadastradas '
          'com ela não são alteradas.',
      confirmLabel: 'Excluir',
    );
    final token = _token;
    if (!confirmed || token == null || !mounted) return;
    setState(() => _busyId = tag.id);
    final ok = await _store.delete(tag.id, token);
    if (!mounted) return;
    setState(() => _busyId = null);
    showAppSnackBar(
      context,
      ok
          ? 'Necessidade excluída.'
          : _store.errorMessage ?? 'Não foi possível excluir.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      currentItem: AppNavigationItem.profile,
      bottomBar: AppPrimaryButton(
        key: const Key('needs_add_button'),
        label: 'Nova necessidade',
        onPressed: () => _edit(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              'Necessidades',
              style: GoogleFonts.manrope(
                fontSize: AppTextSize.display,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) => AppAsyncList<NeedTag>(
                items: _store.tags,
                isLoading: _store.isLoading,
                errorMessage: _store.errorMessage,
                emptyMessage: 'Nenhuma necessidade cadastrada.',
                onRefresh: _load,
                spacing: 8,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemBuilder: (_, tag) => Container(
                  padding: const EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          tag.name,
                          style: GoogleFonts.manrope(
                            fontSize: AppTextSize.title,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AppItemActionsMenu(
                        key: Key('need_menu_${tag.id}'),
                        itemLabel: 'necessidade',
                        isBusy: _busyId == tag.id && _store.isSaving,
                        onEdit: () => _edit(tag),
                        onDelete: () => _delete(tag),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
