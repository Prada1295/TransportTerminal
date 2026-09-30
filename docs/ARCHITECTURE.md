# 01 — Architecture

**Last verified: 2026-09-29**

## Style

- **Clean Architecture** as the overarching layering strategy.
- **MVVM** as the presentation-layer pattern, *inside* the Presentation layer.

> These are not the same kind of thing. Clean Architecture defines *where code
> lives and which direction dependencies point*. MVVM defines *how the UI talks
> to logic*. MVVM lives inside Presentation; it does not replace Clean Architecture.

## Layers


## Dependency direction (the rule)


- **Domain knows nothing.** It does not import SwiftUI, does not know HTTP, does
  not know JSON, does not know persistence.
- **Presentation depends on Domain.** ViewModels consume UseCase protocols.
  Views consume ViewModels.
- **Data depends on Domain.** Data implements Domain's repository protocols.
- **App wires everything.** It is the only layer that knows concrete types.

**Any dependency that violates this direction is a bug.** Examples:

- A ViewModel importing a Repository → violation. ViewModels only see UseCases.
- A Domain entity conforming to `Codable` for JSON reasons → violation. DTOs live
  in Data.
- A UseCase importing SwiftUI → violation. Ever.

## What each layer contains

| Layer | Contains | Never contains |
|---|---|---|
| Domain | Entities, enums, errors, repository protocols, UseCases, UseCase Results | UI, HTTP, JSON, `Codable`, SwiftUI, persistence |
| Data | Repository implementations, DTOs (`Codable`), mappers, seed data | Business rules, UI |
| Presentation | SwiftUI Views, ViewModels | Repositories, business rules, HTTP |
| App | DI container, `@main` | Business rules, UI, persistence |

## MVVM rules (inside Presentation)

- **ViewModel is `@MainActor @Observable`.**
- ViewModel exposes `private(set)` state and `async` methods.
- ViewModel takes **UseCase protocols**, never concrete implementations, never
  repositories.
- ViewModel contains **no business rules.** If a rule decides *what should happen*,
  it belongs in a UseCase.
- Views are dumb: they render state and dispatch user actions.

## Composition root

`App/DependencyContainer.swift` is the **only** place in the codebase that knows
concrete types (`InMemoryVehicleRepository`, etc.). Everything else depends on
protocols. This is what makes the fake → real swap (when the backend arrives)
a one-file change.

## The "results" vs "DTOs" distinction

Two different concepts that look similar:

- **UseCase Results** (e.g. `VehicleEntryResult`, `CancelDispatchResult`) live in
  `Domain/Results/`. They are what a UseCase returns to Presentation. No `Codable`,
  no serialization.
- **DTOs** (when the backend arrives) will live in `Data/DTOs/`. They are
  `Codable`, they represent JSON, and they are mapped to Domain entities at the
  repository boundary.

**Never mix them.** A `Result` is not a `DTO`. A `DTO` never crosses into Domain.
