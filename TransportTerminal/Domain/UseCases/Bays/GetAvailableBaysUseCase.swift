//
//  CreateDispatchUseCase.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 14/09/26.
//
import Foundation

public protocol GetAvailableBaysUseCase {
    func execute() async throws -> [Bay]
}

public final class GetAvailableBays: GetAvailableBaysUseCase {

    private let bayRepository: BayRepository
    private let dispatchRepository: DispatchRepository

    public init(
        bayRepository: BayRepository,
        dispatchRepository: DispatchRepository
    ) {
        self.bayRepository = bayRepository
        self.dispatchRepository = dispatchRepository
    }

    public func execute() async throws -> [Bay] {

        let bays = try await bayRepository.getAll()
        let activeDispatches = try await dispatchRepository.getActiveDispatches()

        let occupiedBayIDs = Set(
            activeDispatches.map { $0.bayId }
        )

        return bays.filter { bay in
            bay.active && !occupiedBayIDs.contains(bay.id)
        }
    }
}
