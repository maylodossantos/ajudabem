import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class DevAccount {
  const DevAccount({
    required this.label,
    required this.icon,
    required this.email,
    required this.password,
  });

  final String label;
  final IconData icon;
  final String email;
  final String password;
}

const devAccounts = [
  DevAccount(
    label: 'Admin',
    icon: Icons.admin_panel_settings_outlined,
    email: 'admin@ajudabem.local',
    password: 'Admin@123456',
  ),
  DevAccount(
    label: 'ONG',
    icon: Icons.volunteer_activism_outlined,
    email: 'ong@ajudabem.local',
    password: 'Ong@123456',
  ),
  DevAccount(
    label: 'ONG 2',
    icon: Icons.diversity_3_outlined,
    email: 'ong2@ajudabem.local',
    password: 'Ong2@123456',
  ),
  DevAccount(
    label: 'Usuário',
    icon: Icons.person_outline,
    email: 'usuario@ajudabem.local',
    password: 'Usuario@123456',
  ),
];

const showDevQuickLogin = kDebugMode || bool.fromEnvironment('DEV_SHORTCUTS');

class DevQuickLogin extends StatelessWidget {
  const DevQuickLogin({
    super.key,
    required this.onSelected,
    this.enabled = true,
  });

  final ValueChanged<DevAccount> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Atalhos de desenvolvimento',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: color,
            fontSize: AppTextSize.caption,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        for (var start = 0; start < devAccounts.length; start += 2) ...[
          if (start > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (final account in devAccounts.skip(start).take(2)) ...[
                if (account != devAccounts[start]) const SizedBox(width: 8),
                Expanded(
                  child: AppOutlinedButton(
                    key: Key('dev_login_${account.email}'),
                    label: account.label,
                    dense: true,
                    icon: Icon(account.icon, size: 16, color: color),
                    onPressed: enabled ? () => onSelected(account) : null,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
