import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
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
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
              style: GoogleFonts.manrope(fontSize: AppTextSize.body),
              decoration: InputDecoration.collapsed(
                hintText: hintText,
                hintStyle: GoogleFonts.manrope(
                  color: AppColors.textMuted,
                  fontSize: AppTextSize.body,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search, color: AppColors.textStrong),
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
