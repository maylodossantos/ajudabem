# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

AjudaBem API — backend for a TCC (thesis) app connecting NGOs, volunteers, and people needing assistance. Spring Boot 3.4.5, Java 17, Maven.

## Commands

Maven wrapper (`mvnw.cmd` on Windows, `mvnw` on Unix). `JAVA_HOME` is often not set in this environment — point it at an installed JDK 17 first, e.g.:
```
$env:JAVA_HOME = "C:\Users\Maylo\.jdks\ms-17.0.20.1"
```

- Start local Postgres: `docker compose up -d db` (required before `spring-boot:run`; not required for `test`, see Persistence below)
- Start local fake SMTP (MailDev, for the forgot-password email): `docker compose up -d maildev` — web inbox at `http://localhost:1080`, SMTP at `localhost:1025` (both are `UserService`'s dev-time defaults, see application.properties)
- Local LLM for the risk triage of assisted people (optional): install Ollama and run `ollama pull qwen2.5:3b` once; the API calls it at `http://localhost:11434` (`OLLAMA_URL`/`OLLAMA_MODEL`). People are saved with `riskLevel = null` (pending) and a scheduled job (`RiskTriageService.triagePending`, every `TRIAGE_INTERVAL_MS`) classifies them; without Ollama they simply stay pending.
- Build: `./mvnw.cmd compile`
- Run: `./mvnw.cmd spring-boot:run`
- Test: `./mvnw.cmd test`
- Single test: `./mvnw.cmd test -Dtest=ClassName#methodName`
- Package: `./mvnw.cmd package`

Tests are a mix of Mockito unit tests for services (which mock `CurrentUserService`, so they can't catch auth wiring bugs) and `@SpringBootTest` + MockMvc integration tests that go through the real JWT → `SecurityFilter` → controller chain (`CurrentUserResolutionTest`, `NewsAuthorizationIntegrationTest`). Anything touching auth or roles needs an integration test, not just a mocked one.

## Architecture

- **Layering**: `Controller → Service → Repository (Spring Data JPA) → Entity`, with MapStruct interfaces in `mappers/` doing all DTO↔entity conversion. Controllers hold no business logic — each endpoint method calls one service method and wraps the result in `ResponseEntity`.
- **Soft delete only**: every entity extends `domains/EntityBase.java` (`id`, `createdAt`/`updatedAt` auto-set via `@PrePersist`/`@PreUpdate`, plus `deleted`/`deletedAt` + a `softDelete()` helper). "Deleting" a row always means calling `softDelete()` then `repository.save(...)` — never `repository.delete(...)`.
- **DTOs**: Java records under `dto/<resource>/`, one file per DTO (`XRequestDTO`, `XResponseDTO`). Update endpoints use MapStruct's `@BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)` (see `UserMapper`, `AssistedPersonMapper`) so a `PUT` body only overwrites fields that are non-null — this is the partial-update convention; don't add `@NotNull`/`@NotBlank` to fields on request DTOs used for partial updates, or you'll break that.
- **Auth**: stateless JWT only (`infra/security/`). `SecurityFilter` reads the `Authorization: Bearer` header and validates it via `TokenService` (HMAC256, `com.auth0:java-jwt`), then builds the `Authentication` with the **email as principal** (not the `User` entity — `CurrentUserService` looks the user back up via `Authentication#getName()`, which only yields the email that way) and `ROLE_<UserRole>` as authority. Public endpoints (`SecurityConfig`): `POST /auth/login|register|forgot-password|verify-code|reset-password`, `GET /news` and `GET /news/**`, and Swagger; everything else requires a valid token. `CustomAuthenticationEntryPoint` returns a JSON `ErrorResponseDTO` with 401 for missing/invalid tokens. Spring's `UserDetailsServiceAutoConfiguration` is excluded in `ApiApplication` since nothing uses it.
- **User CPF / birth date**: required on register, optional on `PUT /user/me`. `@ValidCpf` (`infra/validation/`) checks the verification digits and accepts masked or plain input; `UserService` stores only the 11 digits and enforces uniqueness (`CpfAlreadyExistsException`, 409), so the mapper ignores `cpf`.
- **Roles** (`ADMIN`, `USER`, `USER_ONG`): registration always creates `USER`; other roles are assigned directly in the database. Role checks live in the service layer, not in `SecurityConfig` — e.g. `NewsService.requirePublisherRole` lets only `ADMIN` create/update/delete news and throws `ForbiddenActionException` (403) otherwise. Reading news is public. Assisted people by id: only the author may `PUT`/`DELETE`; the author, `ADMIN` and `USER_ONG` may `GET` (403 otherwise); `GET /assisted-person` lists only the token user's own registrations.
- **Error handling** is centralized in `infra/RestExceptionHandler.java` (`@ControllerAdvice`):
  - Domain exceptions live flat in `exceptions/` — one class per case, extends `RuntimeException`, single `String message` constructor (e.g. `UserNotFoundException`, `EmailAlreadyExistsException`). New cases get their own exception class, added to the `@ExceptionHandler({...})` list for its HTTP status in `RestExceptionHandler` (handlers are grouped by status and all build the body via `ErrorResponseDTO.of(status, message)`), not a bare `RuntimeException` (those fall through to a generic 500).
  - Services look entities up through one private helper each (`findNews`, `findAssistedPerson`, `findUserByEmail`) that throws the matching not-found exception — reuse it instead of repeating `findById(...).orElseThrow(...)`.
  - Exception messages and all other backend-internal strings are in **English**, matching the rest of the codebase.
  - Bean Validation (`@Valid` on `@RequestBody` params + `jakarta.validation.constraints` on the DTO record components) drives request validation. Validation failures use a different shape than other errors — `{status, message: "Erro de validação", errors: {field: message}}` (`ValidationErrorResponseDTO`, built by overriding `handleMethodArgumentNotValid`). The `errors` map's field messages are in **Portuguese** (user-facing); everything else stays in English.
- **Persistence**: PostgreSQL, run locally via `docker-compose.yml` (service `db`, default db/user/password all `ajudabem`, port 5432 — overridable via `DB_HOST`/`DB_PORT`/`DB_NAME`/`DB_USER`/`DB_PASSWORD` env vars, see `application.properties`). Schema is owned by **Flyway** migrations under `src/main/resources/db/migration/` (`V1`–`V5` so far) — `spring.jpa.hibernate.ddl-auto=validate`, so Hibernate only checks the entities match the migrated schema and never generates DDL itself. Adding/changing a JPA entity field requires a new `V<n>__description.sql` migration file (never edit an already-applied one) that keeps the table in sync, or the app fails to start with a schema validation error. Tests use a separate `src/test/resources/application.properties` pointing at H2 in-memory with `spring.flyway.enabled=false` and `ddl-auto=create-drop`, so `./mvnw.cmd test` needs no Docker/Postgres running.
- **CORS** origins come from `api.cors.allowed-origins` (env var `CORS_ALLOWED_ORIGINS`, comma-separated, default `http://localhost:4200`). To test the Flutter web build from a phone on the same Wi-Fi, add `http://<machine LAN IP>:4200` there — the LAN IP changes between networks, so re-check it with `ipconfig` when the phone can't reach the API.
- Package root `com.ajudabem.api` is organized by technical layer (`controllers/`, `services/<resource>/`, `repositories/`, `domains/<resource>/`, `dto/<resource>/`, `mappers/`, `exceptions/`, `infra/`), not by feature module — a single feature's code is spread across all of these.
