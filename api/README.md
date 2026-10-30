# Backend AjudaBem

API em Java 17 com Spring Boot, PostgreSQL e migrações Flyway. Este guia prepara o ambiente local do zero no Windows com PowerShell. Ajuste o caminho se clonou o repositório em outra pasta.

## 1. Pré-requisitos

- **Git**, para clonar e atualizar o repositório.
- **JDK 17**, com `JAVA_HOME` apontando para a pasta do JDK e `%JAVA_HOME%\bin` no `PATH`.
- **Docker Desktop**, configurado para executar containers Linux, com o motor iniciado. Conclua a configuração inicial e reinicie o Windows se solicitado. Se o Docker pedir atualização do WSL, siga as instruções exibidas por ele.
- **IntelliJ IDEA**, opcional: a API também pode ser executada pelo terminal.
- Internet na primeira execução para baixar Maven, dependências, imagens Docker e, caso habilitada, a IA local.

Não é necessário instalar Maven, PostgreSQL, MailDev ou Ollama separadamente: o projeto inclui Maven Wrapper e Docker Compose. A API Java roda no computador; os serviços auxiliares rodam no Docker.

Abra um novo PowerShell após instalar as ferramentas e confira:

```powershell
java -version
javac -version
$env:JAVA_HOME
docker --version
docker compose version
docker info
```

Java e compilador devem indicar a versão 17. `JAVA_HOME` deve apontar para o JDK, por exemplo `C:\Program Files\Java\jdk-17`, sem `\bin`. O comando `docker info` deve mostrar a seção `Server` sem erro.

## 2. Entrar na pasta da API

Depois de clonar o repositório:

```powershell
cd C:\projetos\ajudabem\api
```

Todos os comandos seguintes consideram essa pasta como diretório atual. Para o ambiente local padrão, não é necessário criar um `.env` ou editar `application.properties`.

## 3. Iniciar os serviços

Com o Docker Desktop aberto, inicie o banco e o servidor de e-mail de testes:

```powershell
docker compose up -d db maildev
docker compose ps
```

Aguarde o serviço `db` aparecer como `healthy`. O primeiro início baixa as imagens e cria o banco.

