import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../stores/recover_access_store.dart';

class RecoverAccessPage extends StatelessWidget {
  const RecoverAccessPage({super.key});

  static const _primaryText = Color(0xFF232323);

  @override
  Widget build(BuildContext context) {
    final store = Modular.get<RecoverAccessStore>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AuthAppBar(showBackButton: true, onBack: Modular.to.pop),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(27, 72, 27, 24),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/icons/recover_access.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 48),
                      Text(
                        'Esqueceu sua senha?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Sem problemas! Vamos te ajudar a recuperar o acesso à sua conta.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                color: _primaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'E-mail:',
                        hintText: 'Digite seu e-mail',
                        prefixIconAsset: 'assets/icons/register/email.svg',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: store.setEmail,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 56),
                child: AppPrimaryButton(
                  label: 'Enviar código',
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
