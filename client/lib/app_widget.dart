import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'core/theme/app_theme.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ajuda Bem',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: Modular.routerConfig,
    );
  }
}