| Serviço | Função | Endereço/porta padrão |
| --- | --- | --- |
| PostgreSQL (`db`) | Persistência da aplicação | `localhost:5432` |
| MailDev (`maildev`) | Captura dos e-mails de teste | SMTP: `localhost:1025`; interface: [localhost:1080](http://localhost:1080) |
| Ollama (`ollama`, opcional) | IA para classificação de risco das pessoas assistidas | `localhost:11434` |
| `ollama-pull` (opcional) | Baixa o modelo usado pelo Ollama | Encerra após concluir o download |

O banco, usuário e senha locais são **`ajudabem`**. O MailDev recebe as mensagens da API e permite lê-las no navegador; elas não são entregues às caixas de e-mail reais. Não é necessário configurar Gmail ou outro provedor para testar os fluxos de e-mail.

### Habilitar a triagem por IA

Para também executar a classificação automática de risco:

```powershell
docker compose up -d ollama ollama-pull
docker compose logs -f ollama-pull
```

O serviço `ollama-pull` baixa o modelo **`qwen2.5:3b`**. Reserve espaço em disco e aguarde o download terminar; essa etapa pode demorar e a inferência depende dos recursos da máquina. Use `Ctrl+C` para sair dos logs sem parar os containers.

Confira se o modelo está disponível:

```powershell
docker compose exec ollama ollama list
```

Também é possível iniciar todos os serviços de uma vez:

```powershell
docker compose up -d
```

Sem Ollama, a API inicia e os demais fluxos podem ser usados, mas as pessoas assistidas aguardam classificação. A triagem tenta novamente a cada 60 segundos por padrão e pode registrar avisos de conexão enquanto o serviço ou o modelo estiverem indisponíveis.

## 4. Executar a API

### Pelo PowerShell

```powershell
.\mvnw.cmd spring-boot:run
```

O Maven Wrapper baixa o Maven e as dependências na primeira execução. Mantenha esse terminal aberto enquanto usa a API.

### Pelo IntelliJ IDEA

1. Abra a pasta `api` como projeto Maven, usando o `pom.xml`.
2. Configure o SDK do projeto e o JDK do Maven como **Java 17**.
3. Aguarde a importação das dependências.
4. Execute a classe `com.ajudabem.api.ApiApplication` em Run ou Debug.

Escolha uma das formas de execução para evitar duas APIs disputando a porta 8080. O perfil padrão é `dev`; não é necessário informar um perfil para o desenvolvimento local.

Na inicialização, o **Flyway aplica automaticamente as migrações pendentes**. Não crie tabelas manualmente e não altere migrações já aplicadas. O Hibernate valida o esquema resultante.

A inicialização terminou quando o log mostrar:

```text
Tomcat started on port 8080
Started ApiApplication
```

## 5. Acessar e testar

- API: [http://localhost:8080](http://localhost:8080).
- Swagger: [http://localhost:8080/swagger-ui/index.html](http://localhost:8080/swagger-ui/index.html).
- Especificação OpenAPI: [http://localhost:8080/v3/api-docs](http://localhost:8080/v3/api-docs).
- E-mails de teste: [http://localhost:1080](http://localhost:1080).

A raiz `/` não é uma tela do sistema e sua resposta não confirma, por si só, um problema de inicialização. Use o Swagger para consultar os endpoints. Para rotas autenticadas, faça login e informe o JWT no botão **Authorize** do Swagger.

### Administrador local

Ao iniciar no perfil `dev`, a API cria esta conta automaticamente, caso ainda não exista:

| Campo | Valor |
| --- | --- |
| E-mail | `admin@ajudabem.local` |
| Senha inicial | `Admin@123456` |
| Permissão | `ADMIN` |

Entre pelo login normal do app. No **Perfil**, acesse a análise das ONGs para aprovar ou rejeitar solicitações.

A senha é armazenada criptografada. Reiniciar a API não duplica a conta nem redefine a senha. Uma conta existente com o mesmo e-mail é preservada, inclusive suas permissões. Em uma máquina nova com banco novo, iniciar a API cria o administrador novamente; os demais dados da máquina antiga não são transferidos automaticamente.

## 6. Configuração por variáveis de ambiente

Os padrões atendem ao desenvolvimento local. Para ajustes, defina variáveis no PowerShell **antes** de iniciar a API, ou em **Environment variables** da configuração Run/Debug do IntelliJ.

| Variável | Padrão local | Uso |
| --- | --- | --- |
| `DB_HOST` | `localhost` | Host do PostgreSQL |
| `DB_PORT` | `5432` | Porta do PostgreSQL |
| `DB_NAME` | `ajudabem` | Nome do banco |
| `DB_USER` / `DB_PASSWORD` | `ajudabem` | Credenciais do banco |
| `MAIL_HOST` / `MAIL_PORT` | `localhost` / `1025` | Servidor SMTP |
| `MAIL_USERNAME` / `MAIL_PASSWORD` | Vazios | Credenciais SMTP, se exigidas |
| `MAIL_SMTP_AUTH` / `MAIL_SMTP_STARTTLS` | `false` | Autenticação e STARTTLS do SMTP |
| `MAIL_FROM` | `no-reply@ajudabem.com` | Remetente dos e-mails |
| `OLLAMA_URL` | `http://localhost:11434` | Endereço do Ollama |
| `OLLAMA_MODEL` | `qwen2.5:3b` | Modelo usado e baixado pelo Compose |
| `TRIAGE_INTERVAL_MS` | `60000` | Intervalo da triagem, em milissegundos |
| `CORS_ALLOWED_ORIGINS` | `http://localhost:4200` | Origens web permitidas, separadas por vírgulas |
| `JWT_SECRET` | Valor de desenvolvimento em `application.properties` | Segredo de assinatura dos tokens |
| `SPRING_PROFILES_ACTIVE` | Não definido; perfil padrão `dev` | Perfil ativo da API |
| `SERVER_PORT` | `8080` | Porta HTTP da API |
| `GEOCODING_URL` | `https://nominatim.openstreetmap.org` | Serviço externo de geocodificação usado pelas funcionalidades que o consultam |

Exemplo para usar outra porta local para o PostgreSQL:

```powershell
$env:DB_PORT = "5433"
docker compose up -d db maildev
.\mvnw.cmd spring-boot:run
```

As variáveis desse exemplo valem para a sessão atual. Se iniciar pelo IntelliJ, configure `DB_PORT=5433` também na execução da API.

O Compose aceita ainda `MAILDEV_SMTP_PORT`, `MAILDEV_WEB_PORT` e `OLLAMA_PORT` para alterar as portas publicadas. Ajuste respectivamente `MAIL_PORT`, o endereço aberto no navegador e `OLLAMA_URL` na API. Alterar `DB_NAME`, `DB_USER` ou `DB_PASSWORD` no Compose não reconfigura um banco já inicializado no volume existente.

Um `.env` é lido pelo Compose, mas não é carregado automaticamente pela API Java executada no terminal ou IntelliJ. Mantenha os valores compatíveis nos dois ambientes.

Para usar Flutter web em outra origem, adicione-a em `CORS_ALLOWED_ORIGINS`. Em um celular físico, `localhost` aponta para o próprio celular: configure o app com o IP da máquina que executa a API e permita o acesso à porta no firewall, quando necessário.

### Perfil de produção

Em produção, defina `SPRING_PROFILES_ACTIVE=prod`, um `JWT_SECRET` próprio e as credenciais/endpoints dos serviços desse ambiente. O perfil não fornece esses valores automaticamente.

O administrador de teste não é criado fora de `dev`, nem quando `prod` ou `production` estão ativos junto dele. Trocar o perfil não remove uma conta já criada: use bancos separados para desenvolvimento e produção.

## 7. Testes e build

Executar testes:

```powershell
.\mvnw.cmd test
```

Os testes usam H2 em memória e a configuração de `src/test/resources/application.properties`, sem precisar de PostgreSQL, MailDev ou Ollama rodando.

Gerar o JAR, executando também os testes:

```powershell
.\mvnw.cmd clean package
java -jar target\api-0.0.1-SNAPSHOT.jar
```

O JAR exige os mesmos serviços e configurações da execução pelo Maven ou IntelliJ.

## 8. Uso diário e encerramento

Após reiniciar o computador, abra o Docker Desktop e execute:

```powershell
cd C:\projetos\ajudabem\api
docker compose up -d db maildev
.\mvnw.cmd spring-boot:run
```

Se usar a triagem, inicie também `ollama` e `ollama-pull`. Depois de puxar atualizações do código, reinicie a API para aplicar as mudanças e migrações.

Para parar a API, use `Ctrl+C` no terminal ou Stop no IntelliJ. Para parar os serviços auxiliares:

```powershell
docker compose stop
```

Para remover os containers preservando os volumes:

```powershell
docker compose down
```

O banco e o modelo ficam em volumes Docker e são reutilizados nos próximos inícios. **Não use `docker compose down -v` para uma parada normal**: essa opção remove os volumes do projeto, incluindo os dados do banco e o modelo baixado.

## 9. Problemas comuns

| Sintoma | O que verificar |
| --- | --- |
| `docker` não reconhecido | Confirme a instalação do Docker Desktop e abra um novo terminal. |
| Erro de conexão com `docker_engine` ou named pipe inexistente | Abra o Docker Desktop e aguarde o motor ficar pronto. Resolva eventuais solicitações de WSL ou reinicialização antes de repetir `docker info`. |
| `Connection to localhost:5432 refused` | Execute `docker compose up -d db`, confira `docker compose ps` e aguarde `healthy`. Verifique também `DB_HOST` e `DB_PORT`. |
| Falha de autenticação no PostgreSQL | Confira as credenciais da API e do banco. Variáveis novas não alteram as credenciais de um volume já inicializado. |
| Falha de envio de e-mail para `localhost:1025` | Inicie `maildev`, confira as portas e abra a interface na porta 1080. |
| Falha em `http://localhost:11434/api/chat` | Inicie `ollama` e `ollama-pull`, aguarde o modelo e confira `docker compose exec ollama ollama list`. A API pode continuar rodando enquanto a triagem aguarda. |
| Porta 8080 ocupada | Pare a outra execução da API ou defina `SERVER_PORT` com uma porta livre. |
| `JAVA_HOME` inválido ou erro de compilação por versão Java | Configure JDK 17 no terminal e no IntelliJ; confira `java -version`, `javac -version` e `.\mvnw.cmd -version`. |
| Admin local não disponível | Confirme o perfil `dev`, reinicie a API e verifique se já existe uma conta com o mesmo e-mail e outra senha ou permissão. |
| Aviso `spring.jpa.open-in-view` | Esse aviso não impede a inicialização da API. |

Para consultar os logs dos serviços:

```powershell
docker compose logs --tail 100 db maildev ollama
```
