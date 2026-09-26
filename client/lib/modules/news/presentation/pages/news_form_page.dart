import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/news_article.dart';
import '../stores/news_form_store.dart';

class NewsFormPage extends StatefulWidget {
  const NewsFormPage({super.key, this.initialArticle});

  final NewsArticle? initialArticle;

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  late final LoginStore _loginStore;
  late final NewsFormStore _formStore;
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _loginStore = Modular.get<LoginStore>();
    _formStore = Modular.get<NewsFormStore>();

    final article = widget.initialArticle;
    if (article != null) {
      _formStore.populate(article);
    }

    _titleController = TextEditingController(text: _formStore.title);
    _subtitleController = TextEditingController(text: _formStore.subtitle);
    _contentController = TextEditingController(text: _formStore.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() =>
      pickAndUploadGalleryImage(context, _formStore.cover);

  Future<void> _submit() async {
    final token = _loginStore.authToken;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

    _formStore.setTitle(_titleController.text);
    _formStore.setSubtitle(_subtitleController.text);
    _formStore.setContent(_contentController.text);

    final wasEditing = _formStore.isEditing;
    final success = await _formStore.submit(token);

    if (!mounted) {
      return;
    }

    showAppSnackBar(
      context,
      success
          ? wasEditing
                ? 'Notícia atualizada com sucesso!'
                : 'Notícia publicada com sucesso!'
          : _formStore.errorMessage ?? 'Não foi possível salvar a notícia.',
    );

    if (success) {
      Modular.to.navigate(AppRoutes.news);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(showBackButton: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Observer(
                          builder: (_) => Text(
                            _formStore.isEditing
                                ? 'Editar notícia'
                                : 'Nova notícia',
                            style: GoogleFonts.manrope(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Observer(
                          builder: (_) => _CoverImagePicker(
                            imageUrl: _formStore.cover.imageUrl,
                            isUploading: _formStore.cover.isUploading,
                            onTap: _pickCoverImage,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          key: const Key('news_form_title_field'),
                          label: 'Título:',
                          hintText: 'Título da notícia',
                          controller: _titleController,
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          key: const Key('news_form_subtitle_field'),
                          label: 'Subtítulo:',
                          hintText: 'Subtítulo (opcional)',
                          controller: _subtitleController,
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          key: const Key('news_form_content_field'),
                          label: 'Conteúdo:',
                          hintText: 'Escreva o conteúdo da notícia',
                          controller: _contentController,
                          maxLines: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                Observer(
                  builder: (_) => Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: AppPrimaryButton(
                      key: const Key('news_form_submit_button'),
                      label: _formStore.isEditing
                          ? 'Salvar alterações'
                          : 'Publicar',
                      onPressed: _formStore.canSubmit ? _submit : null,
                      isLoading: _formStore.isLoading,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoverImagePicker extends StatelessWidget {
  const _CoverImagePicker({
    required this.imageUrl,
    required this.isUploading,
    required this.onTap,
  });

  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return GestureDetector(
      key: const Key('news_form_cover_image_picker'),
      onTap: isUploading ? null : onTap,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(8),
            image: hasImage
                ? DecorationImage(
                    image: NetworkImage(imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: isUploading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : hasImage
              ? null
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 32,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Adicionar capa',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
