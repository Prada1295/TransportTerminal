//
//  GetActiveDispatchDetailsUseCase.swift
//  TransportTerminal
//
//  Created by Codex on 3/10/26.
//

import Foundation

public protocol GetActiveDispatchDetailsUseCase {
    func execute() async throws -> [DispatchDetailsResult]
}

public final class GetActiveDispatchDetails: GetActiveDispatchDetailsUseCase {

    private let dispatchRepository: DispatchRepository
    private let vehicleRepository: VehicleRepository
    private let routeRepository: RouteRepository
    private let bayRepository: BayRepository

    public init(
        dispatchRepository: DispatchRepository,
        vehicleRepository: VehicleRepository,
        routeRepository: RouteRepository,
        bayRepository: BayRepository
    ) {
        self.dispatchRepository = dispatchRepository
        self.vehicleRepository = vehicleRepository
        self.routeRepository = routeRepository
        self.bayRepository = bayRepository
    }

    public func execute() async throws -> [DispatchDetailsResult] {
        let dispatches = try await dispatchRepository.getActiveDispatches()

        var details: [DispatchDetailsResult] = []
        details.reserveCapacity(dispatches.count)

        for dispatch in dispatches {
            details.append(
                try await makeDetails(for: dispatch)
            )
        }

        return details
    }

    private func makeDetails(
        for dispatch: Dispatch
    ) async throws -> DispatchDetailsResult {

        guard let vehicle = try await vehicleRepository.getById(dispatch.vehicleId) else {
            throw TerminalError.vehicleNotFound
        }

        guard let route = try await routeRepository.getById(dispatch.routeId) else {
            throw TerminalError.routeNotFound
        }

        guard let bay = try await bayRepository.getById(dispatch.bayId) else {
            throw TerminalError.bayNotFound
        }

        return DispatchDetailsResult(
            id: dispatch.id,
            vehicleId: vehicle.id,
            vehiclePlate: vehicle.plate,
            vehicleType: vehicle.type,
            routeId: route.id,
            routeOrigin: route.origin,
            routeDestination: route.destination,
            bayId: bay.id,
            bayCode: bay.code,
            scheduledDeparture: dispatch.scheduledDeparture,
            actualDeparture: dispatch.actualDeparture,
            status: dispatch.status
        )
    }
}
