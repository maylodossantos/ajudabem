import 'package:flutter/material.dart';

import '../../../../core/widgets/app_choice_chip.dart';
import '../../../../core/widgets/app_filter_scaffold.dart';
import '../../domain/entities/help_point.dart';
import '../../domain/entities/help_point_filter.dart';

class HelpPointFilterPage extends StatefulWidget {
  const HelpPointFilterPage({
    required this.initial,
    required this.options,
    super.key,
  });

  final HelpPointFilter initial;
  final HelpPointOptions options;

  @override
  State<HelpPointFilterPage> createState() => _HelpPointFilterPageState();
}

class _HelpPointFilterPageState extends State<HelpPointFilterPage> {
  late HelpPointFilter _filter = widget.initial;

  Set<T> _toggle<T>(Set<T> current, T option) {
    final next = Set.of(current);
    if (!next.remove(option)) next.add(option);
    return next;
  }

  void _update(HelpPointFilter filter) => setState(() => _filter = filter);

  @override
  Widget build(BuildContext context) {
    final options = widget.options;

    return AppFilterScaffold(
      onReset: () => _update(const HelpPointFilter()),
      onSave: () => Navigator.of(context).pop(_filter),
      sections: [
        if (options.types.isNotEmpty)
          AppFilterSection(
            title: 'Tipo de Local',
            child: AppChoiceChipGroup<AssistanceType>(
              options: AssistanceType.values
                  .where(options.types.contains)
                  .toList(),
              labelOf: (type) => type.label,
              isSelected: _filter.types.contains,
              onToggle: (type) => _update(
                _filter.copyWith(types: _toggle(_filter.types, type)),
              ),
            ),
          ),
        if (options.hasLocations) ...[
          AppFilterSection(
            title: 'Distância',
            child: AppDistanceSlider(
              key: const Key('help_point_filter_distance'),
              maxDistanceKm: _filter.maxDistanceKm,
              limitKm: HelpPointFilter.maxDistanceLimitKm,
              onChanged: (km) => _update(_filter.withMaxDistance(km)),
            ),
          ),
          AppFilterSection(
            title: 'Ordenar',
            child: AppChoiceChipGroup<HelpPointSort>(
              options: HelpPointSort.values,
              labelOf: (sort) => sort.label,
              isSelected: (sort) => _filter.sort == sort,
              onToggle: (sort) => _update(_filter.copyWith(sort: sort)),
            ),
          ),
        ],
        if (options.availability.isNotEmpty)
          AppFilterSection(
            title: 'Disponibilidade',
            child: AppChoiceChipGroup<HelpPointAvailability>(
              options: HelpPointAvailability.values
                  .where(options.availability.contains)
                  .toList(),
              labelOf: (option) => option.label,
              isSelected: _filter.availability.contains,
              onToggle: (option) => _update(
                _filter.copyWith(
                  availability: _toggle(_filter.availability, option),
                ),
              ),
            ),
          ),
        if (options.organizationTypes.isNotEmpty)
          AppFilterSection(
            title: 'Tipo de organização',
            child: AppChoiceChipGroup<HelpPointOrganizationType>(
              options: HelpPointOrganizationType.values
                  .where(options.organizationTypes.contains)
                  .toList(),
              labelOf: (type) => type.label,
              isSelected: _filter.organizationTypes.contains,
              onToggle: (type) => _update(
                _filter.copyWith(
                  organizationTypes: _toggle(_filter.organizationTypes, type),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
