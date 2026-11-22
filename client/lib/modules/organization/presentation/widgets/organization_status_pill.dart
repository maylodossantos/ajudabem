import 'package:flutter/material.dart';

import '../../../../core/widgets/app_badge.dart';
import '../../domain/entities/organization.dart';

class OrganizationStatusPill extends StatelessWidget {
  const OrganizationStatusPill({required this.status, super.key});

  final OrganizationStatus status;

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: status.label,
      dot: true,
      tone: switch (status) {
        OrganizationStatus.pending => AppTone.warning,
        OrganizationStatus.approved => AppTone.success,
        OrganizationStatus.rejected => AppTone.danger,
      },
    );
  }
}
