import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/brazilian_states.dart';
import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_cep_field.dart';
import '../../../../core/widgets/app_labeled_field.dart';
import '../../domain/entities/organization.dart';
import '../pages/document_viewer_page.dart';

class OrganizationField extends StatelessWidget {
  const OrganizationField(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: AppColors.textMuted,
            fontSize: AppTextSize.small,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '—' : value,
          style: GoogleFonts.manrope(
            color: AppColors.textBody,
            fontSize: AppTextSize.small,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class OrganizationFieldGrid extends StatelessWidget {
  const OrganizationFieldGrid({required this.fields, super.key});

  final List<(String, String)> fields;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < fields.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: OrganizationField(fields[i].$1, fields[i].$2)),
              const SizedBox(width: 12),
              Expanded(
                child: i + 1 < fields.length
                    ? OrganizationField(fields[i + 1].$1, fields[i + 1].$2)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class OrganizationDocumentTile extends StatelessWidget {
  const OrganizationDocumentTile({
    required this.organizationId,
    required this.type,
    required this.document,
    super.key,
  });

  final int organizationId;
  final OrganizationDocumentType type;
  final OrganizationDocument? document;

  @override
  Widget build(BuildContext context) {
    final document = this.document;
    final sentAt = document?.sentAt;

    return Material(
      color: AppColors.surfaceSubtle,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: document == null
            ? null
            : () => Modular.to.pushNamed(
                AppRoutes.documentViewer,
                arguments: DocumentViewerArgs(
                  organizationId: organizationId,
                  document: document,
                ),
              ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.textBody,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: GoogleFonts.manrope(
                        color: AppColors.textBody,
                        fontSize: AppTextSize.title,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      document == null
                          ? 'Não enviado'
                          : sentAt == null
                          ? 'Enviado'
                          : 'Enviado em ${DateInputFormatter.display(sentAt)}',
                      style: GoogleFonts.manrope(
                        color: document == null
                            ? AppColors.danger
                            : AppColors.textMuted,
                        fontSize: AppTextSize.small,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.textMuted),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrganizationAddressValues {
  const OrganizationAddressValues({
    required this.zipCode,
    required this.number,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.website,
    required this.instagram,
  });

  final String zipCode;
  final String number;
  final String street;
  final String neighborhood;
  final String city;
  final String? state;
  final String website;
  final String instagram;
}

class OrganizationAddressCallbacks {
  const OrganizationAddressCallbacks({
    required this.onZipCode,
    required this.onNumber,
    required this.onStreet,
    required this.onNeighborhood,
    required this.onCity,
    required this.onState,
    required this.onWebsite,
    required this.onInstagram,
  });

  final ValueChanged<String> onZipCode;
  final ValueChanged<String> onNumber;
  final ValueChanged<String> onStreet;
  final ValueChanged<String> onNeighborhood;
  final ValueChanged<String> onCity;
  final ValueChanged<String> onState;
  final ValueChanged<String> onWebsite;
  final ValueChanged<String> onInstagram;
}

class OrganizationAddressFields extends StatelessWidget {
  const OrganizationAddressFields({
    required this.values,
    required this.callbacks,
    super.key,
  });

  final OrganizationAddressValues values;
  final OrganizationAddressCallbacks callbacks;

  static const _gap = SizedBox(height: 10);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppCepField(
                key: const Key('ong_form_cep_field'),
                initialValue: values.zipCode,
                onChanged: callbacks.onZipCode,
                required: true,
                onStreet: callbacks.onStreet,
                onNeighborhood: callbacks.onNeighborhood,
                onCity: callbacks.onCity,
                onState: callbacks.onState,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppLabeledField(
                label: 'Número',
                required: true,
                initialValue: values.number,
                onChanged: callbacks.onNumber,
              ),
            ),
          ],
        ),
        _gap,
        AppLabeledField(
          label: 'Endereço',
          required: true,
          initialValue: values.street,
          onChanged: callbacks.onStreet,
        ),
        _gap,
        AppLabeledField(
          label: 'Bairro',
          initialValue: values.neighborhood,
          onChanged: callbacks.onNeighborhood,
        ),
        _gap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppLabeledField(
                label: 'Cidade',
                required: true,
                initialValue: values.city,
                onChanged: callbacks.onCity,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppLabeledDropdown<String>(
                label: 'Estado',
                required: true,
                hintText: 'Selecione',
                value: values.state,
                options: BrazilianStates.codes,
                labelOf: BrazilianStates.nameOf,
                onChanged: callbacks.onState,
              ),
            ),
          ],
        ),
        _gap,
        AppLabeledField(
          label: 'Site',
          initialValue: values.website,
          keyboardType: TextInputType.url,
          onChanged: callbacks.onWebsite,
        ),
        _gap,
        AppLabeledField(
          label: 'Instagram',
          initialValue: values.instagram,
          onChanged: callbacks.onInstagram,
        ),
      ],
    );
  }
}
