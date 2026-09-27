---
name: backend-conventions
description: Conventions for adding or editing REST endpoints, services, entities, DTOs, or exceptions in the AjudaBem Spring Boot API. Use this whenever creating a new resource/controller/service, adding a delete endpoint, throwing an error from a service, adding request validation, or touching anything under src/main/java/com/ajudabem/api/ — even if the user just says "add an endpoint for X" or "handle this error" without mentioning conventions explicitly. These rules were deliberately chosen for this project and diverging from them (generic RuntimeException, hard deletes, English validation messages, etc.) is a bug, not a style choice.
---

# AjudaBem backend conventions

This project has a small, consistent set of rules for how errors, deletes, and validation work across every resource. They exist so the API behaves the same way for News, AssistedPerson, User, and whatever gets added next — a frontend/mobile client should never have to special-case one resource's error shape. Follow them for every new endpoint, not just the ones that already have them.

For general architecture (layering, package layout, auth flow, persistence) see `CLAUDE.md` at the repo root — this skill is the prescriptive checklist for the error/validation/delete layer specifically.

## 1. Delete = soft delete, always

Every entity extends `domains/EntityBase.java`, which already has `deleted`, `deletedAt`, and a `softDelete()` helper, and is annotated `@SQLRestriction("deleted = false")` so soft-deleted rows disappear from every query. A delete endpoint never calls `repository.delete(...)`. It looks up the entity through the service's private lookup helper (which throws the resource's not-found exception), calls `softDelete()`, and saves:

```java
public void deleteNews(Long id) {
    News news = findNews(id);

    news.softDelete();
    repository.save(news);
}

private News findNews(Long id) {
    return repository.findById(id)
            .orElseThrow(() -> new NewsNotFoundException("News not found"));
}
```

Each service has exactly one such helper per entity it looks up (`findNews`, `findAssistedPerson`, `findUserByEmail`) — reuse it instead of repeating `findById(...).orElseThrow(...)` in every method. A new entity must also get `@SQLRestriction("deleted = false")`.

Watch out for the easy mistake here: calling `softDelete()` without `repository.save(...)` afterwards silently does nothing — the entity is only dirty in memory. This exact bug existed in `UserService.deleteMe()` before it was fixed; don't reintroduce it in a new service.

## 2. One exception class per error case — never a bare `RuntimeException`

When a service needs to signal "not found," "already exists," "already deleted," etc., create a dedicated exception in `com.ajudabem.api.exceptions` rather than throwing `new RuntimeException("...")`. A bare `RuntimeException` isn't caught by `RestExceptionHandler`, so it falls through to Spring Boot's default handler and becomes an opaque 500 — the client gets no usable error shape.

Every exception in this package follows the same minimal shape:

```java
package com.ajudabem.api.exceptions;

public class AssistedPersonNotFoundException extends RuntimeException {
    public AssistedPersonNotFoundException(String message) {
        super(message);
    }
}
```

Name it after the specific failure (`EmailAlreadyExistsException`, `AssistedPersonNotFoundException`), not something generic like `ServiceException`.

## 3. Every new exception needs a handler in `RestExceptionHandler`

`infra/RestExceptionHandler.java` (`@ControllerAdvice`) is the single place that turns exceptions into HTTP responses. Adding an exception class without registering it there means it still 500s. Handlers are **grouped by HTTP status**: one method per status, listing every exception class that maps to it, all building the body through the shared `error(...)` helper / `ErrorResponseDTO.of(status, message)`. To add an exception, add its class to the list of the matching status — don't write a new copy-pasted method:

