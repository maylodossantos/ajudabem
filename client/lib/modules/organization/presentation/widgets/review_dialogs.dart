import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_labeled_field.dart';
import '../../domain/entities/organization.dart';

Future<bool> showApproveOrganizationDialog(BuildContext context) async {
  final approved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AppDialog(
      icon: const AppDialogIcon(icon: Icons.check),
      title: 'Aprovar ONG?',
      message:
          'Ao aprovar esta solicitação, a organização poderá utilizar todos '
          'os recursos disponíveis para ONGs na plataforma.',
      content: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Benefit('Cadastros de pessoas em vulnerabilidade'),
          _Benefit('Gerenciar atendimentos da organização'),
          _Benefit('Criar e gerenciar campanhas'),
        ],
      ),
      actions: [
        AppOutlinedButton(
          label: 'Cancelar',
          onPressed: () => Navigator.of(dialogContext).pop(false),
        ),
        AppPrimaryButton(
          key: const Key('ong_confirm_approve_button'),
          label: 'Aprovar',
          onPressed: () => Navigator.of(dialogContext).pop(true),
        ),
      ],
    ),
  );
  return approved ?? false;
}

Future<void> showOrganizationApprovedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AppDialog(
      icon: const AppDialogIcon(
        icon: Icons.check,
        color: Colors.white,
        background: AppColors.success,
        size: 96,
      ),
      title: 'Solicitação aprovada!',
      message:
          'A organização foi validada com sucesso e já pode acessar os '
          'recursos exclusivos para ONGs na plataforma.',
      actions: [
        AppPrimaryButton(
          label: 'Fechar',
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
      ],
    ),
  );
}

Future<(RejectionReason, String?)?> showRejectOrganizationDialog(
  BuildContext context,
) {
  return showDialog<(RejectionReason, String?)>(
    context: context,
    builder: (_) => const _RejectDialog(),
  );
}

class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  RejectionReason? _reason;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reason = _reason;

    return AppDialog(
      icon: const AppDialogIcon(icon: Icons.close, color: AppColors.danger),
      title: 'Reprovar organização',
      message:
          'Informe o motivo da reprovação para que a organização possa '
          'corrigir as pendências e enviar uma nova solicitação.',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppLabeledDropdown<RejectionReason>(
            key: const Key('ong_reject_reason_field'),
            label: 'Motivo:',
            hintText: 'Selecione o motivo',
            value: reason,
            options: RejectionReason.values,
            labelOf: (option) => option.label,
            onChanged: (value) => setState(() => _reason = value),
          ),
          const SizedBox(height: 14),
          Text('Observação (opcional)', style: AppFieldStyles.label),
          const SizedBox(height: 4),
          TextField(
            key: const Key('ong_reject_note_field'),
            controller: _noteController,
            maxLines: 5,
            maxLength: 1000,
            style: GoogleFonts.manrope(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Descreva os detalhes da reprovação',
              hintStyle: AppFieldStyles.hint,
              counterText: '',
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        AppOutlinedButton(
          label: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppPrimaryButton(
          key: const Key('ong_confirm_reject_button'),
          label: 'Reprovar',
          color: AppColors.danger,
          onPressed: reason == null
              ? null
              : () => Navigator.of(context).pop((reason, _noteController.text)),
        ),
      ],
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                color: const Color(0xFF232323),
                fontSize: 14,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
