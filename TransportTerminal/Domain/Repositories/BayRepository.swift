//
//  BayRepository.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 24/08/26.
//

import Foundation

public protocol BayRepository {
    func getById(_ id: UUID) async throws -> Bay?
    func getAll() async throws -> [Bay]
    func save(_ bay: Bay) async throws
}
