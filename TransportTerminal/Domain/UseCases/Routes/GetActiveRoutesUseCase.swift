//
//  CreateDispatchUseCase.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 14/09/26.
//
import Foundation

public protocol GetActiveRoutesUseCase {
    func execute() async throws -> [Route]
}

public final class GetActiveRoutes: GetActiveRoutesUseCase {

    private let routeRepository: RouteRepository

    public init(routeRepository: RouteRepository) {
        self.routeRepository = routeRepository
    }

    public func execute() async throws -> [Route] {
        let routes = try await routeRepository.getAll()

        return routes.filter { $0.isActive }
    }
}
