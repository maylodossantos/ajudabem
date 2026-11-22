import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_async_list.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_info_banner.dart';
import '../../../../core/widgets/app_map.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/app_floating_pill.dart';
import '../../../profile/presentation/stores/profile_store.dart';
import '../../domain/entities/help_point.dart';
import '../../domain/entities/help_point_filter.dart';
import '../stores/help_points_store.dart';
import '../widgets/help_point_widgets.dart';
import '../widgets/help_points_map.dart';

class HelpPointsPage extends StatefulWidget {
  const HelpPointsPage({
    super.key,
    this.store,
    this.canManage,
    this.showTiles = true,
  });

  final HelpPointsStore? store;
  final bool? canManage;
  final bool showTiles;

  @override
  State<HelpPointsPage> createState() => _HelpPointsPageState();
}

class _HelpPointsPageState extends State<HelpPointsPage> {
  late final HelpPointsStore _store;
  bool _showList = false;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<HelpPointsStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _store.load());
  }

  bool get _canManage =>
      widget.canManage ??
      (Modular.tryGet<ProfileStore>()?.profile?.isAdmin ?? false);

  Future<void> _openFilters() async {
    final filter = await Modular.to.pushNamed<HelpPointFilter>(
      AppRoutes.helpPointFilter,
      arguments: (_store.filter, _store.options),
    );
    if (filter != null) {
      await _store.applyFilter(filter);
    }
  }

  Future<void> _open(HelpPoint point) async {
    final changed = await Modular.to.pushNamed<bool>(
      AppRoutes.helpPointDetail,
      arguments: point,
    );
    if (changed == true && mounted) {
      await _store.load();
    }
  }

  Future<void> _create() async {
    final created = await Modular.to.pushNamed<bool>(AppRoutes.helpPointForm);
    if (created == true && mounted) {
      await _store.load();
    }
  }

  Widget _viewToggle() => AppFloatingPill(
    key: const Key('help_points_view_toggle'),
    icon: _showList ? Icons.map_outlined : Icons.format_list_bulleted,
    label: _showList ? 'Ver mapa' : 'Ver lista',
    onTap: () => setState(() => _showList = !_showList),
  );

  Widget _addButton() => AppMapButton(
    key: const Key('help_points_add_button'),
    icon: Icons.add,
    tooltip: 'Cadastrar ponto de ajuda',
    onTap: _create,
  );

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      currentItem: AppNavigationItem.help,
      maxWidth: double.infinity,
      showBackButton: false,
      floatingActionButton: _showList && _canManage ? _addButton() : null,
      body: Observer(
        builder: (_) => Stack(
          fit: StackFit.expand,
          children: [
            Offstage(
              offstage: _showList,
              child: TickerMode(
                enabled: !_showList,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    HelpPointsMap(
                      points: _store.mappedPoints,
                      isLoading: _store.isLoading,
                      showTiles: widget.showTiles,
                      now: _store.now,
                      distanceKmTo: _store.distanceKmTo,
                      onOpen: _open,
                      actions: [if (_canManage) _addButton()],
                      bottomCenter: _viewToggle(),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: _topControls(elevated: true),
                    ),
                  ],
                ),
              ),
            ),
            if (_showList)
              ColoredBox(
                color: AppColors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _topControls(elevated: false),
                    Expanded(child: _list()),
                  ],
                ),
              ),
            if (_showList)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Center(child: _viewToggle()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _topControls({required bool elevated}) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppFilterBar(
                activeLabels: _store.filter.activeLabels,
                onOpen: _openFilters,
                elevated: elevated,
              ),
              if (_store.isLocating)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              if (_store.locationError case final error?
                  when _store.filter.needsLocation)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AppInfoBanner(
                    icon: Icons.location_off_outlined,
                    message: error,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: AppAsyncList<HelpPoint>(
          items: _store.visiblePoints,
          isLoading: _store.isLoading,
          errorMessage: _store.errorMessage,
          emptyMessage: _store.points.isEmpty
              ? 'Nenhum ponto de ajuda cadastrado.'
              : 'Nenhum ponto de ajuda com esses filtros.',
          onRefresh: _store.load,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 84),
          itemBuilder: (_, point) => HelpPointCard(
            key: Key('help_point_list_${point.id}'),
            point: point,
            horizontal: true,
            distanceKm: _store.distanceKmTo(point),
            onTap: () => _open(point),
          ),
        ),
      ),
    );
  }
}
