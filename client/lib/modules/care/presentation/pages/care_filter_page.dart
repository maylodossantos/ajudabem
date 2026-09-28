import 'package:flutter/material.dart';

import '../../../../core/widgets/app_choice_chip.dart';
import '../../../../core/widgets/app_filter_scaffold.dart';
import '../../domain/entities/care_case.dart';
import '../../domain/entities/care_filter.dart';
import '../stores/care_list_store.dart';

class CareFilterPage extends StatefulWidget {
  const CareFilterPage({
    required this.initial,
    required this.options,
    required this.mode,
    super.key,
  });

  final CareFilter initial;
  final CareOptions options;
  final CareListMode mode;

  @override
  State<CareFilterPage> createState() => _CareFilterPageState();
}

class _CareFilterPageState extends State<CareFilterPage> {
  late CareFilter _filter = widget.initial;

  Set<T> _toggle<T>(Set<T> current, T option) {
    final next = Set.of(current);
    if (!next.remove(option)) next.add(option);
    return next;
  }

  void _update(CareFilter filter) => setState(() => _filter = filter);

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final myCases = widget.mode == CareListMode.myCases;
    final needs = options.needs.toList()..sort();

    return AppFilterScaffold(
      onReset: () => _update(const CareFilter()),
      onSave: () => Navigator.of(context).pop(_filter),
      sections: [
        if (options.urgencies.isNotEmpty)
          AppFilterSection(
            title: 'Urgência',
            child: AppChoiceChipGroup<Urgency>(
              options: Urgency.values
                  .where(options.urgencies.contains)
                  .toList(),
              labelOf: (urgency) => urgency.label,
              isSelected: _filter.urgencies.contains,
              onToggle: (urgency) => _update(
                _filter.copyWith(
                  urgencies: _toggle(_filter.urgencies, urgency),
                ),
              ),
            ),
          ),
        if (myCases && options.statuses.length > 1)
          AppFilterSection(
            title: 'Situação',
            child: AppChoiceChipGroup<CareStatus>(
              options: CareStatus.values
                  .where(options.statuses.contains)
                  .toList(),
              labelOf: (status) => status.label,
              isSelected: _filter.statuses.contains,
              onToggle: (status) => _update(
                _filter.copyWith(statuses: _toggle(_filter.statuses, status)),
              ),
            ),
          ),
        if (myCases && options.finishReasons.isNotEmpty)
          AppFilterSection(
            title: 'Resultado',
            child: AppChoiceChipGroup<FinishReason>(
              options: FinishReason.values
                  .where(options.finishReasons.contains)
                  .toList(),
              labelOf: (reason) => reason.label,
              isSelected: _filter.finishReasons.contains,
              onToggle: (reason) => _update(
                _filter.copyWith(
                  finishReasons: _toggle(_filter.finishReasons, reason),
                ),
              ),
            ),
          ),
        if (options.hasDistances)
          AppFilterSection(
            title: 'Distância',
            child: AppDistanceSlider(
              key: const Key('care_filter_distance'),
              maxDistanceKm: _filter.maxDistanceKm,
              onChanged: (km) => _update(_filter.withMaxDistance(km)),
            ),
          ),
        if (needs.isNotEmpty)
          AppFilterSection(
            title: 'Necessidades',
            child: AppChoiceChipGroup<String>(
              options: needs,
              labelOf: (need) => need,
              isSelected: _filter.needs.contains,
              onToggle: (need) => _update(
                _filter.copyWith(needs: _toggle(_filter.needs, need)),
              ),
            ),
          ),
      ],
    );
  }
}
