import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_cover_image.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_info_card.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/news_article.dart';
import '../stores/news_store.dart';

class NewsManageDetailPage extends StatefulWidget {
  const NewsManageDetailPage({
    required this.article,
    super.key,
    this.store,
    this.token,
  });

  final NewsArticle article;
  final NewsStore? store;
  final String? token;

  @override
  State<NewsManageDetailPage> createState() => _NewsManageDetailPageState();
}

class _NewsManageDetailPageState extends State<NewsManageDetailPage> {
  late final NewsStore _store;
  late NewsArticle _article;

  String? get _token => widget.token ?? Modular.get<LoginStore>().authToken;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<NewsStore>();
    _article = widget.article;
  }

  Future<void> _edit() async {
    final saved = await Modular.to.pushNamed<NewsArticle>(
      AppRoutes.newsForm,
      arguments: _article,
    );
    if (saved != null && mounted) setState(() => _article = saved);
  }

  Future<void> _delete() async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Excluir notícia?',
      message: 'A notícia "${_article.title}" será excluída permanentemente.',
      confirmLabel: 'Excluir',
    );
    if (!confirmed || !mounted) return;

    final token = _token;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

    final deleted = await _store.deleteArticle(_article.id, token);
    if (!mounted) return;

    showAppSnackBar(
      context,
      deleted
          ? 'Notícia excluída com sucesso.'
          : _store.errorMessage ?? 'Não foi possível excluir a notícia.',
    );
    if (deleted) Modular.to.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.manrope(
      color: const Color(0xFF232323),
      fontSize: 13.5,
      height: 1.45,
      letterSpacing: 0,
    );

    return AppPageScaffold(
      currentItem: AppNavigationItem.profile,
      maxWidth: 560,
      bottomBar: Observer(
        builder: (_) => AppBottomActions(
          secondaryLabel: 'Excluir',
          secondaryKey: const Key('news_manage_delete'),
          secondaryColor: AppColors.danger,
          onSecondary: _store.isDeleting(_article.id) ? null : _delete,
          primaryLabel: 'Editar',
          primaryKey: const Key('news_manage_edit'),
          onPrimary: _edit,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        children: [
          AppCoverImage(
            imageUrl: _article.coverImage,
            aspectRatio: 1.83,
            borderRadius: BorderRadius.circular(10),
            placeholder: const ColoredBox(
              color: Color(0xFFA2A2A2),
              child: Icon(Icons.newspaper, size: 56, color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          AppInfoCard(
            title: 'Título',
            child: Text(_article.title, style: bodyStyle),
          ),
          if (_article.subtitle.isNotEmpty) ...[
            const SizedBox(height: 14),
            AppInfoCard(
              title: 'Sub-Título',
              child: Text(_article.subtitle, style: bodyStyle),
            ),
          ],
          const SizedBox(height: 14),
          AppInfoCard(
            title: 'Descrição',
            child: SelectableText(_article.content, style: bodyStyle),
          ),
        ],
      ),
    );
  }
}
