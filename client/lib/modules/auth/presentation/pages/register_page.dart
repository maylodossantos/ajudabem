import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/formatters/cpf_input_formatter.dart';
import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/formatters/phone_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../stores/register_store.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Modular.get<RegisterStore>();

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
                    padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
                    child: Column(
                      children: [
                        Text(
                          'Crie sua conta no AjudaBem.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          key: const Key('register_name_field'),
                          label: 'Nome:',
                          hintText: 'Nome',
                          prefixIconAsset: 'assets/icons/register/user.svg',
                          keyboardType: TextInputType.name,
                          onChanged: store.setName,
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          key: const Key('register_email_field'),
                          label: 'E-mail:',
                          hintText: 'E-mail',
                          prefixIconAsset: 'assets/icons/register/email.svg',
                          keyboardType: TextInputType.emailAddress,
                          onChanged: store.setEmail,
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          key: const Key('register_phone_field'),
                          label: 'Telefone:',
                          hintText: 'Telefone',
                          prefixIconAsset: 'assets/icons/register/phone.svg',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [PhoneInputFormatter()],
                          onChanged: store.setPhone,
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          key: const Key('register_cpf_field'),
                          label: 'CPF:',
                          hintText: '000.000.000-00',
                          prefixIcon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [CpfInputFormatter()],
                          onChanged: store.setCpf,
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          key: const Key('register_birth_date_field'),
                          label: 'Data de nascimento:',
                          hintText: 'dd/mm/aaaa',
                          prefixIcon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [DateInputFormatter()],
                          onChanged: store.setBirthDate,
                        ),
                        const SizedBox(height: 8),
                        Observer(
                          builder: (_) => AppTextField(
                            key: const Key('register_password_field'),
                            label: 'Senha:',
                            hintText: 'Senha',
                            prefixIconAsset:
                                'assets/icons/register/password.svg',
                            obscureText: store.isPasswordObscured,
                            onChanged: store.setPassword,
                            suffixIcon: IconButton(
                              onPressed: store.togglePasswordVisibility,
                              icon: Icon(
                                store.isPasswordObscured
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Observer(
                          builder: (_) => AppTextField(
                            key: const Key('register_confirm_password_field'),
                            label: 'Confirme sua senha:',
                            hintText: 'Senha',
                            prefixIconAsset:
                                'assets/icons/register/password.svg',
                            obscureText: store.isConfirmPasswordObscured,
                            onChanged: store.setConfirmPassword,
                            suffixIcon: IconButton(
                              onPressed: store.toggleConfirmPasswordVisibility,
                              icon: Icon(
                                store.isConfirmPasswordObscured
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Observer(
                          builder: (_) => _TermsCheckbox(
                            value: store.acceptedTerms,
                            onChanged: store.setAcceptedTerms,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Observer(
                  builder: (_) => Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 54),
                    child: AppPrimaryButton(
                      key: const Key('register_submit_button'),
                      label: 'Cadastrar',
                      onPressed: store.canSubmit
                          ? () => _submit(context, store)
                          : null,
                      isLoading: store.isLoading,
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

  Future<void> _submit(BuildContext context, RegisterStore store) async {
    final success = await store.submit();

    if (!context.mounted) {
      return;
    }

    final message = success
        ? 'Cadastro realizado com sucesso!'
        : store.errorMessage ?? 'Não foi possível realizar o cadastro.';

    showAppSnackBar(context, message);

    if (success) {
      store.clear();
      Modular.to.navigate(AppRoutes.auth);
    }
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return InkWell(
      key: const Key('register_accept_terms'),
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(
              value ? Icons.check_circle : Icons.circle,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.manrope(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: 0,
                ),
                children: [
                  const TextSpan(text: 'Declaro que li e concordo com os '),
                  TextSpan(
                    text: 'Termos de Uso',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          Modular.to.pushNamed(AppRoutes.termsOfUse),
                  ),
                  const TextSpan(text: ' e a '),
                  TextSpan(
                    text: 'Política de Privacidade.',
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
