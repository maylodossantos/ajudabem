import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.hintText,
    super.key,
    this.label,
    this.prefixIcon,
    this.prefixIconAsset,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.controller,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
  });

  final String? label;
  final String hintText;
  final IconData? prefixIcon;
  final String? prefixIconAsset;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool enabled;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final hasPrefixIcon = prefixIcon != null || prefixIconAsset != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.manrope(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
        ],
        SizedBox(
          height: maxLines == 1 ? 36 : 20.0 * maxLines,
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            style: GoogleFonts.manrope(
              color: const Color(0xFFA2A2A2),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: _buildPrefixIcon(),
              suffixIcon: suffixIcon,
              contentPadding: EdgeInsets.symmetric(
                horizontal: hasPrefixIcon ? 0 : 16,
                vertical: maxLines == 1 ? 0 : 8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildPrefixIcon() {
    if (prefixIconAsset != null) {
      return Center(
        widthFactor: 1,
        heightFactor: 1,
        child: SvgPicture.asset(prefixIconAsset!, width: 18, height: 18),
      );
    }

    if (prefixIcon != null) {
      return Icon(prefixIcon, size: 18);
    }

    return null;
  }
}
