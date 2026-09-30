# 03 — Domain

**Last verified: 2026-09-29**

## Entities

| Entity | Fields | Notes |
|---|---|---|
| `Vehicle` | `id`, `plate`, `companyId`, `type`, `capacity`, `status` | `status` is mutable. |
| `Company` | `id`, `name`, `nit`, `isActive` | |
| `Route` | `id`, `origin`, `destination`, `estimatedMinutes`, `isActive` | |
| `Bay` | `id`, `code`, `active` | |
| `Dispatch` | `id`, `vehicleId`, `routeId`, `bayId`, `scheduledDeparture`, `actualDeparture?`, `status` | `actualDeparture` and `status` are mutable. |
| `VehicleMovement` | `id`, `vehicleId`, `timestamp`, `type` | Immutable once created. |

## Enums

| Enum | Cases |
|---|---|
| `VehicleStatus` | `outsideTerminal`, `insideTerminal`, `dispatched`, `maintenance` |
| `VehicleType` | `bus`, `buseta`, `microbus`, `van`, `taxi` |
| `MovementType` | `entry`, `exit` |
| `DispatchStatus` | `scheduled`, `boarding`, `departed`, `cancelled`, `delayed` |

## Errors (`TerminalError`)

`vehicleNotFound`, `companyNotFound`, `companyInactive`, `vehicleAlreadyInside`,
`vehicleInMaintenance`, `vehicleNotInsideTerminal`, `routeNotFound`, `routeInactive`,
`bayNotFound`, `bayInactive`, `vehicleAlreadyHasActiveDispatch`,
`bayAlreadyHasActiveDispatch`, `dispatchNotFound`, `dispatchAlreadyCancelled`,
`dispatchAlreadyDeparted`.

## UseCases and their business rules

### `RegisterVehicleEntry`
1. Vehicle must exist.
2. Company must exist.
3. Company must be active.
4. Vehicle must not be in maintenance.
5. Vehicle must not already be inside the terminal.
6. Records an `entry` movement.
7. Sets vehicle status to `insideTerminal`.

### `RegisterVehicleExit`
1. Vehicle must exist.
2. Vehicle must not be in maintenance.
3. Vehicle must be inside the terminal.
4. Records an `exit` movement.
5. Sets vehicle status to `outsideTerminal`.

### `CreateDispatch`
1. Vehicle must exist, not be in maintenance, and be inside the terminal.
2. Route must exist and be active.
3. Bay must exist and be active.
4. Vehicle must not already have an active dispatch.
5. Bay must not already have an active dispatch.
6. Creates a dispatch in status `scheduled`.

### `ExecuteDispatch`
1. Dispatch must exist.
2. Dispatch must not be cancelled or already departed.
3. Delegates to `RegisterVehicleExit` for the vehicle side.
4. Sets dispatch status to `departed` and `actualDeparture` to the exit timestamp.

### `CancelDispatch`
1. Dispatch must exist.
2. Dispatch must not be cancelled or already departed.
3. Sets dispatch status to `cancelled`.

### `GetVehiclesInsideTerminal`
- Returns vehicles with status `insideTerminal`. No side effects.

### `GetActiveDispatches`
- Returns dispatches whose status is not `cancelled` and not `departed`.

### `GetVehicleDetails`
- Combines vehicle + company data for a detail view.

## Invariants

- A vehicle can have at most **one** active dispatch at a time.
- A bay can host at most **one** active dispatch at a time.
- A `Dispatch` represents a **plan**; a `VehicleMovement` represents a **fact**.
  A departure creates both.
- A vehicle's status and its movement history should always be consistent
  (see `04-known-issues.md` — this is not enforced atomically yet).

## Results

UseCase Results live in `Domain/Results/`. They are the output contract of a
UseCase, immutable and `Equatable`, and are consumed by ViewModels.

Current Results: `CancelDispatchResult`, `CreateDispatchResult`,
`ExecuteDispatchResult`, `VehicleEntryResult`, `VehicleExitResult`, `VehicleDetails`.
