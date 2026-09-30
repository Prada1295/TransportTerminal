# Transport Terminal

An iOS application for managing and monitoring the daily operations of a ground passenger transport terminal.

Built as a portfolio project to demonstrate iOS development practices: Clean Architecture, MVVM, dependency injection, asynchronous operations, repository abstraction, and automated testing with Swift and SwiftUI.

---

## Overview

Transport Terminal is an operational management application designed around the daily activities of a transportation terminal.

The current version focuses on vehicle management and terminal movements, providing a foundation that can evolve into a broader operational management system.

The Data layer currently uses **in-memory repositories and seed data by design** — this allows the entire application to be developed, tested, and demonstrated before the backend exists. When the backend is ready, only the `Data` layer will change; the `Domain` and `Presentation` layers will remain untouched.

---

## Tech Stack

- **Language:** Swift 5.9+
- **UI:** SwiftUI
- **Concurrency:** `async`/`await`, `actor`, `@MainActor`
- **State:** Observation framework (`@Observable`)
- **Architecture:** Clean Architecture + MVVM
- **Persistence:** SwiftData (planned)
- **Backend:** ASP.NET Core + Entity Framework Core (planned)

---

## Architecture

The project follows **Clean Architecture**, with MVVM inside the Presentation layer.


- **Domain** — Entities, enums, errors, repository protocols, and use cases. No framework dependencies.
- **Data** — Repository implementations, DTOs, mappers, and seed data.
- **Presentation** — SwiftUI views and `@Observable` ViewModels.
- **App** — Dependency injection container (composition root) and `@main` entry point.

Dependencies point inward. The `Domain` layer knows nothing about UI, networking, or persistence.

For detailed architecture documentation, see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

---

## Current Features

### Operational Dashboard

Provides an overview of the current terminal operation:

- Vehicles inside the terminal
- Vehicles available for entry
- Vehicle operational status
- Active dispatches
- Bay occupancy count

### Vehicle Details

Select a vehicle from the Dashboard to view its details:

- License plate
- Vehicle type
- Capacity
- Operational status
- Associated company

### Vehicle Entry

Register a vehicle entry into the terminal:

1. Select an available vehicle
2. Confirm the operation
3. Register the vehicle entry
4. Create a vehicle movement
5. Update the vehicle status to `insideTerminal`

### Vehicle Exit

Register a vehicle exit from the terminal:

1. View the list of vehicles currently inside the terminal
2. Select a vehicle
3. Confirm the operation
4. Register the exit
5. Create a vehicle movement
6. Update the vehicle status to `outsideTerminal`

### Dispatches

Create, monitor, and execute vehicle dispatches:

- Create a dispatch linking a vehicle, route, and bay
- Cancel an active dispatch
- Execute a dispatch (registers the vehicle exit and marks the dispatch as departed)

---

## Business Rules

Business rules live in the **Domain** layer, not in SwiftUI views or ViewModels. Examples:

- A vehicle must not be in maintenance to enter or exit.
- A vehicle must be inside the terminal to be dispatched.
- A vehicle can have only one active dispatch at a time.
- A bay can host only one active dispatch at a time.
- Only active routes and active bays can be used for a dispatch.

---

