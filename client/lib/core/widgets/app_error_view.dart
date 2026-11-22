import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class AppMessageView extends StatelessWidget {
  const AppMessageView({
    required this.icon,
    required this.message,
    super.key,
    this.tone = AppColors.textSecondary,
    this.action,
  });

  final IconData icon;
  final String message;
  final Color tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: tone),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.textBody,
                  fontSize: AppTextSize.body,
                  height: 1.4,
                  letterSpacing: 0,
                ),
              ),
              if (action case final action?) ...[
                const SizedBox(height: AppSpacing.lg),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    required this.message,
    super.key,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppMessageView(icon: icon, message: message);
  }
}

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.message,
    required this.onRetry,
    super.key,
    this.retryLabel = 'Tentar novamente',
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return AppMessageView(
      icon: Icons.cloud_off_outlined,
      tone: AppColors.danger,
      message: message,
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(onPressed: onRetry, child: Text(retryLabel)),
          if (secondaryActionLabel != null)
            TextButton(
              onPressed: onSecondaryAction,
              child: Text(secondaryActionLabel!),
            ),
        ],
      ),
    );
  }
}
