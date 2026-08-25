//
//  InMemoryDispatchRepository.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 25/08/26.
//

import Foundation

public actor InMemoryDispatchRepository: DispatchRepository {
    private var dispatches: [Dispatch]

    public init(dispatches: [Dispatch] = []) {
        self.dispatches = dispatches
    }

    public func save(_ dispatch: Dispatch) async throws {
        dispatches.append(dispatch)
    }

    public func getById(_ id: UUID) async throws -> Dispatch? {
        dispatches.first { $0.id == id }
    }

    public func getActiveDispatches() async throws -> [Dispatch] {
        dispatches.filter { dispatch in
            dispatch.status != .cancelled && dispatch.status != .departed
        }
    }

    public func update(_ dispatch: Dispatch) async throws {
        guard let index = dispatches.firstIndex(where: { $0.id == dispatch.id }) else {
            return
        }

        dispatches[index] = dispatch
    }
}
