import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/constants/brazilian_states.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_cover_image_picker.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_form_parts.dart';
import '../../../../core/widgets/app_labeled_field.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/news_article.dart';
import '../stores/news_form_store.dart';

class NewsFormPage extends StatefulWidget {
  const NewsFormPage({super.key, this.initialArticle, this.store, this.token});

  final NewsArticle? initialArticle;
  final NewsFormStore? store;
  final String? token;

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  static const contentMaxLength = 10000;

  late final NewsFormStore _formStore;

  @override
  void initState() {
    super.initState();
    _formStore = widget.store ?? Modular.get<NewsFormStore>();

    final article = widget.initialArticle;
    if (article != null) {
      _formStore.populate(article);
    }
  }

  Future<void> _submit() async {
    final token = widget.token ?? Modular.get<LoginStore>().authToken;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

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

    if (!success) return;
    if (Modular.to.canPop()) {
      Modular.to.pop(_formStore.savedArticle);
    } else {
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
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AppFormHeading('Preencha as informações abaixo'),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'Informações gerais:',
                            style: AppFieldStyles.value.copyWith(
                              color: const Color(0xFF232323),
                              fontSize: 15,
                            ),
                          ),
                        ),
                        AppFormGap(
                          AppLabeledField(
                            key: const Key('news_form_title_field'),
                            label: 'Título:',
                            required: true,
                            initialValue: _formStore.title,
                            maxLength: 150,
                            onChanged: _formStore.setTitle,
                          ),
                        ),
                        AppFormGap(
                          AppLabeledField(
                            key: const Key('news_form_subtitle_field'),
                            label: 'Sub-Título',
                            initialValue: _formStore.subtitle,
                            maxLength: 200,
                            onChanged: _formStore.setSubtitle,
                          ),
                        ),
                        AppFormGap(
                          AppLabeledField(
                            key: const Key('news_form_content_field'),
                            label: 'Descrição:',
                            required: true,
                            initialValue: _formStore.content,
                            maxLines: 14,
                            minLines: 10,
                            maxLength: contentMaxLength,
                            onChanged: _formStore.setContent,
                          ),
                        ),
                        const AppFieldLabel('Capa:'),
                        const SizedBox(height: 4),
                        AppFormGap(
                          AppCoverImagePicker(
                            key: const Key('news_form_cover_image_picker'),
                            store: _formStore.cover,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 3,
                              child: AppLabeledField(
                                key: const Key('news_form_city_field'),
                                label: 'Cidade:',
                                hintText: 'Ex.: Cascavel',
                                initialValue: _formStore.city,
                                onChanged: _formStore.setCity,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Observer(
                                builder: (_) => AppLabeledDropdown<String>(
                                  label: 'Estado:',
                                  value: _formStore.state,
                                  options: BrazilianStates.codes,
                                  labelOf: (code) => code,
                                  onChanged: _formStore.setState,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Observer(
                  builder: (_) => Padding(
                    padding: const EdgeInsets.fromLTRB(28, 10, 28, 14),
                    child: AppPrimaryButton(
                      key: const Key('news_form_submit_button'),
                      label: _formStore.isEditing ? 'Salvar' : 'Publicar',
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