| Situation | HTTP status | Handler |
|---|---|---|
| Resource doesn't exist (`findById` empty) | 404 `NOT_FOUND` | `notFoundHandler` |
| Resource already exists / already in that state (duplicate email, already deleted) | 409 `CONFLICT` | `conflictHandler` |
| Auth failure (bad password, bad/expired token or code) | 401 `UNAUTHORIZED` | `unauthorizedHandler` |
| Authenticated but not allowed (wrong role) | 403 `FORBIDDEN` | `forbiddenHandler` |
| Invalid request outside Bean Validation (passwords don't match) | 400 `BAD_REQUEST` | `badRequestHandler` |

```java
@ExceptionHandler({
        UserNotFoundException.class,
        AssistedPersonNotFoundException.class,
        NewsNotFoundException.class
})
public ResponseEntity<ErrorResponseDTO> notFoundHandler(RuntimeException exception) {
    return error(HttpStatus.NOT_FOUND, exception);
}
```

## 4. Exception messages are in English; validation messages are in Portuguese

These two message families serve different audiences, so they don't share a language:

- **Exception messages** (`ErrorResponseDTO.message`, the string passed to `new XException(...)`) are internal/developer-facing and follow the rest of the codebase's English convention (identifiers, comments, log text) — e.g. `"Email is using"`, `"User not found"`, `"Assisted person not found"`. The Flutter app maps statuses to its own Portuguese messages where the English text would reach the user (e.g. login 404/401).
- **Validation field messages** (the `errors` map described below) are shown directly to end users in the mobile app, so they're in Portuguese — e.g. `"Nome deve ter no máximo 100 caracteres"`.

If you're unsure which bucket a message falls into, ask: does this string ever reach the app's UI as-is? If yes, Portuguese; if it's just for debugging/logs/API consumers, English.

## 5. Request validation: Bean Validation, fixed error shape

Validate request DTOs with `@Valid` on the controller's `@RequestBody` parameter plus `jakarta.validation.constraints` annotations on the DTO record's components:

```java
public record NewsRequestDTO(
        @NotBlank(message = "Título é obrigatório")
        @Size(max = 150, message = "Título deve ter no máximo 150 caracteres")
        String title,
        ...
) { }
```

```java
@PostMapping
public ResponseEntity<NewsResponseDTO> createNews(@Valid @RequestBody NewsRequestDTO body) {
    return ResponseEntity.ok(newsService.createNews(body));
}
```

Validation failures use a different response shape than every other error — this is intentional, don't try to unify it with `ErrorResponseDTO`:

```json
{
  "status": 400,
  "message": "Erro de validação",
  "errors": {
    "name": "Nome deve ter no máximo 100 caracteres"
  }
}
```

This is already wired up once, centrally, in `RestExceptionHandler` (it overrides `handleMethodArgumentNotValid` and builds a `ValidationErrorResponseDTO`) — you don't need to touch that file to get this behavior, just add the `@Valid`/constraint annotations to the new DTO.

### Don't break partial updates with validation annotations

Update DTOs (the ones mapped with MapStruct's `@BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)`, e.g. `UpdateUserRequestDTO`, `AssistedPersonRequestDTO` on `PUT`) treat a missing/null field as "don't change this field," not "clear it." If you add `@NotNull` or `@NotBlank` to a field on one of these DTOs, a legitimate partial update that omits that field will now fail validation instead of leaving it untouched. Use null-tolerant constraints like `@Size(max = ...)` there — Bean Validation constraints (other than `@NotNull`) pass on `null` by design, so this combination is exactly what you want. Reserve `@NotBlank`/`@NotNull` for create-only DTOs (`RegisterRequestDTO`, `AssistedPersonRequestDTO` on create) where every field is required.

## 6. Auth: authenticated by default, roles checked in the service

`SecurityConfig` `permitAll()`s only the auth flow (`POST /auth/login|register|forgot-password|verify-code|reset-password`), public reads of news (`GET /news`, `GET /news/**`) and Swagger; any other new endpoint is authenticated by default without extra annotations. A missing or invalid token returns a JSON 401 via `CustomAuthenticationEntryPoint` — you get this for free. Making a new endpoint public is a deliberate change to that list.

`SecurityFilter` grants `ROLE_<UserRole>` and uses the user's **email** as the principal (`CurrentUserService.get()` depends on that). Role rules live in the service, next to the logic they protect, and throw `ForbiddenActionException` (403) — see `NewsService.requirePublisherRole` (only `ADMIN` writes news). Don't rely on `SecurityConfig` for role gating.

## 7. Tests: write them for new code, never fake a pass for existing ones

Services have Mockito unit tests, plus a few `@SpringBootTest` + MockMvc integration tests. The unit tests mock `CurrentUserService`, so they can't see auth wiring — a real 404-on-every-request bug in `SecurityFilter` went unnoticed until an integration test was added.

- **New service/controller logic** (a new endpoint, a new exception path, a new validation rule) should come with a unit test that exercises it — at minimum the happy path and the failure case that throws your new exception. Prefer a plain unit test on the service (mocking the repository).
- **Anything involving auth, roles or public/private access** also needs an integration test through the real JWT → `SecurityFilter` → controller chain (see `NewsAuthorizationIntegrationTest`, `CurrentUserResolutionTest`).
- **When editing existing code**, run the existing suite (`./mvnw.cmd test`, or `./mvnw.cmd test -Dtest=ClassName#methodName` for one test) before calling the change done. If a test fails, that's signal the change affected real behavior — go find out why and fix the actual code or the test's expectation to match genuinely intended behavior. Never make a failing test pass by weakening or deleting its assertions, adding `@Disabled`, or loosening what it checks just to get green — that turns the test into a lie and defeats the point of having it. If a test's expectation is genuinely outdated because the requirement changed, say so explicitly rather than silently editing it away.

## Checklist for a new resource

When adding a new resource end-to-end (entity, controller, service, DTOs):

- [ ] Entity extends `EntityBase` and has `@SQLRestriction("deleted = false")`
- [ ] Request DTOs: `@NotBlank`/`@NotNull` + `@Size`/etc. for create; only null-tolerant constraints (`@Size`, no `@NotNull`/`@NotBlank`) for partial-update DTOs
- [ ] Controller: `@Valid @RequestBody` on create/update; delete endpoint calls a service method, never the repository directly
- [ ] Service: dedicated exception(s) for each failure case, thrown from `com.ajudabem.api.exceptions`; one private `findX(id)` lookup helper; delete = `softDelete()` + `save(...)`; role rules throw `ForbiddenActionException`
- [ ] `RestExceptionHandler`: new exception class added to the handler list of its status code
- [ ] Exception message text in English; validation constraint `message = "..."` in Portuguese
- [ ] Unit test(s) covering the new logic (happy path + at least one failure case)
- [ ] If this change touched existing code, ran `./mvnw.cmd test` and got a genuine pass — not an edited/disabled assertion
