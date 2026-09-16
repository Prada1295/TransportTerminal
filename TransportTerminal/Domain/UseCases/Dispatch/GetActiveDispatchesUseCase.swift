//
//  GetActiveDispatchesUseCase.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 15/09/26.
//
import Foundation

public protocol GetActiveDispatchesUseCase {
    func execute() async throws -> [Dispatch]
}

public final class GetActiveDispatches: GetActiveDispatchesUseCase {

    private let dispatchRepository: DispatchRepository

    public init(
        dispatchRepository: DispatchRepository
    ) {
        self.dispatchRepository = dispatchRepository
    }

    public func execute() async throws -> [Dispatch] {
        try await dispatchRepository.getActiveDispatches()
    }
}
