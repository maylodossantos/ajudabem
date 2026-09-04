import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../stores/login_store.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const _primaryText = Color(0xFF232323);
  static const _facebookBlue = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context) {
    final store = Modular.get<LoginStore>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(),
      bottomNavigationBar: _LoginBottomNavigation(
        onRegister: () => _openRegistrationMenu(context, store),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 96, 24, 32),
                    child: Column(
                      children: [
                        Text(
                          'Seja bem-vindo ao AjudaBem!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Entre para ter acesso completo ao seu perfil,\n'
                          'acompanhar atendimentos, ajudar pessoas e participar\n'
                          'da comunidade.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            color: _primaryText,
                            fontSize: 14,
                            height: 1.25,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          key: const Key('login_email_field'),
                          label: 'E-mail:',
                          hintText: 'E-mail',
                          prefixIconAsset: 'assets/icons/register/email.svg',
                          keyboardType: TextInputType.emailAddress,
                          onChanged: store.setEmail,
                        ),
                        const SizedBox(height: 8),
                        Observer(
                          builder: (_) => AppTextField(
                            key: const Key('login_password_field'),
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
                        const SizedBox(height: 14),
                        Observer(
                          builder: (_) => AppPrimaryButton(
                            key: const Key('login_submit_button'),
                            label: store.isLoading ? 'Entrando...' : 'Entrar',
                            onPressed: store.canSubmit
                                ? () => _submit(context, store)
                                : null,
                            icon: store.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _OrDivider(),
                        const SizedBox(height: 12),
                        AppOutlinedButton(
                          label: 'Faça login com o Google',
                          onPressed: () {},
                          icon: SvgPicture.asset(
                            'assets/icons/google_icon.svg',
                            width: 14,
                            height: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AppOutlinedButton(
                          label: 'Faça login com o Facebook',
                          onPressed: () {},
                          icon: const Icon(
                            Icons.facebook,
                            size: 17,
                            color: _facebookBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 0,
                          runSpacing: 4,
                          children: [
                            AppTextButton(
                              label: 'Criar conta',
                              icon: Icons.person_add_alt_outlined,
                              onPressed: () =>
                                  Modular.to.pushNamed(AppRoutes.register),
                            ),
                            AppTextButton(
                              label: 'Esqueci minha senha',
                              icon: Icons.lock_outline,
                              onPressed: () =>
                                  Modular.to.pushNamed(AppRoutes.recoverAccess),
                            ),
                          ],
                        ),
                      ],
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

  Future<void> _submit(BuildContext context, LoginStore store) async {
    final success = await store.submit();

    if (!context.mounted) {
      return;
    }

    if (success) {
      Modular.to.navigate(AppRoutes.profile);
      return;
    }

    final message = store.errorMessage ?? 'Não foi possível entrar.';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openRegistrationMenu(BuildContext context, LoginStore store) {
    if (store.isAuthenticated) {
      Modular.to.navigate(AppRoutes.registrationMenu);
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Faça login para acessar o menu de cadastro.'),
        ),
      );
  }
}

class _LoginBottomNavigation extends StatelessWidget {
  const _LoginBottomNavigation({required this.onRegister});

  static const _unselectedColor = Color(0xFF494949);

  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('login_bottom_navigation'),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F3F3),
        border: Border(top: BorderSide(color: Color(0xFFE2E2E2))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _LoginNavigationItem(
                iconAsset: 'assets/icons/navigation/news.svg',
                label: 'Notícias',
              ),
              const SizedBox(width: 48),
              const _LoginNavigationItem(
                iconAsset: 'assets/icons/navigation/heart.svg',
                label: 'Ajuda',
              ),
              const SizedBox(width: 48),
              const _LoginNavigationItem(
                iconAsset: 'assets/icons/navigation/profile.svg',
                label: 'Perfil',
                selected: true,
              ),
              const SizedBox(width: 48),
              _LoginNavigationItem(
                iconAsset: 'assets/icons/navigation/add.svg',
                label: 'Cadastro',
                onTap: onRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginNavigationItem extends StatelessWidget {
  const _LoginNavigationItem({
    required this.iconAsset,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String iconAsset;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : _LoginBottomNavigation._unselectedColor;

    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: Center(
                child: SvgPicture.asset(
                  iconAsset,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.manrope(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.35);

    return Row(
      children: [
        Expanded(child: Divider(color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Ou',
            style: GoogleFonts.manrope(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        Expanded(child: Divider(color: color)),
      ],
    );
  }
}
