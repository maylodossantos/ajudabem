import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'app_module.dart';
import 'app_widget.dart';
import 'core/widgets/app_map.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppMap.preloadLastLocation().ignore();
  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}
