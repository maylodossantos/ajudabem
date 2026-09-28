import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/formatters/cep_input_formatter.dart';
import '../../../../core/formatters/phone_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/external_link_service.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_item_actions_menu.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/app_square_icon_button.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../profile/presentation/stores/profile_store.dart';
import '../../domain/entities/help_point.dart';
import '../stores/help_points_store.dart';
import '../widgets/help_point_widgets.dart';

class HelpPointDetailPage extends StatefulWidget {
  const HelpPointDetailPage({required this.point, super.key});

  final HelpPoint point;

  @override
  State<HelpPointDetailPage> createState() => _HelpPointDetailPageState();
}

class _HelpPointDetailPageState extends State<HelpPointDetailPage> {
  late HelpPoint _point = widget.point;
  bool _changed = false;
  bool _isDeleting = false;

  ExternalLinkService get _links => Modular.get<ExternalLinkService>();

  bool get _canManage =>
      Modular.tryGet<ProfileStore>()?.profile?.isAdmin ?? false;

  String get _fullAddress => [
    _point.streetLabel,
    _point.cityLabel,
    CepInputFormatter.display(_point.zipCode),
  ].where((part) => part.isNotEmpty).join(', ');

  Future<void> _launch(Future<bool> Function() open) async {
    if (!await open() && mounted) {
      showAppSnackBar(context, 'Não foi possível abrir o aplicativo.');
    }
  }

  Future<void> _edit() async {
    final saved = await Modular.to.pushNamed<HelpPoint>(
      AppRoutes.helpPointForm,
      arguments: _point,
    );
    if (saved != null && mounted) {
      setState(() {
        _point = saved;
        _changed = true;
      });
    }
  }

  Future<void> _delete() async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Excluir ponto de ajuda?',
      message: '"${_point.name}" deixará de aparecer para todos.',
      confirmLabel: 'Excluir',
    );
    final token = Modular.get<LoginStore>().authToken;
    if (!confirmed || token == null || !mounted) return;

    setState(() => _isDeleting = true);
    final store = Modular.get<HelpPointsStore>();
    final success = await store.delete(_point.id, token);
    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (success) {
      showAppSnackBar(context, 'Ponto de ajuda excluído.');
      Navigator.of(context).pop(true);
    } else {
      showAppSnackBar(
        context,
        store.errorMessage ?? 'Não foi possível excluir.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final point = _point;
    final call = point.phone ?? point.whatsapp;
    final whatsapp = point.whatsapp;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AuthAppBar(
          showBackButton: true,
          onBack: () => Navigator.of(context).pop(_changed),
        ),
        bottomNavigationBar: const AppMainNavigation(
          currentItem: AppNavigationItem.help,
        ),
        body: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HelpPointCover(point: point, aspectRatio: 1.9),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(point.name, style: _Styles.title),
                          ),
                          if (_canManage)
                            AppItemActionsMenu(
                              tooltip: 'Opções do ponto de ajuda',
                              isBusy: _isDeleting,
                              onEdit: _edit,
                              onDelete: _delete,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              [
                                point.streetLabel,
                                [
                                  point.cityLabel,
                                  CepInputFormatter.display(point.zipCode),
                                ].where((part) => part.isNotEmpty).join(', '),
                              ].where((part) => part.isNotEmpty).join(',\n'),
                              style: _Styles.muted,
                            ),
                          ),
                          AppSquareIconButton(
                            key: const Key('help_point_map_button'),
                            icon: Icons.map_outlined,
                            tooltip: 'Ver no mapa',
                            color: Colors.white,
                            background: Theme.of(context).colorScheme.primary,
                            onPressed: () => _launch(
                              () => _links.openMap(
                                point: point.location,
                                address: _fullAddress,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (point.services.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        AssistanceTags(services: point.services),
                      ],
                      if (point.description.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(point.description, style: _Styles.body),
                      ],
                      if (_hasContact(point)) ...[
                        const SizedBox(height: 18),
                        Text('Contato', style: _Styles.section),
                        const SizedBox(height: 6),
                        if (point.phone case final phone?)
                          _Line('Telefone', PhoneInputFormatter.format(phone)),
                        if (point.whatsapp case final number?)
                          _Line('WhatsApp', PhoneInputFormatter.format(number)),
                        if (point.email case final email?)
                          _Line('E-mail', email),
                        if (point.responsible case final responsible?)
                          _Line('Responsável', responsible),
                        if (call != null || whatsapp != null) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              if (call != null)
                                _ContactButton(
                                  icon: Icons.call_outlined,
                                  label: 'Ligar',
                                  onPressed: () =>
                                      _launch(() => _links.call(call)),
                                ),
                              if (whatsapp != null)
                                _ContactButton(
                                  icon: Icons.chat_outlined,
                                  label: 'Mensagem',
                                  onPressed: () => _launch(
                                    () => _links.openWhatsApp(whatsapp),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                      if (point.scheduleLines.isNotEmpty ||
                          (point.scheduleNote?.isNotEmpty ?? false)) ...[
                        const SizedBox(height: 18),
                        Text(
                          'Horário de Funcionamento',
                          style: _Styles.section,
                        ),
                        const SizedBox(height: 6),
                        for (final line in point.scheduleLines)
                          Text(line, style: _Styles.body),
                        if (point.scheduleNote case final note?
                            when note.isNotEmpty)
                          Text(note, style: _Styles.body),
                      ],
                      if (point.noteLines.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('Observações:', style: _Styles.body),
                        for (final line in point.noteLines)
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text('•  $line', style: _Styles.body),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static bool _hasContact(HelpPoint point) =>
      point.phone != null ||
      point.whatsapp != null ||
      point.email != null ||
      point.responsible != null;
}

abstract final class _Styles {
  static final title = GoogleFonts.manrope(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static final section = GoogleFonts.manrope(
    color: Colors.black,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static final body = GoogleFonts.manrope(
    color: const Color(0xFF232323),
    fontSize: 15,
    height: 1.35,
    letterSpacing: 0,
  );

  static final muted = GoogleFonts.manrope(
    color: const Color(0xFF6B6B6B),
    fontSize: 15,
    height: 1.35,
    letterSpacing: 0,
  );
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text('$label: $value', style: _Styles.body);
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
