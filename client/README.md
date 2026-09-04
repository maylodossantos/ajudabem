# AjudaBem

Aplicativo Android em Flutter para apoiar a gestão de ONGs. Neste momento, o projeto está na fase de estruturação e mocks de tela, preparando a base para a implementação futura dos datasources.

## Arquitetura

O projeto segue Clean Architecture junto com Flutter Modular.

A estrutura principal fica em:

```txt
lib/
  core/
  modules/
```

`core` concentra recursos compartilhados do app, como tema, rotas e widgets reutilizáveis.

`modules` concentra as features do aplicativo. Cada módulo deve seguir a divisão:

```txt
modules/
  nome_do_modulo/
    data/
    domain/
    presentation/
```

`data` fica responsável por datasources, models e implementações de repositories.

`domain` concentra entities, repositories abstratos e usecases.

`presentation` concentra pages, widgets e stores/controladores de tela.

As rotas e injeções de dependência são organizadas com Flutter Modular. O módulo raiz fica em `lib/app_module.dart`, e cada módulo registra suas próprias rotas e binds.

## Estado

Estamos usando MobX como gerenciador de estado.

As stores devem ficar dentro da camada `presentation` do módulo relacionado, por exemplo:

```txt
lib/modules/auth/presentation/stores/login_store.dart
```

Stores MobX usam codegen. Sempre que criar ou alterar uma store com `@observable`, `@computed` ou `@action`, gere novamente os arquivos `.g.dart`:

```bash
dart run build_runner build
```

Para acompanhar alterações durante o desenvolvimento:

```bash
dart run build_runner watch
```

## Versão do Flutter

Este projeto está sendo desenvolvido com Flutter `3.44.2`.

Confira sua versão local com:

```bash
flutter --version
```

## Como Rodar

Instale as dependências:

```bash
flutter pub get
```

Gere os arquivos do MobX:

```bash
dart run build_runner build
```

Rode o app em um emulador ou dispositivo Android:

```bash
flutter run
```

Para listar dispositivos disponíveis:

```bash
flutter devices
```

Para rodar em um dispositivo específico:

```bash
flutter run -d <device_id>
```

## Qualidade

Rode a análise estática:

```bash
flutter analyze
```

Rode os testes:

```bash
flutter test
```

Formate o projeto:

```bash
dart format lib test
```

## Plataformas

Por enquanto, o foco do desenvolvimento é Android. A pasta iOS gerada pelo Flutter não deve guiar as decisões de implementação neste momento.
