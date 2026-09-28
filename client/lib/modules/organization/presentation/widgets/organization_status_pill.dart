import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_status_pill.dart';
import '../../domain/entities/organization.dart';

class OrganizationStatusPill extends StatelessWidget {
  const OrganizationStatusPill({required this.status, super.key});

  final OrganizationStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (status) {
      OrganizationStatus.pending => (
        AppColors.warningText,
        AppColors.warningSoft,
      ),
      OrganizationStatus.approved => (
        AppColors.successText,
        AppColors.successSoft,
      ),
      OrganizationStatus.rejected => (AppColors.danger, AppColors.dangerSoft),
    };

    return AppStatusPill(
      label: status.label,
      color: color,
      background: background,
    );
  }
}
