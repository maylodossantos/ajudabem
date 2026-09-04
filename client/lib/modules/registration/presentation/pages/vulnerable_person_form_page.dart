import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/assisted_person.dart';
import '../stores/vulnerable_person_form_store.dart';

class VulnerablePersonFormPage extends StatelessWidget {
  const VulnerablePersonFormPage({
    super.key,
    this.store,
    this.authToken,
    this.initialPerson,
  });

  final VulnerablePersonFormStore? store;
  final String? authToken;
  final AssistedPerson? initialPerson;

  @override
  Widget build(BuildContext context) {
    final formStore = store ?? Modular.get<VulnerablePersonFormStore>();
    final token = authToken ?? Modular.get<LoginStore>().authToken;
    final person = initialPerson;
    if (person != null && !formStore.isEditing) {
      formStore.populate(person);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AuthAppBar(showBackButton: true, onBack: Modular.to.pop),
      bottomNavigationBar: Observer(
        builder: (_) => _SubmitBar(
          onPressed: formStore.canSubmit
              ? () => _submit(context, formStore, token)
              : null,
          isLoading: formStore.isLoading,
          isEditing: formStore.isEditing,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 24),
              child: Observer(
                builder: (_) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Preencha as informações abaixo'),
                    const SizedBox(height: 14),
                    const _Question(
                      title: 'Você tem informações pessoais dessa pessoa?',
                      helper:
                          'A pessoa forneceu os dados diretamente ou autorizou '
                          'você a compartilhá-los.',
                    ),
                    const SizedBox(height: 8),
                    _BinaryChoice(
                      value: formStore.hasPersonalInformation,
                      onChanged: formStore.setHasPersonalInformation,
                    ),
                    const SizedBox(height: 18),
                    const _SectionTitle('Informações Gerais'),
                    const SizedBox(height: 10),
                    _FormField(
                      label: 'Nome:',
                      initialValue: formStore.name,
                      onChanged: formStore.setName,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _FormField(
                            label: 'Idade:',
                            initialValue: formStore.age,
                            keyboardType: TextInputType.number,
                            onChanged: formStore.setAge,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SelectionField(
                            label: 'Sexo:',
                            value: formStore.sex,
                            options: const [
                              'Masculino',
                              'Feminino',
                              'Outro',
                              'Prefiro não informar',
                            ],
                            onChanged: formStore.setSex,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Possui endereço fixo?',
                      style: _FormTypography.question,
                    ),
                    const SizedBox(height: 8),
                    _BinaryChoice(
                      value: formStore.hasFixedAddress,
                      onChanged: formStore.setHasFixedAddress,
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      label: 'Endereço:',
                      initialValue: formStore.address,
                      onChanged: formStore.setAddress,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _FormField(
                            label: 'Cidade:',
                            initialValue: formStore.city,
                            onChanged: formStore.setCity,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SelectionField(
                            label: 'Estado:',
                            value: formStore.state,
                            options: const [
                              'Paraná',
                              'Santa Catarina',
                              'Rio Grande do Sul',
                              'São Paulo',
                              'Outro',
                            ],
                            onChanged: formStore.setState,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _FormField(
                            label: 'CEP:',
                            initialValue: formStore.zipCode,
                            keyboardType: TextInputType.number,
                            onChanged: formStore.setZipCode,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FormField(
                            label: 'Numero:',
                            initialValue: formStore.number,
                            keyboardType: TextInputType.number,
                            onChanged: formStore.setNumber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _SectionTitle('Necessidades identificadas'),
                    const SizedBox(height: 12),
                    const _Question(
                      title: 'Como você descreveria essa pessoa?',
                      helper:
                          'Descreva brevemente como essa pessoa está e em que '
                          'situação ela se encontra.',
                    ),
                    const SizedBox(height: 8),
                    _MultilineField(
                      initialValue: formStore.description,
                      onChanged: formStore.setDescription,
                    ),
                    const SizedBox(height: 12),
                    const _Question(
                      title: 'O que essa pessoa parece precisar?',
                      helper: 'Selecione todas as opções que se aplicam.',
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 7,
                      children: [
                        for (final need in _needs)
                          _NeedButton(
                            label: need,
                            selected: formStore.isNeedSelected(need),
                            onPressed: () => formStore.toggleNeed(need),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _needs = [
    'Alimentação',
    'Moradia',
    'Saúde',
    'Apoio emocional',
    'Reabilitação',
  ];

  Future<void> _submit(
    BuildContext context,
    VulnerablePersonFormStore formStore,
    String? token,
  ) async {
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

    final wasEditing = formStore.isEditing;
    final success = await formStore.submit(token);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? wasEditing
                      ? 'Cadastro atualizado com sucesso!'
                      : 'Pessoa cadastrada com sucesso!'
                : formStore.errorMessage ??
                      'Não foi possível concluir o cadastro.',
          ),
        ),
      );

    if (success) {
      Modular.to.navigate(
        wasEditing ? AppRoutes.assistedPeople : AppRoutes.registrationMenu,
      );
    }
  }
}

abstract final class _FormTypography {
  static final sectionTitle = GoogleFonts.manrope(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static final question = GoogleFonts.manrope(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static final helper = GoogleFonts.manrope(
    color: const Color(0xFFBABABA),
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static final label = GoogleFonts.manrope(
    color: const Color(0xFF232323),
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static final button = GoogleFonts.manrope(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: _FormTypography.sectionTitle);
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.title, required this.helper});

  final String title;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _FormTypography.question),
        const SizedBox(height: 3),
        Text(helper, style: _FormTypography.helper),
      ],
    );
  }
}

class _BinaryChoice extends StatelessWidget {
  const _BinaryChoice({required this.value, required this.onChanged});

  final bool? value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ChoiceButton(
          label: 'Sim',
          selected: value == true,
          onPressed: () => onChanged(true),
        ),
        const SizedBox(width: 8),
        _ChoiceButton(
          label: 'Não',
          selected: value == false,
          onPressed: () => onChanged(false),
        ),
      ],
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 58,
      height: 32,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: selected ? const Color(0xFF037D68) : primary,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(label, style: _FormTypography.button),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.onChanged,
    this.initialValue = '',
    this.keyboardType,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final String initialValue;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _FormTypography.label),
        const SizedBox(height: 4),
        Container(
          key: ValueKey('form-field-$label'),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: TextFormField(
              initialValue: initialValue,
              onChanged: onChanged,
              keyboardType: keyboardType,
              style: GoogleFonts.manrope(fontSize: 14),
              decoration: const InputDecoration.collapsed(hintText: ''),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectionField extends StatelessWidget {
  const _SelectionField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _FormTypography.label),
        const SizedBox(height: 4),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.primary,
              ),
              style: GoogleFonts.manrope(
                color: const Color(0xFF454545),
                fontSize: 14,
              ),
              items: [
                for (final option in options)
                  DropdownMenuItem(value: option, child: Text(option)),
              ],
              onChanged: (selected) {
                if (selected != null) {
                  onChanged(selected);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MultilineField extends StatelessWidget {
  const _MultilineField({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: GoogleFonts.manrope(fontSize: 14),
        decoration: _inputDecoration(
          context,
        ).copyWith(contentPadding: const EdgeInsets.all(10)),
      ),
    );
  }
}

class _NeedButton extends StatelessWidget {
  const _NeedButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 32),
        backgroundColor: selected
            ? const Color(0xFF037D68)
            : Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: _FormTypography.button),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.onPressed,
    required this.isLoading,
    required this.isEditing,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F3F3),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(44, 18, 44, 20),
          child: SizedBox(
            height: 39,
            child: FilledButton(
              key: const Key('vulnerable_person_submit_button'),
              onPressed: onPressed,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isEditing ? 'Salvar alterações' : 'Concluir',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(BuildContext context) {
  return InputDecoration(
    isDense: true,
    filled: false,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 1.5,
      ),
    ),
  );
}
