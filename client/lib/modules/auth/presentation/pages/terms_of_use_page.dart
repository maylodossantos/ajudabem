import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_document_card.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../stores/register_store.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key, this.store});

  final RegisterStore? store;

  static const _sections = [
    DocumentSection(title: 'Termos de Uso', isMajor: true),
    DocumentSection(
      title: '1. Aceitação dos Termos',
      blocks: [
        DocumentParagraph(
          'Ao acessar ou utilizar a plataforma AjudaBem, o usuário declara '
          'que leu, compreendeu e concorda com estes Termos de Uso e com a '
          'coleta e tratamento de seus dados conforme descrito neste '
          'documento.',
        ),
        DocumentParagraph(
          'Caso o usuário não concorde com qualquer parte destes termos, '
          'não deverá utilizar a plataforma.',
        ),
      ],
    ),
    DocumentSection(
      title: '2. Sobre a Plataforma',
      blocks: [
        DocumentParagraph(
          'O AjudaBem é uma plataforma que tem como objetivo facilitar a '
          'conexão entre pessoas que necessitam de ajuda e organizações, '
          'voluntários ou instituições que possam oferecer suporte.',
        ),
        DocumentParagraph(
          'A plataforma atua apenas como intermediadora dessas conexões, '
          'não sendo responsável direto pela prestação dos serviços '
          'realizados por terceiros.',
        ),
      ],
    ),
    DocumentSection(
      title: '3. Cadastro de Usuários',
      blocks: [
        DocumentParagraph(
          'Para utilizar determinadas funcionalidades da plataforma, poderá '
          'ser necessário realizar cadastro.',
        ),
        DocumentParagraph('O usuário se compromete a:'),
        DocumentBullets([
          'Fornecer informações verdadeiras e atualizadas',
          'Não utilizar dados falsos ou de terceiros sem autorização',
          'Utilizar a plataforma de forma ética e legal',
        ]),
        DocumentParagraph(
          'O AjudaBem poderá suspender ou remover contas que violem estes '
          'termos.',
        ),
      ],
    ),
    DocumentSection(
      title: '4. Consentimento para Coleta e Uso de Dados',
      blocks: [
        DocumentParagraph(
          'A utilização da plataforma está condicionada ao consentimento '
          'explícito do usuário para coleta e tratamento de dados.',
        ),
        DocumentParagraph(
          'Ao aceitar estes termos, o usuário autoriza o AjudaBem a coletar '
          'e armazenar dados necessários para funcionamento da plataforma.',
        ),
        DocumentParagraph('Esses dados podem incluir:'),
        DocumentBullets([
          'Nome',
          'Localização aproximada',
          'Características ou informações fornecidas voluntariamente',
          'Informações de contato',
          'Dados de organizações cadastradas',
        ]),
        DocumentParagraph('Esses dados são utilizados exclusivamente para:'),
        DocumentBullets([
          'Identificação dentro da plataforma',
          'Facilitar conexões entre pessoas e organizações',
          'Melhorar os serviços oferecidos',
        ]),
        DocumentParagraph(
          'Nenhum dado será coletado ou armazenado sem o consentimento do '
          'usuário.',
        ),
      ],
    ),
    DocumentSection(
      title: '5. Armazenamento e Segurança das Informações',
      blocks: [
        DocumentParagraph(
          'O AjudaBem adota medidas técnicas e organizacionais para proteger '
          'os dados armazenados, incluindo:',
        ),
        DocumentBullets([
          'Controle de acesso restrito',
          'Proteção contra acesso não autorizado',
          'Monitoramento e registros de acesso',
          'Boas práticas de segurança em banco de dados',
        ]),
        DocumentParagraph(
          'Apesar das medidas de segurança adotadas, nenhum sistema é '
          'totalmente imune a riscos, e o usuário reconhece essa condição '
          'ao utilizar a plataforma.',
        ),
      ],
    ),
    DocumentSection(
      title: '6. Compartilhamento de Dados',
      blocks: [
        DocumentParagraph(
          'Os dados fornecidos poderão ser compartilhados apenas quando '
          'necessário para o funcionamento da plataforma, como por exemplo:',
        ),
        DocumentBullets([
          'Para permitir que ONGs ou voluntários entrem em contato',
          'Para viabilizar o atendimento solicitado',
        ]),
        DocumentParagraph('O AjudaBem não comercializa dados pessoais.'),
      ],
    ),
    DocumentSection(
      title: '7. Direitos do Usuário',
      blocks: [
        DocumentParagraph(
          'De acordo com a legislação aplicável de proteção de dados '
          '(incluindo a LGPD), o usuário pode:',
        ),
        DocumentBullets([
          'Solicitar acesso aos seus dados',
          'Solicitar correção de dados incorretos',
          'Solicitar exclusão de seus dados',
          'Revogar seu consentimento a qualquer momento',
        ]),
        DocumentParagraph(
          'Solicitações podem ser realizadas através dos canais de contato '
          'disponibilizados pela plataforma.',
        ),
      ],
    ),
    DocumentSection(
      title: '8. Exclusão de Conta',
      blocks: [
        DocumentParagraph(
          'O usuário poderá solicitar a exclusão de sua conta a qualquer '
          'momento.',
        ),
        DocumentParagraph(
          'Após a solicitação, os dados poderão ser removidos do sistema, '
          'exceto quando houver necessidade de retenção por obrigação legal '
          'ou segurança da plataforma.',
        ),
      ],
    ),
    DocumentSection(
      title: '9. Limitação de Responsabilidade',
      blocks: [
        DocumentParagraph('O AjudaBem não garante:'),
        DocumentBullets([
          'Disponibilidade contínua da plataforma',
          'A veracidade de todas as informações fornecidas por usuários ou '
              'organizações',
          'A qualidade ou execução dos serviços prestados por terceiros',
        ]),
        DocumentParagraph(
          'O uso da plataforma é realizado sob responsabilidade do usuário.',
        ),
      ],
    ),
    DocumentSection(
      title: '10. Alterações nos Termos',
      blocks: [
        DocumentParagraph(
          'Estes Termos de Uso podem ser atualizados a qualquer momento para '
          'refletir melhorias ou alterações na plataforma.',
        ),
        DocumentParagraph(
          'Quando isso ocorrer, a nova versão será publicada com a data de '
          'atualização.',
        ),
      ],
    ),
    DocumentSection(
      title: '11. Contato',
      blocks: [
        DocumentParagraph(
          'Para dúvidas, solicitações relacionadas a dados ou suporte, o '
          'usuário poderá entrar em contato através dos canais oficiais do '
          'AjudaBem.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final registerStore = store ?? Modular.get<RegisterStore>();

    void answer(bool accepted) {
      registerStore.setAcceptedTerms(accepted);
      Navigator.of(context).pop();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(showBackButton: true),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: AppOutlinedButton(
                    key: const Key('terms_decline_button'),
                    label: 'Recusar',
                    onPressed: () => answer(false),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: AppPrimaryButton(
                    key: const Key('terms_accept_button'),
                    label: 'Aceitar',
                    onPressed: () => answer(true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
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
