import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_icon_badge.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../stores/recover_access_store.dart';

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  static const _codeLength = 4;

  late final RecoverAccessStore _store;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _store = Modular.get<RecoverAccessStore>();
    _controllers = List.generate(_codeLength, (_) => TextEditingController());
    _focusNodes = List.generate(_codeLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    _store.setCode(_controllers.map((c) => c.text).join());
  }

  void _onBackspace(int index) {
    if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = _store;

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
                      const AppIconBadge(icon: Icons.mail_outline_rounded),
                      const SizedBox(height: 24),
                      Text(
                        'O código foi enviado para o seu e-mail:',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Observer(
                        builder: (_) => Text(
                          store.email,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 336),
                        child: Row(
                          children: [
                            for (
                              var index = 0;
                              index < _codeLength;
                              index++
                            ) ...[
                              if (index > 0) const SizedBox(width: 10),
                              Expanded(
                                child: _CodeDigitField(
                                  key: Key('verify_code_digit_field_$index'),
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  onChanged: (value) =>
                                      _onDigitChanged(index, value),
                                  onBackspace: () => _onBackspace(index),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Observer(
                        builder: (_) => store.canResendCode
                            ? GestureDetector(
                                key: const Key('resend_code_button'),
                                onTap: () => _resend(context, store),
                                child: Text(
                                  'Reenviar código',
                                  style: GoogleFonts.manrope(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                  ),
                                ),
                              )
                            : Text.rich(
                                TextSpan(
                                  style: GoogleFonts.manrope(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Reenviar código em '),
                                    TextSpan(
                                      text: '${store.resendSecondsRemaining}',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                    const TextSpan(text: ' s'),
                                  ],
                                ),
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
                    key: const Key('verify_code_submit_button'),
                    label: 'Verificar código',
                    onPressed: store.canSubmitCode
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
    final success = await store.confirmCode();

    if (!context.mounted) {
      return;
    }

    if (success) {
      Modular.to.navigate(AppRoutes.resetPassword);
      return;
    }

    showAppSnackBar(
      context,
      store.errorMessage ?? 'Não foi possível verificar o código.',
    );
  }

  Future<void> _resend(BuildContext context, RecoverAccessStore store) async {
    final success = await store.resendCode();

    if (!context.mounted) {
      return;
    }

    final message = success
        ? 'Novo código enviado!'
        : store.errorMessage ?? 'Não foi possível enviar o código.';

    showAppSnackBar(context, message);
  }
}

class _CodeDigitField extends StatelessWidget {
  const _CodeDigitField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(10));

    return AspectRatio(
      aspectRatio: 1,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          expands: true,
          maxLines: null,
          maxLength: 1,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          style: GoogleFonts.manrope(
            color: Colors.black,
            fontSize: 34,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: '_',
            hintStyle: GoogleFonts.manrope(
              color: const Color(0xFFBDBDBD),
              fontSize: 28,
              fontWeight: FontWeight.w400,
              height: 1,
            ),
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
