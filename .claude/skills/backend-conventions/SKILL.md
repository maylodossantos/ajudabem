---
name: backend-conventions
description: Conventions for adding or editing REST endpoints, services, entities, DTOs, or exceptions in the AjudaBem Spring Boot API. Use this whenever creating a new resource/controller/service, adding a delete endpoint, throwing an error from a service, adding request validation, or touching anything under src/main/java/com/ajudabem/api/ — even if the user just says "add an endpoint for X" or "handle this error" without mentioning conventions explicitly. These rules were deliberately chosen for this project and diverging from them (generic RuntimeException, hard deletes, English validation messages, etc.) is a bug, not a style choice.
---

# AjudaBem backend conventions

This project has a small, consistent set of rules for how errors, deletes, and validation work across every resource. They exist so the API behaves the same way for News, AssistedPerson, User, and whatever gets added next — a frontend/mobile client should never have to special-case one resource's error shape. Follow them for every new endpoint, not just the ones that already have them.

For general architecture (layering, package layout, auth flow, persistence) see `CLAUDE.md` at the repo root — this skill is the prescriptive checklist for the error/validation/delete layer specifically.

## 1. Delete = soft delete, always

Every entity extends `domains/EntityBase.java`, which already has `deleted`, `deletedAt`, and a `softDelete()` helper. A delete endpoint never calls `repository.delete(...)`. It looks up the entity (throwing the resource's not-found exception if missing), calls `softDelete()`, and saves:

```java
public void deleteNews(Long id) {
    News news = repository.findById(id)
            .orElseThrow(() -> new NewsNotFoundException("News is not exists"));

    news.softDelete();
    repository.save(news);
}
```

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

`infra/RestExceptionHandler.java` (`@ControllerAdvice`) is the single place that turns exceptions into HTTP responses. Adding an exception class without adding a matching `@ExceptionHandler` there means it still 500s. The handler returns `ErrorResponseDTO(message, status, timestamp)` with the status that matches the failure's meaning:

| Situation | HTTP status |
|---|---|
| Resource doesn't exist (`findById` empty) | 404 `NOT_FOUND` |
| Resource already exists / already in that state (duplicate email, already deleted) | 409 `CONFLICT` |
| Auth failure (bad password, bad/expired token) | 401 `UNAUTHORIZED` |

```java
@ExceptionHandler(AssistedPersonNotFoundException.class)
public ResponseEntity<ErrorResponseDTO> assistedPersonNotFoundHandler(AssistedPersonNotFoundException exception) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponseDTO(
                    exception.getMessage(),
                    HttpStatus.NOT_FOUND.value(),
                    LocalDateTime.now()
            ));
}
```

## 4. Exception messages are in English; validation messages are in Portuguese

These two message families serve different audiences, so they don't share a language:

- **Exception messages** (`ErrorResponseDTO.message`, the string passed to `new XException(...)`) are internal/developer-facing and follow the rest of the codebase's English convention (identifiers, comments, log text) — e.g. `"Email is using"`, `"User not found"`, `"Assisted person is not exists"`.
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

## 6. Auth: everything except login/register needs a token

`SecurityConfig` only `permitAll()`s `POST /auth/login` and `POST /auth/register`; any other new endpoint is authenticated by default without extra annotations. A missing or invalid token returns a JSON 401 via `CustomAuthenticationEntryPoint` — you get this for free, no per-controller work needed.

Note: role checks (`ADMIN`/`USER`/`USER_ONG`) are **not enforced anywhere yet** — don't write an endpoint assuming `hasRole(...)` restricts access, because nothing currently does that. If a task genuinely needs role-gating, that's a separate, deliberate piece of work (flag it rather than assuming it already works).

## 7. Tests: write them for new code, never fake a pass for existing ones

This project currently has almost no test coverage (`ApiApplicationTests` is just a context-load check), which makes it easy to break something silently while "fixing" something else — exactly the kind of regression tests exist to catch.

- **New service/controller logic** (a new endpoint, a new exception path, a new validation rule) should come with a unit test that exercises it — at minimum the happy path and the failure case that throws your new exception. Prefer a plain unit test on the service (mocking the repository) over a full `@SpringBootTest` unless you specifically need the Spring context or security filter chain wired up.
- **When editing existing code**, run the existing suite (`./mvnw.cmd test`, or `./mvnw.cmd test -Dtest=ClassName#methodName` for one test) before calling the change done. If a test fails, that's signal the change affected real behavior — go find out why and fix the actual code or the test's expectation to match genuinely intended behavior. Never make a failing test pass by weakening or deleting its assertions, adding `@Disabled`, or loosening what it checks just to get green — that turns the test into a lie and defeats the point of having it. If a test's expectation is genuinely outdated because the requirement changed, say so explicitly rather than silently editing it away.

## Checklist for a new resource

When adding a new resource end-to-end (entity, controller, service, DTOs):

- [ ] Entity extends `EntityBase`
- [ ] Request DTOs: `@NotBlank`/`@NotNull` + `@Size`/etc. for create; only null-tolerant constraints (`@Size`, no `@NotNull`/`@NotBlank`) for partial-update DTOs
- [ ] Controller: `@Valid @RequestBody` on create/update; delete endpoint calls a service method, never the repository directly
- [ ] Service: dedicated exception(s) for each failure case, thrown from `com.ajudabem.api.exceptions`; delete = `softDelete()` + `save(...)`
- [ ] `RestExceptionHandler`: one `@ExceptionHandler` per new exception class, correct status code
- [ ] Exception message text in English; validation constraint `message = "..."` in Portuguese
- [ ] Unit test(s) covering the new logic (happy path + at least one failure case)
- [ ] If this change touched existing code, ran `./mvnw.cmd test` and got a genuine pass — not an edited/disabled assertion
