import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../../domain/entities/organization.dart';
import '../stores/organization_contact_store.dart';
import '../widgets/organization_widgets.dart';

class OngContactFormPage extends StatefulWidget {
  const OngContactFormPage({
    required this.organization,
    super.key,
    this.store,
    this.token,
  });

  final Organization organization;
  final OrganizationContactStore? store;
  final String? token;

  @override
  State<OngContactFormPage> createState() => _OngContactFormPageState();
}

class _OngContactFormPageState extends State<OngContactFormPage> {
  late final OrganizationContactStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? Modular.get<OrganizationContactStore>();
    _store.populate(widget.organization);
  }

  Future<void> _save() async {
    final token = widget.token ?? Modular.get<LoginStore>().authToken;
    if (token == null) {
      Modular.to.navigate(AppRoutes.auth);
      return;
    }

    final saved = await _store.save(token);
    if (!mounted) return;

    showAppSnackBar(
      context,
      saved != null
          ? 'Dados da ONG atualizados.'
          : _store.errorMessage ?? 'Não foi possível salvar os dados da ONG.',
    );
    if (saved != null) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(showBackButton: true),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Observer(
              builder: (_) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppSectionTitle('Contato e endereço da ONG'),
                    const SizedBox(height: 16),
                    OrganizationAddressFields(
                      values: OrganizationAddressValues(
                        zipCode: _store.zipCode,
                        number: _store.number,
                        street: _store.street,
                        neighborhood: _store.neighborhood,
                        city: _store.city,
                        state: _store.state,
                        website: _store.website,
                        instagram: _store.instagram,
                      ),
                      callbacks: OrganizationAddressCallbacks(
                        onZipCode: _store.setZipCode,
                        onNumber: _store.setNumber,
                        onStreet: _store.setStreet,
                        onNeighborhood: _store.setNeighborhood,
                        onCity: _store.setCity,
                        onState: _store.setState,
                        onWebsite: _store.setWebsite,
                        onInstagram: _store.setInstagram,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppPrimaryButton(
                      key: const Key('ong_contact_save_button'),
                      label: 'Salvar',
                      isLoading: _store.isLoading,
                      onPressed: _store.canSave ? _save : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
