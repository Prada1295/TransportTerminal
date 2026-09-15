//
//  test.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 14/09/26.
//
import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct GetActiveRoutesUseCaseTests {

    @Test
    func executeWhenRepositoryIsEmptyReturnsEmptyList() async throws {

        let sut = makeSUT()

        let result = try await sut.execute()

        #expect(result.isEmpty)
    }

    @Test
    func executeWhenNoRoutesAreActiveReturnsEmptyList() async throws {

        let routes = [
            makeRoute(isActive: false),
            makeRoute(isActive: false)
        ]

        let sut = makeSUT(routes: routes)

        let result = try await sut.execute()

        #expect(result.isEmpty)
    }

    @Test
    func executeWhenRoutesAreActiveReturnsOnlyActiveRoutes() async throws {

        let activeRoute = makeRoute(
            origin: "Medellín",
            destination: "Bogotá",
            isActive: true
        )

        let inactiveRoute = makeRoute(
            origin: "Medellín",
            destination: "Cali",
            isActive: false
        )

        let anotherActiveRoute = makeRoute(
            origin: "Medellín",
            destination: "Pereira",
            isActive: true
        )

        let sut = makeSUT(
            routes: [
                activeRoute,
                inactiveRoute,
                anotherActiveRoute
            ]
        )

        let result = try await sut.execute()

        #expect(
            result == [
                activeRoute,
                anotherActiveRoute
            ]
        )
    }
}

private extension GetActiveRoutesUseCaseTests {

    func makeSUT(
        routes: [Route] = []
    ) -> GetActiveRoutesUseCase {

        GetActiveRoutes(
            routeRepository: FakeActiveRoutesRepository(
                routes: routes
            )
        )
    }

    func makeRoute(
        id: UUID = UUID(),
        origin: String = "Medellín",
        destination: String = "Bogotá",
        estimatedMinutes: Int = 360,
        isActive: Bool = true
    ) -> Route {

        Route(
            id: id,
            origin: origin,
            destination: destination,
            estimatedMinutes: estimatedMinutes,
            isActive: isActive
        )
    }
}

private final class FakeActiveRoutesRepository: RouteRepository {

    private var routes: [Route]

    init(routes: [Route]) {
        self.routes = routes
    }

    func getById(_ id: UUID) async throws -> Route? {
        routes.first { $0.id == id }
    }

    func getAll() async throws -> [Route] {
        routes
    }

    func save(_ route: Route) async throws {
        routes.append(route)
    }
}
