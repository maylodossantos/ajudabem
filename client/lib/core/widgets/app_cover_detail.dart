import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppCoverDetail extends StatefulWidget {
  const AppCoverDetail({
    required this.imageUrl,
    required this.caption,
    required this.title,
    required this.subtitle,
    required this.body,
    super.key,
    this.placeholderIcon = Icons.image_outlined,
  });

  final String? imageUrl;
  final String caption;
  final String title;
  final String subtitle;
  final String body;
  final IconData placeholderIcon;

  static const coverHeight = 300.0;
  static const cardTop = 220.0;

  @override
  State<AppCoverDetail> createState() => _AppCoverDetailState();
}

class _AppCoverDetailState extends State<AppCoverDetail> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.imageUrl;
    final placeholder = Center(
      child: Icon(widget.placeholderIcon, size: 64, color: Colors.white),
    );

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          AnimatedBuilder(
            animation: _scroll,
            builder: (_, child) {
              final offset = _scroll.hasClients ? _scroll.offset : 0.0;
              return Positioned(
                top: -offset * 0.35,
                left: 0,
                right: 0,
                height: AppCoverDetail.coverHeight,
                child: child!,
              );
            },
            child: ColoredBox(
              color: const Color(0xFFA2A2A2),
              child: url == null || url.isEmpty
                  ? placeholder
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => placeholder,
                    ),
            ),
          ),
          SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(
              20,
              AppCoverDetail.cardTop,
              20,
              0,
            ),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - AppCoverDetail.cardTop,
              ),
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.caption.isNotEmpty) ...[
                    Text(
                      widget.caption,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFA2A2A2),
                        fontSize: 14,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    widget.title,
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF232323),
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      letterSpacing: 0,
                    ),
                  ),
                  if (widget.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFA2A2A2),
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        height: 1.45,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SelectableText(
                    widget.body,
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF232323),
                      fontSize: 15,
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
