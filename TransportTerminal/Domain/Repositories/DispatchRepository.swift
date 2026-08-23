//
//  DispatchRepository.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//
import Foundation

public protocol DispatchRepository {
    func save(_ dispatch: Dispatch) async throws
    func getById(_ id: UUID) async throws -> Dispatch?
    func getActiveDispatches() async throws -> [Dispatch]
}
