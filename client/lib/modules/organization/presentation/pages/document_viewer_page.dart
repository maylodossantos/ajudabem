import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/document_print_service.dart';
import '../../../../core/services/file_download_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_pdf_viewer.dart';
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
  final _viewer = AppPdfViewerController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
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
      setState(() => _bytes = bytes);
    } on AppException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Não foi possível abrir o documento.');
      }
    }
  }

  Future<void> _print() async {
    final bytes = _bytes;
    if (bytes == null) return;
    try {
      await Modular.get<DocumentPrintService>().printPdf(
        widget.args.document.fileName,
        bytes,
      );
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, 'Não foi possível imprimir o documento.');
      }
    }
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
    final bytes = _bytes;
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
                  : bytes == null
                  ? const Center(child: CircularProgressIndicator())
                  : AppPdfViewer(bytes: bytes, controller: _viewer),
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
                      key: const Key('document_zoom_in_button'),
                      icon: Icons.zoom_in,
                      color: const Color(0xFF232323),
                      background: const Color(0xFFE8E8E8),
                      tooltip: 'Aproximar',
                      onPressed: bytes == null
                          ? null
                          : () => _viewer.zoomBy(1.5),
                    ),
                    const SizedBox(width: 8),
                    AppSquareIconButton(
                      key: const Key('document_zoom_out_button'),
                      icon: Icons.zoom_out,
                      color: const Color(0xFF232323),
                      background: const Color(0xFFE8E8E8),
                      tooltip: 'Afastar',
                      onPressed: bytes == null
                          ? null
                          : () => _viewer.zoomBy(1 / 1.5),
                    ),
                    const Spacer(),
                    AppSquareIconButton(
                      key: const Key('document_print_button'),
                      icon: Icons.print_outlined,
                      tooltip: 'Imprimir',
                      color: const Color(0xFF232323),
                      background: const Color(0xFFE8E8E8),
                      onPressed: _bytes == null ? null : _print,
                    ),
                    const SizedBox(width: 8),
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
