//
//  CreateDispatchUseCase.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 14/09/26.
//
import Foundation

public protocol ExecuteDispatchUseCase {
    func execute(dispatchId: UUID) async throws -> ExecuteDispatchResult
}

public final class ExecuteDispatch: ExecuteDispatchUseCase {

    private let dispatchRepository: DispatchRepository
    private let registerVehicleExit: RegisterVehicleExitUseCase

    public init(
        dispatchRepository: DispatchRepository,
        registerVehicleExit: RegisterVehicleExitUseCase
    ) {
        self.dispatchRepository = dispatchRepository
        self.registerVehicleExit = registerVehicleExit
    }

    public func execute(
        dispatchId: UUID
    ) async throws -> ExecuteDispatchResult {

        guard var dispatch = try await dispatchRepository.getById(dispatchId) else {
            throw TerminalError.dispatchNotFound
        }

        guard dispatch.status != .cancelled else {
            throw TerminalError.dispatchAlreadyCancelled
        }

        guard dispatch.status != .departed else {
            throw TerminalError.dispatchAlreadyDeparted
        }

        let exitResult = try await registerVehicleExit.execute(
            vehicleId: dispatch.vehicleId
        )

        dispatch.status = .departed
        dispatch.actualDeparture = exitResult.timestamp

        try await dispatchRepository.update(dispatch)

        return ExecuteDispatchResult(
            dispatchId: dispatch.id,
            vehicleId: dispatch.vehicleId,
            routeId: dispatch.routeId,
            bayId: dispatch.bayId,
            scheduledDeparture: dispatch.scheduledDeparture,
            actualDeparture: exitResult.timestamp,
            status: dispatch.status
        )
    }
}
