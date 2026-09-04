import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    required this.hintText,
    super.key,
    this.prefixIcon,
    this.prefixIconAsset,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
  });

  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final String? prefixIconAsset;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final hasPrefixIcon = prefixIcon != null || prefixIconAsset != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 36,
          child: TextField(
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
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
