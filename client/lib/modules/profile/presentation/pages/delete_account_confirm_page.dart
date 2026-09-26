import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_icon_badge.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../stores/profile_store.dart';

class DeleteAccountConfirmPage extends StatefulWidget {
  const DeleteAccountConfirmPage({super.key});

  @override
  State<DeleteAccountConfirmPage> createState() =>
      _DeleteAccountConfirmPageState();
}

class _DeleteAccountConfirmPageState extends State<DeleteAccountConfirmPage> {
  late final LoginStore _loginStore;
  late final ProfileStore _profileStore;

  @override
  void initState() {
    super.initState();
    _loginStore = Modular.get<LoginStore>();
    _profileStore = Modular.get<ProfileStore>();
  }

  Future<void> _confirmDelete() async {
    final token = _loginStore.authToken;
    if (token == null) {
      return;
    }

    final deleted = await _profileStore.deleteAccount(token);

    if (!mounted || !deleted) {
      return;
    }

    _profileStore.clear();
    _loginStore.signOut();
    Modular.to.navigate(AppRoutes.auth);
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(27, 48, 27, 24),
              child: Column(
                children: [
                  const AppIconBadge(
                    icon: Icons.delete_outline,
                    iconColor: AppColors.danger,
                    backgroundColor: AppColors.dangerSoft,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Excluir sua conta?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Essa ação é permanente. Todos os seus dados e '
                    'cadastros serão removidos e não será possível '
                    'recuperar sua conta depois.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF454545),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      letterSpacing: 0,
                    ),
                  ),
                  Observer(
                    builder: (_) {
                      final error = _profileStore.errorMessage;
                      if (error == null) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          error,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            color: AppColors.danger,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  Observer(
                    builder: (_) => AppPrimaryButton(
                      key: const Key('delete_account_confirm_button'),
                      label: 'Excluir minha conta',
                      color: AppColors.danger,
                      isLoading: _profileStore.isLoading,
                      onPressed: _confirmDelete,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Observer(
                    builder: (_) => AppOutlinedButton(
                      key: const Key('delete_account_cancel_button'),
                      label: 'Cancelar',
                      onPressed: _profileStore.isLoading
                          ? null
                          : Modular.to.pop,
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
