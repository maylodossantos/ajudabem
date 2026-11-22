import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract final class AppIcons {
  static const _base = 'assets/icons/utilities';
  static const registeredPeople = '$_base/pessoas_cadastradas.svg';
  static const validationRequest = '$_base/validacao_solicitar.svg';
  static const validationReview = '$_base/validacao_avaliar.svg';
  static const volunteer = '$_base/voluntario.svg';
  static const news = '$_base/noticias.svg';
  static const needs = '$_base/necessidades.svg';
  static const myOng = '$_base/minha_ong.svg';
  static const nominatedPeople = '$_base/pessoas_indicadas.svg';
  static const inCare = '$_base/em_atendimento.svg';
  static const initiatives = '$_base/iniciativas.svg';
  static const edit = 'assets/icons/actions/editar.svg';
  static const delete = 'assets/icons/actions/excluir.svg';
  static const close = 'assets/icons/actions/fechar.svg';
  static const _shortcuts = 'assets/icons/shortcuts';
  static const indicatePerson = '$_shortcuts/indicar_pessoa.svg';
  static const helpPoints = '$_shortcuts/pontos_de_ajuda.svg';
  static const beVolunteer = '$_shortcuts/ser_voluntario.svg';
}

class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(this.asset, {super.key, this.color, this.size});

  final String asset;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      theme: color == null ? const SvgTheme() : SvgTheme(currentColor: color!),
    );
  }
}
