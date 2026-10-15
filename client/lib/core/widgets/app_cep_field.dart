import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/brazilian_states.dart';
import '../formatters/cep_input_formatter.dart';
import '../services/cep_service.dart';
import '../theme/app_colors.dart';
import 'app_labeled_field.dart';

class AppCepField extends StatefulWidget {
  const AppCepField({
    required this.initialValue,
    required this.onChanged,
    super.key,
    this.onStreet,
    this.onNeighborhood,
    this.onCity,
    this.onState,
    this.label = 'CEP:',
    this.required = false,
    this.service,
  });

  final String label;
  final bool required;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onStreet;
  final ValueChanged<String>? onNeighborhood;
  final ValueChanged<String>? onCity;
  final ValueChanged<String>? onState;
  final CepService? service;

  @override
  State<AppCepField> createState() => _AppCepFieldState();
}

class _AppCepFieldState extends State<AppCepField> {
  bool _searching = false;
  String? _error;
  String? _lastLookup;

  CepService? get _service => widget.service ?? Modular.tryGet<CepService>();

  void _fill(CepAddress address) {
    void apply(ValueChanged<String>? setter, String value) {
      if (setter != null && value.isNotEmpty) setter(value);
    }

    apply(widget.onStreet, address.street);
    apply(widget.onNeighborhood, address.neighborhood);
    apply(widget.onCity, address.city);
    if (BrazilianStates.codes.contains(address.state)) {
      widget.onState?.call(address.state);
    }
  }

  Future<void> _changed(String value) async {
    widget.onChanged(value);
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) {
      if (_error != null) setState(() => _error = null);
      return;
    }
    final service = _service;
    if (service == null || digits == _lastLookup) return;

    _lastLookup = digits;
    setState(() {
      _searching = true;
      _error = null;
    });
    final address = await service.lookup(digits);
    if (!mounted) return;
    setState(() {
      _searching = false;
      _error = address == null
          ? 'CEP não encontrado. Preencha o endereço.'
          : null;
    });
    if (address != null) _fill(address);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final error = _error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppLabeledField(
          label: widget.label,
          required: widget.required,
          hintText: '00000-000',
          initialValue: widget.initialValue,
          keyboardType: TextInputType.number,
          inputFormatters: [CepInputFormatter()],
          onChanged: _changed,
        ),
        if (_searching)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: primary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Buscando endereço...',
                  style: GoogleFonts.manrope(color: primary, fontSize: 11),
                ),
              ],
            ),
          )
        else if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              error,
              style: GoogleFonts.manrope(color: AppColors.danger, fontSize: 11),
            ),
          ),
      ],
    );
  }
}
