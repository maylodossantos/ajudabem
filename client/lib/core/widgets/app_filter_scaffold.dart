import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ajuda_bem_logo.dart';
import 'app_page_scaffold.dart';

class AppFilterScaffold extends StatelessWidget {
  const AppFilterScaffold({
    required this.sections,
    required this.onReset,
    required this.onSave,
    super.key,
  });

  final List<Widget> sections;
  final VoidCallback onReset;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const AjudaBemLogo(),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary),
          tooltip: 'Fechar',
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
          child: AppBottomActions(
            secondaryLabel: 'Resetar',
            onSecondary: onReset,
            primaryLabel: 'Salvar',
            primaryKey: const Key('filter_save_button'),
            onPrimary: onSave,
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: sections,
            ),
          ),
        ),
      ),
    );
  }
}

class AppFilterSection extends StatelessWidget {
  const AppFilterSection({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.manrope(
              color: const Color(0xFF232323),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class AppDistanceSlider extends StatelessWidget {
  const AppDistanceSlider({
    required this.maxDistanceKm,
    required this.onChanged,
    super.key,
    this.limitKm = 50,
  });

  final double? maxDistanceKm;
  final ValueChanged<double?> onChanged;
  final double limitKm;

  @override
  Widget build(BuildContext context) {
    final distance = maxDistanceKm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          distance == null ? 'Sem limite' : 'Até ${distance.round()} km',
          style: GoogleFonts.manrope(fontSize: 15, letterSpacing: 0),
        ),
        Slider(
          min: 1,
          max: limitKm,
          divisions: limitKm.round() - 1,
          value: distance ?? limitKm,
          label: distance == null ? 'Sem limite' : '${distance.round()} km',
          onChanged: (value) => onChanged(value >= limitKm ? null : value),
        ),
      ],
    );
  }
}
