import 'package:flutter/material.dart';

import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_document_card.dart';
import '../../../../core/widgets/app_main_navigation.dart';
import '../../../../core/widgets/auth_app_bar.dart';

class AboutConfigPage extends StatelessWidget {
  const AboutConfigPage({super.key});

  static const _sections = [
    DocumentSection(
      title: 'Sobre Nós',
      isMajor: true,
      blocks: [
        DocumentParagraph(
          'O AjudaBem é uma plataforma criada para facilitar a '
          'identificação de pessoas em situação de vulnerabilidade e '
          'conectar essas situações a organizações que possam oferecer '
          'apoio e assistência.',
        ),
        DocumentParagraph(
          'Nosso objetivo é permitir que cidadãos comuniquem, de forma '
          'responsável, situações que possam necessitar de atenção social, '
          'como falta de moradia, necessidade de alimentação, cuidados de '
          'saúde ou apoio emocional. Essas informações são encaminhadas '
          'exclusivamente para instituições e organizações parceiras que '
          'atuam na área de assistência social.',
        ),
        DocumentParagraph(
          'O AjudaBem não tem como finalidade expor pessoas ou tornar '
          'públicas informações sensíveis. Por isso, a plataforma adota '
          'medidas para reduzir riscos à privacidade e à segurança das '
          'pessoas descritas nos registros.',
        ),
      ],
    ),
    DocumentSection(
      title: 'Como funciona',
      blocks: [
        DocumentParagraph(
          'Usuários podem registrar situações de vulnerabilidade informando:',
        ),
        DocumentBullets([
          'localização aproximada',
          'descrição da situação observada',
          'necessidades aparentes da pessoa',
        ]),
        DocumentParagraph(
          'Essas informações são analisadas e disponibilizadas apenas para '
          'organizações parceiras verificadas, que podem avaliar a situação '
          'e decidir se podem realizar algum tipo de ação ou '
          'acompanhamento.',
        ),
      ],
    ),
    DocumentSection(
      title: 'Privacidade e proteção de dados',
      isMajor: true,
      blocks: [
        DocumentParagraph(
          'O AjudaBem foi desenvolvido com foco em minimização de dados e '
          'proteção da privacidade. A plataforma não exige identificação '
          'direta da pessoa descrita, evitando coleta de informações como '
          'documentos, fotos ou dados que possam expor indevidamente '
          'alguém.',
        ),
        DocumentParagraph(
          'As informações registradas são utilizadas exclusivamente para '
          'fins de assistência social e encaminhamento a organizações '
          'parceiras. O acesso é restrito e controlado, não havendo '
          'divulgação pública dessas informações.',
        ),
        DocumentParagraph(
          'O tratamento de dados segue os princípios da Lei Geral de '
          'Proteção de Dados Pessoais (LGPD), respeitando a finalidade '
          'social da plataforma e priorizando a proteção da dignidade, '
          'privacidade e segurança das pessoas envolvidas.',
        ),
      ],
    ),
    DocumentSection(
      title: 'Uso responsável da plataforma',
      blocks: [
        DocumentParagraph(
          'Ao registrar uma situação, o usuário declara que está fornecendo '
          'informações de boa-fé e que o objetivo do cadastro é '
          'exclusivamente possibilitar assistência social. O AjudaBem não '
          'deve ser utilizado para exposição, discriminação ou qualquer '
          'forma de uso indevido de informações sobre terceiros.',
        ),
      ],
    ),
    DocumentSection(
      title: 'Nosso compromisso',
      blocks: [
        DocumentParagraph(
          'O AjudaBem acredita que a tecnologia pode ser uma ferramenta '
          'importante para aproximar quem precisa de ajuda de quem pode '
          'ajudar. Por isso, buscamos construir um ambiente seguro, '
          'responsável e voltado ao bem-estar social.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(showBackButton: true),
      bottomNavigationBar: const AppMainNavigation(
        key: Key('about_bottom_navigation'),
        currentItem: AppNavigationItem.profile,
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: const SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: AppDocumentCard(sections: _sections),
            ),
          ),
        ),
      ),
    );
  }
}
