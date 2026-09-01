# Transport Terminal

An iOS application prototype for managing and monitoring operational activities inside a transportation terminal.

The project is being developed as a portfolio project to demonstrate iOS development practices, Clean Architecture, MVVM, dependency injection, asynchronous operations, repository abstraction, and automated testing using Swift and SwiftUI.

---

## Overview

Transport Terminal is an operational management application designed around the daily activities of a transportation terminal.

The current version focuses on vehicle management and terminal movements, providing a foundation that can evolve into a broader operational management system.

The application is currently using in-memory repositories and seeded data while the domain and presentation layers are being developed.

Right now the app is still in an early stage, so it's using in-memory data just to test things out. Later on, I plan to connect it to a real API and an external database, so the app can actually save data properly and be more scalable. That should help turn this into a more solid solution for companies in this industry.

---

## Current Features

### Operational Dashboard

The Dashboard provides an overview of the current terminal operation.

Currently implemented:

- Vehicles inside the terminal
- Vehicle operational status
- Basic operational metrics
- Active dispatches UI prototype
- Quick actions
- Vehicle navigation

### Vehicle Details

Users can select a vehicle from the Dashboard and access its details.

Currently displayed information includes:

- License plate
- Vehicle type
- Capacity
- Vehicle status
- Associated company

### Vehicle Entry

The application currently supports registering a vehicle entry into the terminal.

The flow includes:

1. Selecting an available vehicle
2. Confirming the operation
3. Registering the vehicle entry
4. Creating a vehicle movement
5. Updating the vehicle status to `insideTerminal`

Business rules are handled by the domain layer rather than the SwiftUI views.

---

## Architecture

## Architecture

The project follows a Clean Architecture approach combined with MVVM for the presentation layer.

The main goal is to keep business rules independent from the UI and data implementation, making the application easier to test, maintain, and evolve.

### Architectural Overview

┌─────────────────────────────────────────────┐
│                 Presentation                │
│                                             │
│  SwiftUI Views                              │
│       ↓                                     │
│  ViewModels                                 │
└──────────────────────┬──────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────┐
│                   Domain                    │
│                                             │
│  Use Cases                                  │
│       ↓                                     │
│  Repository Protocols                       │
│       ↓                                     │
│  Entities / Business Rules                  │
└──────────────────────┬──────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────┐
│                    Data                     │
│                                             │
│  Repository Implementations                 │
│       ↓                                     │
│  In-Memory Data / Seed Data                 │
└─────────────────────────────────────────────┘