//
//  InMemoryBayRepository.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 25/08/26.
//

import Foundation

public actor InMemoryBayRepository: BayRepository {
    private var bays: [Bay]

    public init(bays: [Bay] = []) {
        self.bays = bays
    }

    public func getById(_ id: UUID) async throws -> Bay? {
        bays.first { $0.id == id }
    }

    public func getAll() async throws -> [Bay] {
        bays
    }

    public func save(_ bay: Bay) async throws {
        bays.append(bay)
    }
}
