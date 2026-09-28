import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/file_download_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_square_icon_button.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/organization.dart';
import '../../domain/repositories/organization_repository.dart';

class DocumentViewerArgs {
  const DocumentViewerArgs({
    required this.organizationId,
    required this.document,
  });

  final int organizationId;
  final OrganizationDocument document;
}

class DocumentViewerPage extends StatefulWidget {
  const DocumentViewerPage({required this.args, super.key});

  final DocumentViewerArgs args;

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  Uint8List? _bytes;
  PdfControllerPinch? _controller;
  String? _error;

  static const _minScale = 1.0;
  static const _maxScale = 5.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = Modular.get<LoginStore>().authToken;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

    setState(() => _error = null);
    try {
      final bytes = await Modular.get<OrganizationRepository>()
          .downloadDocument(
            widget.args.organizationId,
            widget.args.document.type,
            token,
          );
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _controller = PdfControllerPinch(document: PdfDocument.openData(bytes));
      });
    } on AppException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Não foi possível abrir o documento.');
      }
    }
  }

  void _zoom(double factor) {
    final controller = _controller;
    if (controller == null) return;
    final current = controller.value.getMaxScaleOnAxis();
    final next = (current * factor).clamp(_minScale, _maxScale);
    controller.value = Matrix4.identity()..scaleByDouble(next, next, next, 1);
  }

  Future<void> _download() async {
    final bytes = _bytes;
    if (bytes == null) return;
    try {
      await Modular.get<FileDownloadService>().savePdf(
        widget.args.document.fileName,
        bytes,
      );
      if (mounted) showAppSnackBar(context, 'Documento baixado.');
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, 'Não foi possível baixar o documento.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final error = _error;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: const AuthAppBar(showBackButton: true),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: const Color(0xFFFAFAFA),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
                child: Text(
                  widget.args.document.type.label,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF232323),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: error != null
                  ? AppErrorView(message: error, onRetry: _load)
                  : controller == null
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        PdfViewPinch(
                          controller: controller,
                          minScale: _minScale,
                          maxScale: _maxScale,
                        ),
                        Positioned(
                          top: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _PageCounter(controller: controller),
                          ),
                        ),
                      ],
                    ),
            ),
            ColoredBox(
              color: const Color(0xFFFAFAFA),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    AppSquareIconButton(
                      icon: Icons.zoom_in,
                      color: const Color(0xFF232323),
                      background: const Color(0xFFE8E8E8),
                      tooltip: 'Aproximar',
                      onPressed: controller == null ? null : () => _zoom(1.5),
                    ),
                    const SizedBox(width: 24),
                    AppSquareIconButton(
                      icon: Icons.zoom_out,
                      color: const Color(0xFF232323),
                      background: const Color(0xFFE8E8E8),
                      tooltip: 'Afastar',
                      onPressed: controller == null
                          ? null
                          : () => _zoom(1 / 1.5),
                    ),
                    const Spacer(),
                    AppSquareIconButton(
                      key: const Key('document_download_button'),
                      icon: Icons.download,
                      tooltip: 'Baixar',
                      color: Colors.white,
                      background: AppColors.success,
                      onPressed: _bytes == null ? null : _download,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageCounter extends StatelessWidget {
  const _PageCounter({required this.controller});

  final PdfControllerPinch controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: controller.pageListenable,
      builder: (_, page, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$page/${controller.pagesCount ?? 1}',
          style: GoogleFonts.manrope(fontSize: 15),
        ),
      ),
    );
  }
}
