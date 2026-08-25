//
//  InMemoryRouteRepository.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 25/08/26.
//

import Foundation

public actor InMemoryRouteRepository: RouteRepository {
    private var routes: [Route]

    public init(routes: [Route] = []) {
        self.routes = routes
    }

    public func getById(_ id: UUID) async throws -> Route? {
        routes.first { $0.id == id }
    }

    public func getAll() async throws -> [Route] {
        routes
    }

    public func save(_ route: Route) async throws {
        routes.append(route)
    }
}
