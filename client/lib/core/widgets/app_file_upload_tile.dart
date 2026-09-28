import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class AppFileUploadTile extends StatelessWidget {
  const AppFileUploadTile({
    required this.label,
    required this.isDone,
    required this.isLoading,
    required this.onTap,
    super.key,
    this.emptyText = 'Selecionar documento',
    this.doneText = 'Documento enviado para análise',
  });

  final String label;
  final bool isDone;
  final bool isLoading;
  final VoidCallback onTap;
  final String emptyText;
  final String doneText;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final textStyle = GoogleFonts.manrope(
      color: isDone ? Colors.white : const Color(0xFF232323),
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    );

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isDone ? doneText : emptyText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isDone ? Colors.white : primary,
              ),
            )
          else
            Icon(
              isDone ? Icons.check_circle_outline : Icons.upload_outlined,
              color: isDone ? Colors.white : const Color(0xFF232323),
              size: 24,
            ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: const Color(0xFF232323),
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: isDone ? AppColors.success : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 52,
              child: isDone
                  ? content
                  : CustomPaint(
                      painter: _DashedBorderPainter(color: primary),
                      child: content,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  static const _dash = 4.0;
  static const _gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
