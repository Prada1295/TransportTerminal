//
//  CancelDispatchUseCase.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 25/08/26.
//

import Foundation

public protocol CancelDispatchUseCase {
    func execute(dispatchId: UUID) async throws -> CancelDispatchResult
}

public final class CancelDispatch: CancelDispatchUseCase {
    private let dispatchRepository: DispatchRepository

    public init(dispatchRepository: DispatchRepository) {
        self.dispatchRepository = dispatchRepository
    }

    public func execute(dispatchId: UUID) async throws -> CancelDispatchResult {
        guard var dispatch = try await dispatchRepository.getById(dispatchId) else {
            throw TerminalError.dispatchNotFound
        }

        guard dispatch.status != .cancelled else {
            throw TerminalError.dispatchAlreadyCancelled
        }

        guard dispatch.status != .departed else {
            throw TerminalError.dispatchAlreadyDeparted
        }

        dispatch.status = .cancelled
        try await dispatchRepository.update(dispatch)

        return CancelDispatchResult(
            dispatchId: dispatch.id,
            vehicleId: dispatch.vehicleId,
            routeId: dispatch.routeId,
            bayId: dispatch.bayId,
            status: dispatch.status
        )
    }
}
