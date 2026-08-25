//
//  CreateDispatchUseCase.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 24/08/26.
//

import Foundation

public protocol CreateDispatchUseCase {
    func execute(
        vehicleId: UUID,
        routeId: UUID,
        bayId: UUID,
        scheduledDeparture: Date
    ) async throws -> CreateDispatchResult
}

public final class CreateDispatch: CreateDispatchUseCase {
    private let vehicleRepository: VehicleRepository
    private let routeRepository: RouteRepository
    private let bayRepository: BayRepository
    private let dispatchRepository: DispatchRepository

    public init(
        vehicleRepository: VehicleRepository,
        routeRepository: RouteRepository,
        bayRepository: BayRepository,
        dispatchRepository: DispatchRepository
    ) {
        self.vehicleRepository = vehicleRepository
        self.routeRepository = routeRepository
        self.bayRepository = bayRepository
        self.dispatchRepository = dispatchRepository
    }

    public func execute(
        vehicleId: UUID,
        routeId: UUID,
        bayId: UUID,
        scheduledDeparture: Date
    ) async throws -> CreateDispatchResult {
        guard let vehicle = try await vehicleRepository.getById(vehicleId) else {
            throw TerminalError.vehicleNotFound
        }

        guard vehicle.status != .maintenance else {
            throw TerminalError.vehicleInMaintenance
        }

        guard vehicle.status == .insideTerminal else {
            throw TerminalError.vehicleNotInsideTerminal
        }

        guard let route = try await routeRepository.getById(routeId) else {
            throw TerminalError.routeNotFound
        }

        guard route.isActive else {
            throw TerminalError.routeInactive
        }

        guard let bay = try await bayRepository.getById(bayId) else {
            throw TerminalError.bayNotFound
        }

        guard bay.active else {
            throw TerminalError.bayInactive
        }

        let activeDispatches = try await dispatchRepository.getActiveDispatches()

        guard !activeDispatches.contains(where: { $0.vehicleId == vehicleId }) else {
            throw TerminalError.vehicleAlreadyHasActiveDispatch
        }

        guard !activeDispatches.contains(where: { $0.bayId == bayId }) else {
            throw TerminalError.bayAlreadyHasActiveDispatch
        }

        let dispatch = Dispatch(
            id: UUID(),
            vehicleId: vehicleId,
            routeId: routeId,
            bayId: bayId,
            scheduledDeparture: scheduledDeparture,
            status: .scheduled
        )

        try await dispatchRepository.save(dispatch)

        return CreateDispatchResult(
            dispatchId: dispatch.id,
            vehicleId: dispatch.vehicleId,
            routeId: dispatch.routeId,
            bayId: dispatch.bayId,
            scheduledDeparture: dispatch.scheduledDeparture,
            status: dispatch.status
        )
    }
}
