import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_square_icon_button.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    required this.controller,
    required this.hintText,
    required this.onSearch,
    super.key,
    this.onFilter,
    this.isFiltering = false,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSearch;
  final VoidCallback? onFilter;
  final bool isFiltering;

  @override
  Widget build(BuildContext context) {
    final field = Container(
      height: 48,
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
              style: GoogleFonts.manrope(fontSize: 14),
              decoration: InputDecoration.collapsed(
                hintText: hintText,
                hintStyle: GoogleFonts.manrope(
                  color: const Color(0xFFBABABA),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search, color: Color(0xFF232323)),
            tooltip: 'Pesquisar',
          ),
        ],
      ),
    );

    final filter = onFilter;
    if (filter == null) return field;

    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Expanded(child: field),
        const SizedBox(width: 10),
        AppSquareIconButton(
          icon: Icons.tune,
          tooltip: 'Filtros',
          color: isFiltering ? Colors.white : primary,
          background: isFiltering ? primary : Colors.white,
          onPressed: filter,
        ),
      ],
    );
  }
}
