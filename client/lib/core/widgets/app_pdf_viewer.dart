import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfx/pdfx.dart';

class AppPdfViewerController {
  _AppPdfViewerState? _state;

  void zoomBy(double factor) => _state?._zoomBy(factor);
}

class AppPdfViewer extends StatefulWidget {
  const AppPdfViewer({
    required this.bytes,
    super.key,
    this.controller,
    this.minScale = 1,
    this.maxScale = 5,
    this.renderScale = 3,
  });

  final Uint8List bytes;
  final AppPdfViewerController? controller;
  final double minScale;
  final double maxScale;
  final double renderScale;

  @override
  State<AppPdfViewer> createState() => _AppPdfViewerState();
}

class _RenderedPage {
  const _RenderedPage(this.bytes, this.aspectRatio);

  final Uint8List bytes;
  final double aspectRatio;
}

class _AppPdfViewerState extends State<AppPdfViewer>
    with SingleTickerProviderStateMixin {
  static const _padding = 12.0;
  static const _gap = 12.0;

  final _transform = TransformationController();
  late final _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  Animation<Matrix4>? _zoomTween;

  List<_RenderedPage>? _pages;
  String? _error;
  Size _viewport = Size.zero;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _transform.addListener(_updateCurrentPage);
    _animation.addListener(() {
      final tween = _zoomTween;
      if (tween != null) _transform.value = tween.value;
    });
    _render();
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller?._state = null;
    _animation.dispose();
    _transform.dispose();
    super.dispose();
  }

  Future<void> _render() async {
    try {
      final document = await PdfDocument.openData(widget.bytes);
      final pages = <_RenderedPage>[];
      for (var number = 1; number <= document.pagesCount; number++) {
        final page = await document.getPage(number);
        final image = await page.render(
          width: page.width * widget.renderScale,
          height: page.height * widget.renderScale,
          format: PdfPageImageFormat.png,
          backgroundColor: '#FFFFFF',
        );
        final aspectRatio = page.width / page.height;
        await page.close();
        if (image != null) pages.add(_RenderedPage(image.bytes, aspectRatio));
      }
      await document.close();
      if (mounted) setState(() => _pages = pages);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Não foi possível exibir o documento.');
      }
    }
  }

  void _zoomBy(double factor) {
    if (_viewport.isEmpty) return;

    final current = _transform.value;
    final scale = current.getMaxScaleOnAxis();
    final next = (scale * factor).clamp(widget.minScale, widget.maxScale);
    if ((next - scale).abs() < 0.001) return;

    final center = _viewport.center(Offset.zero);
    final ratio = next / scale;
    final destination = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(ratio, ratio, 1, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1)
      ..multiply(current);

    final translation = destination.getTranslation();
    final contentWidth = _viewport.width * next;
    final minX = _viewport.width - contentWidth;
    destination.setTranslationRaw(
      translation.x.clamp(minX, 0),
      translation.y > 0 ? 0 : translation.y,
      0,
    );

    _zoomTween = Matrix4Tween(
      begin: current,
      end: destination,
    ).animate(CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic));
    _animation.forward(from: 0);
  }

  void _updateCurrentPage() {
    final pages = _pages;
    if (pages == null || pages.isEmpty || _viewport.isEmpty) return;

    final matrix = _transform.value;
    final scale = matrix.getMaxScaleOnAxis();
    final middle = (-matrix.getTranslation().y + _viewport.height / 2) / scale;
    final pageWidth = _viewport.width - _padding * 2;

    var top = _padding;
    var page = pages.length;
    for (var i = 0; i < pages.length; i++) {
      final height = pageWidth / pages[i].aspectRatio;
      if (middle < top + height + _gap / 2) {
        page = i + 1;
        break;
      }
      top += height + _gap;
    }
    if (page != _currentPage) setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return Center(
        child: Text(error, style: GoogleFonts.manrope(fontSize: 14)),
      );
    }

    final pages = _pages;
    if (pages == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (_, constraints) {
        _viewport = constraints.biggest;

        return Stack(
          children: [
            InteractiveViewer(
              transformationController: _transform,
              minScale: widget.minScale,
              maxScale: widget.maxScale,
              constrained: false,
              child: SizedBox(
                width: constraints.maxWidth,
                child: Padding(
                  padding: const EdgeInsets.all(_padding),
                  child: Column(
                    children: [
                      for (var i = 0; i < pages.length; i++) ...[
                        if (i > 0) const SizedBox(height: _gap),
                        DecoratedBox(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: AspectRatio(
                            aspectRatio: pages[i].aspectRatio,
                            child: Image.memory(
                              pages[i].bytes,
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.medium,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_currentPage/${pages.length}',
                    style: GoogleFonts.manrope(fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
