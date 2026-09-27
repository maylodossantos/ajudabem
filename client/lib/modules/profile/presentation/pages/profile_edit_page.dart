import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/formatters/cpf_input_formatter.dart';
import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/formatters/phone_input_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../../auth/presentation/stores/login_store.dart';
import '../stores/profile_edit_store.dart';
import '../stores/profile_store.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final LoginStore _loginStore;
  late final ProfileStore _profileStore;
  late final ProfileEditStore _editStore;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _cpfController;
  late final TextEditingController _birthDateController;

  @override
  void initState() {
    super.initState();
    _loginStore = Modular.get<LoginStore>();
    _profileStore = Modular.get<ProfileStore>();
    _editStore = Modular.get<ProfileEditStore>();

    final profile = _profileStore.profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _phoneController = TextEditingController(
      text: PhoneInputFormatter.format(profile?.phone ?? ''),
    );
    _emailController = TextEditingController(text: profile?.email ?? '');
    _cpfController = TextEditingController(
      text: CpfInputFormatter.display(profile?.cpf),
    );
    _birthDateController = TextEditingController(
      text: DateInputFormatter.display(profile?.birthDate),
    );

    if (profile != null) {
      _editStore.init(profile);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() =>
      pickAndUploadGalleryImage(context, _editStore.photo);

  Future<void> _save() async {
    final token = _loginStore.authToken;
    if (token == null) {
      return;
    }

    _editStore.setName(_nameController.text);
    _editStore.setPhone(_phoneController.text);

    final success = await _editStore.save(token);

    if (!mounted) {
      return;
    }

    if (success) {
      final updated = _editStore.savedProfile;
      if (updated != null) {
        _profileStore.updateProfile(updated);
      }

      showAppSnackBar(context, 'Perfil atualizado com sucesso!');
      Modular.to.pop();
      return;
    }

    showAppSnackBar(
      context,
      _editStore.errorMessage ?? 'Não foi possível salvar o perfil.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(showBackButton: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      children: [
                        Text(
                          'Editar perfil',
                          style: GoogleFonts.manrope(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Observer(
                          builder: (_) => _AvatarPicker(
                            imageUrl: _editStore.photo.imageUrl,
                            isUploading: _editStore.photo.isUploading,
                            onTap: _pickImage,
                          ),
                        ),
                        const SizedBox(height: 28),
                        AppTextField(
                          key: const Key('profile_edit_name_field'),
                          label: 'Nome:',
                          hintText: 'Nome',
                          controller: _nameController,
                          prefixIconAsset: 'assets/icons/register/user.svg',
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          key: const Key('profile_edit_phone_field'),
                          label: 'Telefone:',
                          hintText: 'Telefone',
                          controller: _phoneController,
                          prefixIconAsset: 'assets/icons/register/phone.svg',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [PhoneInputFormatter()],
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          key: const Key('profile_edit_cpf_field'),
                          label: 'CPF:',
                          hintText: '000.000.000-00',
                          controller: _cpfController,
                          prefixIcon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [CpfInputFormatter()],
                          onChanged: _editStore.setCpf,
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          key: const Key('profile_edit_birth_date_field'),
                          label: 'Data de nascimento:',
                          hintText: 'dd/mm/aaaa',
                          controller: _birthDateController,
                          prefixIcon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [DateInputFormatter()],
                          onChanged: _editStore.setBirthDate,
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          label: 'E-mail:',
                          hintText: 'E-mail',
                          controller: _emailController,
                          enabled: false,
                          prefixIconAsset: 'assets/icons/register/email.svg',
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: TextButton(
                            key: const Key('profile_edit_delete_account'),
                            onPressed: () => Modular.to.pushNamed(
                              AppRoutes.deleteAccountConfirm,
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Excluir minha conta',
                              style: GoogleFonts.manrope(
                                color: AppColors.danger,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Observer(
                  builder: (_) => Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: AppPrimaryButton(
                      key: const Key('profile_edit_save_button'),
                      label: 'Salvar alterações',
                      onPressed: _editStore.canSubmit ? _save : null,
                      isLoading: _editStore.isLoading,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.imageUrl,
    required this.isUploading,
    required this.onTap,
  });

  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('profile_edit_avatar_picker'),
      onTap: isUploading ? null : onTap,
      child: SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppAvatar(radius: 48, imageUrl: imageUrl),
            if (isUploading)
              const Positioned.fill(
                child: CircleAvatar(
                  backgroundColor: Color(0x99000000),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.camera_alt,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
