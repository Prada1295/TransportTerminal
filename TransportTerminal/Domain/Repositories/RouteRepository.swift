//
//  RouteRepository.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//
import Foundation

public protocol RouteRepository {
    func getById(_ id: UUID) async throws -> Route?
    func getAll() async throws -> [Route]
    func save(_ route: Route) async throws
}
