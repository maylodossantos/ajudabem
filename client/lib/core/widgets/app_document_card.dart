import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

sealed class DocumentBlock {
  const DocumentBlock();
}

class DocumentParagraph extends DocumentBlock {
  const DocumentParagraph(this.text);

  final String text;
}

class DocumentBullets extends DocumentBlock {
  const DocumentBullets(this.items);

  final List<String> items;
}

class DocumentSection {
  const DocumentSection({
    required this.title,
    this.blocks = const [],
    this.isMajor = false,
  });

  final String title;
  final List<DocumentBlock> blocks;
  final bool isMajor;
}

class AppDocumentCard extends StatelessWidget {
  const AppDocumentCard({required this.sections, super.key});

  final List<DocumentSection> sections;

  static final _bodyStyle = GoogleFonts.manrope(
    color: const Color(0xFF232323),
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _buildSection(sections[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(DocumentSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: GoogleFonts.manrope(
            color: Colors.black,
            fontSize: section.isMajor ? 18 : 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        if (section.blocks.isNotEmpty) const SizedBox(height: 8),
        for (final block in section.blocks) _buildBlock(block),
      ],
    );
  }

  Widget _buildBlock(DocumentBlock block) {
    return switch (block) {
      DocumentParagraph(:final text) => Text(text, style: _bodyStyle),
      DocumentBullets(:final items) => Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in items)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: _bodyStyle),
                  Expanded(child: Text(item, style: _bodyStyle)),
                ],
              ),
          ],
        ),
      ),
    };
  }
}
