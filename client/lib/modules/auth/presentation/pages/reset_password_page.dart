import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../stores/recover_access_store.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    final store = Modular.get<RecoverAccessStore>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(showBackButton: true),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(27, 72, 27, 24),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/reset_password.svg',
                        width: 108,
                        height: 108,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Crie uma nova senha:',
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
                        key: const Key('reset_password_field'),
                        hintText: 'Senha',
                        prefixIconAsset: 'assets/icons/register/password.svg',
                        obscureText: _isPasswordObscured,
                        onChanged: store.setPassword,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _isPasswordObscured = !_isPasswordObscured,
                          ),
                          icon: Icon(
                            _isPasswordObscured
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        key: const Key('reset_confirm_password_field'),
                        hintText: 'Confirme sua senha',
                        prefixIconAsset: 'assets/icons/register/password.svg',
                        obscureText: _isConfirmPasswordObscured,
                        onChanged: store.setConfirmPassword,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _isConfirmPasswordObscured =
                                !_isConfirmPasswordObscured,
                          ),
                          icon: Icon(
                            _isConfirmPasswordObscured
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 56),
                child: Observer(
                  builder: (_) => AppPrimaryButton(
                    key: const Key('reset_password_submit_button'),
                    label: 'Resetar senha',
                    onPressed: store.canSubmitNewPassword
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
    );
  }

  Future<void> _submit(BuildContext context, RecoverAccessStore store) async {
    final success = await store.submitNewPassword();

    if (!context.mounted) {
      return;
    }

    final message = success
        ? 'Senha redefinida com sucesso!'
        : store.errorMessage ?? 'Não foi possível redefinir a senha.';

    showAppSnackBar(context, message);

    if (success) {
      store.clear();
      Modular.to.navigate(AppRoutes.auth);
    }
  }
}
