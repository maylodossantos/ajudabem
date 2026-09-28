import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/constants/brazilian_states.dart';
import '../../../../core/formatters/cep_input_formatter.dart';
import '../../../../core/formatters/cnpj_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_checkbox_tile.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_file_upload_tile.dart';
import '../../../../core/widgets/app_labeled_field.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/organization.dart';
import '../stores/organization_form_store.dart';
import '../widgets/step_dots.dart';

class OngValidationFormPage extends StatefulWidget {
  const OngValidationFormPage({super.key, this.previous, this.store});

  final Organization? previous;

  final OrganizationFormStore? store;

  @override
  State<OngValidationFormPage> createState() => _OngValidationFormPageState();
}

class _OngValidationFormPageState extends State<OngValidationFormPage> {
  late final OrganizationFormStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<OrganizationFormStore>();
    final previous = widget.previous;
    if (previous != null) {
      _store.populate(previous);
    }
  }

  void _back() {
    if (_store.step == OrganizationFormStoreBase.documentsStep) {
      _store.backToData();
      return;
    }
    Navigator.maybePop(context);
  }

  Future<void> _submit() async {
    final token = Modular.get<LoginStore>().authToken;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

    final success = await _store.submit(token);
    if (!mounted) {
      return;
    }

    showAppSnackBar(
      context,
      success
          ? 'Solicitação enviada para análise!'
          : _store.errorMessage ?? 'Não foi possível enviar a validação.',
    );

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AuthAppBar(showBackButton: true, onBack: _back),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Observer(
                builder: (_) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppSectionTitle('Preencha o formulário abaixo:'),
                      const SizedBox(height: 8),
                      StepDots(count: 2, current: _store.step),
                      const SizedBox(height: 16),
                      if (_store.step == OrganizationFormStoreBase.dataStep)
                        _DataStep(store: _store)
                      else
                        _DocumentsStep(store: _store, onSubmit: _submit),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DataStep extends StatelessWidget {
  const _DataStep({required this.store});

  final OrganizationFormStore store;

  static const _gap = SizedBox(height: 10);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppLabeledField(
          label: 'Razão Social:',
          initialValue: store.corporateName,
          onChanged: store.setCorporateName,
        ),
        _gap,
        AppLabeledField(
          label: 'Nome Fantasia:',
          initialValue: store.tradeName,
          onChanged: store.setTradeName,
        ),
        _gap,
        AppLabeledField(
          label: 'CNPJ:',
          hintText: '00.000.000/0000-00',
          initialValue: store.cnpj,
          keyboardType: TextInputType.number,
          inputFormatters: [CnpjInputFormatter()],
          onChanged: store.setCnpj,
        ),
        _gap,
        AppLabeledDropdown<String>(
          label: 'Área de atuação:',
          hintText: 'Selecione',
          value: store.activityArea,
          options: ActivityAreas.all,
          labelOf: (area) => area,
          onChanged: store.setActivityArea,
        ),
        _gap,
        AppLabeledField(
          label: 'Endereço:',
          initialValue: store.street,
          onChanged: store.setStreet,
        ),
        _gap,
        AppLabeledField(
          label: 'Bairro:',
          initialValue: store.neighborhood,
          onChanged: store.setNeighborhood,
        ),
        _gap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppLabeledField(
                label: 'Cidade:',
                initialValue: store.city,
                onChanged: store.setCity,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppLabeledDropdown<String>(
                label: 'Estado:',
                hintText: 'UF',
                value: store.state,
                options: BrazilianStates.codes,
                labelOf: BrazilianStates.nameOf,
                onChanged: store.setState,
              ),
            ),
          ],
        ),
        _gap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppLabeledField(
                label: 'CEP:',
                hintText: '00000-000',
                initialValue: store.zipCode,
                keyboardType: TextInputType.number,
                inputFormatters: [CepInputFormatter()],
                onChanged: store.setZipCode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppLabeledField(
                label: 'Número:',
                initialValue: store.number,
                onChanged: store.setNumber,
              ),
            ),
          ],
        ),
        _gap,
        AppLabeledField(
          label: 'Site:',
          hintText: 'Opcional',
          initialValue: store.website,
          keyboardType: TextInputType.url,
          onChanged: store.setWebsite,
        ),
        _gap,
        AppLabeledField(
          label: 'Instagram:',
          hintText: 'Opcional',
          initialValue: store.instagram,
          onChanged: store.setInstagram,
        ),
        const SizedBox(height: 28),
        AppPrimaryButton(
          key: const Key('ong_form_continue_button'),
          label: 'Continuar Cadastro',
          onPressed: store.canContinue ? store.goToDocuments : null,
        ),
      ],
    );
  }
}

class _DocumentsStep extends StatelessWidget {
  const _DocumentsStep({required this.store, required this.onSubmit});

  final OrganizationFormStore store;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    const bold = TextStyle(fontWeight: FontWeight.w800);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final type in OrganizationDocumentType.values) ...[
          _DocumentField(store: store, type: type),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 4),
        AppCheckboxTile(
          value: store.acceptedTerms,
          onChanged: store.setAcceptedTerms,
          label: const TextSpan(
            children: [
              TextSpan(text: 'Declaro que li e concordo com os '),
              TextSpan(text: 'Termos de Uso', style: bold),
              TextSpan(text: ' e a '),
              TextSpan(text: 'Política de Privacidade.', style: bold),
            ],
          ),
        ),
        AppCheckboxTile(
          value: store.acceptedDataProcessing,
          onChanged: store.setAcceptedDataProcessing,
          label: const TextSpan(
            text:
                'Autorizo o tratamento dos meus dados e dos dados da minha '
                'organização conforme a LGPD.',
          ),
        ),
        AppCheckboxTile(
          value: store.declaredTruthful,
          onChanged: store.setDeclaredTruthful,
          label: const TextSpan(
            text:
                'Confirmo que todas as informações fornecidas são verdadeiras '
                'e de minha responsabilidade.',
          ),
        ),
        const SizedBox(height: 24),
        AppPrimaryButton(
          key: const Key('ong_form_submit_button'),
          label: 'Concluir Cadastro',
          isLoading: store.isLoading,
          onPressed: store.canSubmit ? onSubmit : null,
        ),
      ],
    );
  }
}

class _DocumentField extends StatefulWidget {
  const _DocumentField({required this.store, required this.type});

  final OrganizationFormStore store;
  final OrganizationDocumentType type;

  @override
  State<_DocumentField> createState() => _DocumentFieldState();
}

class _DocumentFieldState extends State<_DocumentField> {
  bool _isPicking = false;

  Future<void> _pick() async {
    setState(() => _isPicking = true);
    final error = await widget.store.pickDocument(widget.type);
    if (!mounted) return;
    setState(() => _isPicking = false);
    if (error != null) {
      showAppSnackBar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final picked = widget.store.pickedDocuments[widget.type];
        final sentBefore = widget.store.sentDocuments[widget.type];

        return AppFileUploadTile(
          key: Key('ong_document_${widget.type.apiValue}'),
          label: '${widget.type.label}:',
          isDone: picked != null || sentBefore != null,
          isLoading: _isPicking,
          doneText: picked?.name ?? 'Documento enviado para análise',
          emptyText: 'Selecionar documento (PDF)',
          onTap: _pick,
        );
      },
    );
  }
}
