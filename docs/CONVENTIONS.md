# 02 — Conventions

**Last verified: 2026-09-29**

## Naming

- **UseCase protocols:** `VerbNounUseCase` — e.g. `RegisterVehicleEntryUseCase`.
- **UseCase concrete types:** `Default<UseCaseName>` — e.g.
  `DefaultRegisterVehicleEntryUseCase`. *(Not yet applied consistently; see
  `04-known-issues.md`.)*
- **Repository protocols:** `<Entity>Repository`.
- **Repository implementations (in-memory):** `InMemory<Entity>Repository`.
- **Repository implementations (future API):** `API<Entity>Repository`.
- **DTOs (future):** `<Entity>DTO`.
- **Mappers (future):** `<Entity>Mapper`.
- **Errors:** single enum per bounded context — currently `TerminalError`.

## File organization

- One public type per file.
- File name matches the primary type it declares.
- UseCases are grouped by feature in subfolders of `Domain/UseCases/`
  (e.g. `Vehicle/`, `Dispatch/`, `Bays/`, `Routes/`, `VehicleMovement/`).
- Presentation features are grouped by screen in subfolders of `Presentation/`.

## Visibility

- `public` only when a symbol crosses a layer boundary.
- Internal by default elsewhere. Seed data and in-memory repositories should
  probably be `internal` (they are implementation details) — see `04-known-issues.md`.

## Concurrency

- **Repositories with mutable state are `actor`.** Prevents data races when
  multiple UseCases hit the same store concurrently.
- **ViewModels are `@MainActor @Observable`.**
- **UseCase methods are `async throws`** when they need to cross an async boundary.

## Enums

- Domain enums live in `Domain/Entities/` alongside the entities they relate to.
- Domain enums are `String`-backed, and should be `Codable, Equatable` uniformly
  (see `04-known-issues.md` for inconsistencies).

## Errors

- All domain errors are cases of a single `TerminalError` enum.
- `TerminalError` is `Error` and `Equatable`.
- **Never use a `default` clause when switching on `TerminalError`** — exhaustive
  switches force you to handle every case when the enum grows.

## Fake vs real

- The current Data layer is **in-memory fakes by design.** This is not a
  placeholder to be replaced "as soon as possible" — it is a deliberate
  architectural choice to develop the entire app before the backend exists.
- When the backend arrives, only `Data/` and `App/DependencyContainer.swift`
  change. Domain, Presentation, and App (except the container) stay frozen.
- Do **not** suggest "connecting this to a real backend" as if it were a pending
  task — it is already planned and documented in `05-roadmap.md`.

## Last verified rule

Every file in this folder ends with `Last verified: YYYY-MM-DD`. Update it every
time you meaningfully change a rule in that file. If the date is stale, treat the
file with suspicion.
