# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

AjudaBem API — backend for a TCC (thesis) app connecting NGOs, volunteers, and people needing assistance. Spring Boot 3.4.5, Java 17, Maven.

## Commands

Maven wrapper (`mvnw.cmd` on Windows, `mvnw` on Unix). `JAVA_HOME` is often not set in this environment — point it at an installed JDK 17 first, e.g.:
```
$env:JAVA_HOME = "C:\Users\Maylo\.jdks\ms-17.0.20.1"
```

- Build: `./mvnw.cmd compile`
- Run: `./mvnw.cmd spring-boot:run`
- Test: `./mvnw.cmd test`
- Single test: `./mvnw.cmd test -Dtest=ClassName#methodName`
- Package: `./mvnw.cmd package`

Only `ApiApplicationTests` (a default context-load test) exists — there is no feature-level test suite yet.

## Architecture

- **Layering**: `Controller → Service → Repository (Spring Data JPA) → Entity`, with MapStruct interfaces in `mappers/` doing all DTO↔entity conversion. Controllers hold no business logic — each endpoint method calls one service method and wraps the result in `ResponseEntity`.
- **Soft delete only**: every entity extends `domains/EntityBase.java` (`id`, `createdAt`/`updatedAt` auto-set via `@PrePersist`/`@PreUpdate`, plus `deleted`/`deletedAt` + a `softDelete()` helper). "Deleting" a row always means calling `softDelete()` then `repository.save(...)` — never `repository.delete(...)`.
- **DTOs**: Java records under `dto/<resource>/`, one file per DTO (`XRequestDTO`, `XResponseDTO`). Update endpoints use MapStruct's `@BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)` (see `UserMapper`, `AssistedPersonMapper`) so a `PUT` body only overwrites fields that are non-null — this is the partial-update convention; don't add `@NotNull`/`@NotBlank` to fields on request DTOs used for partial updates, or you'll break that.
- **Auth**: stateless JWT only (`infra/security/`). `SecurityFilter` reads the `Authorization: Bearer` header and validates it via `TokenService` (HMAC256, `com.auth0:java-jwt`), then manually builds the `Authentication`. Only `POST /auth/login` and `POST /auth/register` are `permitAll()` (`SecurityConfig`); everything else requires a valid token. `CustomAuthenticationEntryPoint` returns a JSON `ErrorResponseDTO` with 401 for missing/invalid tokens.
- **Roles are not enforced yet**: `UserRole` (`ADMIN`, `USER`, `USER_ONG`) exists on `User`, but `SecurityFilterChain` only checks `.authenticated()`, and `SecurityFilter` grants every authenticated request `ROLE_USER` regardless of the user's actual role. Don't assume role-based restrictions work anywhere in the API until this is wired up.
- **Error handling** is centralized in `infra/RestExceptionHandler.java` (`@ControllerAdvice`):
  - Domain exceptions live flat in `exceptions/` — one class per case, extends `RuntimeException`, single `String message` constructor (e.g. `UserNotFoundException`, `EmailAlreadyExistsException`). New "not found"/"conflict" cases should get their own exception class + a handler here, not a bare `RuntimeException` (those fall through to a generic 500).
  - Exception messages and all other backend-internal strings are in **English**, matching the rest of the codebase.
  - Bean Validation (`@Valid` on `@RequestBody` params + `jakarta.validation.constraints` on the DTO record components) drives request validation. Validation failures use a different shape than other errors — `{status, message: "Erro de validação", errors: {field: message}}` (`ValidationErrorResponseDTO`, built by overriding `handleMethodArgumentNotValid`). The `errors` map's field messages are in **Portuguese** (user-facing); everything else stays in English.
- **Persistence**: H2 in-memory (`spring.datasource.url=jdbc:h2:mem:testdb`), wiped on every restart. `src/main/resources/data.sql` seeds it; `spring.jpa.defer-datasource-initialization=true` makes Hibernate create the schema before `data.sql` runs. No persistent/prod datasource is configured.
- **CORS** is hardcoded to `http://localhost:4200` in `infra/cors/CorsConfig.java` — update if the frontend origin/port changes.
- Package root `com.ajudabem.api` is organized by technical layer (`controllers/`, `services/<resource>/`, `repositories/`, `domains/<resource>/`, `dto/<resource>/`, `mappers/`, `exceptions/`, `infra/`), not by feature module — a single feature's code is spread across all of these.
