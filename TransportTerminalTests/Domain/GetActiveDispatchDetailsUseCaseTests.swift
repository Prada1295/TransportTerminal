//
//  GetActiveDispatchDetailsUseCaseTests.swift
//  TransportTerminalTests
//
//  Created by Codex on 3/10/26.
//

import Foundation
import Testing
@testable import TransportTerminal

struct GetActiveDispatchDetailsUseCaseTests {

    @Test
    func executeReturnsActiveDispatchDetails() async throws {
        let vehicle = makeVehicle()
        let route = makeRoute()
        let bay = makeBay()
        let dispatch = makeDispatch(
            vehicleId: vehicle.id,
            routeId: route.id,
            bayId: bay.id
        )

        let sut = makeSUT(
            dispatches: [dispatch],
            vehicles: [vehicle],
            routes: [route],
            bays: [bay]
        )

        let result = try await sut.execute()

        #expect(result.count == 1)
        #expect(result[0].id == dispatch.id)
        #expect(result[0].vehiclePlate == vehicle.plate)
        #expect(result[0].vehicleType == vehicle.type)
        #expect(result[0].routeOrigin == route.origin)
        #expect(result[0].routeDestination == route.destination)
        #expect(result[0].bayCode == bay.code)
        #expect(result[0].scheduledDeparture == dispatch.scheduledDeparture)
        #expect(result[0].actualDeparture == dispatch.actualDeparture)
        #expect(result[0].status == dispatch.status)
    }

    @Test
    func executeWhenVehicleIsMissingThrowsVehicleNotFound() async {
        let route = makeRoute()
        let bay = makeBay()
        let dispatch = makeDispatch(
            routeId: route.id,
            bayId: bay.id
        )

        let sut = makeSUT(
            dispatches: [dispatch],
            vehicles: [],
            routes: [route],
            bays: [bay]
        )

        await #expect(throws: TerminalError.vehicleNotFound) {
            _ = try await sut.execute()
        }
    }

    @Test
    func executeWhenRouteIsMissingThrowsRouteNotFound() async {
        let vehicle = makeVehicle()
        let bay = makeBay()
        let dispatch = makeDispatch(
            vehicleId: vehicle.id,
            bayId: bay.id
        )

        let sut = makeSUT(
            dispatches: [dispatch],
            vehicles: [vehicle],
            routes: [],
            bays: [bay]
        )

        await #expect(throws: TerminalError.routeNotFound) {
            _ = try await sut.execute()
        }
    }

    @Test
    func executeWhenBayIsMissingThrowsBayNotFound() async {
        let vehicle = makeVehicle()
        let route = makeRoute()
        let dispatch = makeDispatch(
            vehicleId: vehicle.id,
            routeId: route.id
        )

        let sut = makeSUT(
            dispatches: [dispatch],
            vehicles: [vehicle],
            routes: [route],
            bays: []
        )

        await #expect(throws: TerminalError.bayNotFound) {
            _ = try await sut.execute()
        }
    }
}

private extension GetActiveDispatchDetailsUseCaseTests {

    func makeSUT(
        dispatches: [Dispatch] = [],
        vehicles: [Vehicle] = [],
        routes: [Route] = [],
        bays: [Bay] = []
    ) -> GetActiveDispatchDetails {

        GetActiveDispatchDetails(
            dispatchRepository:
                FakeDispatchDetailsDispatchRepository(
                    dispatches: dispatches
                ),
            vehicleRepository:
                FakeDispatchDetailsVehicleRepository(
                    vehicles: vehicles
                ),
            routeRepository:
                FakeDispatchDetailsRouteRepository(
                    routes: routes
                ),
            bayRepository:
                FakeDispatchDetailsBayRepository(
                    bays: bays
                )
        )
    }

    func makeVehicle(
        id: UUID = UUID()
    ) -> Vehicle {

        Vehicle(
            id: id,
            plate: "ABC123",
            companyId: UUID(),
            type: .bus,
            capacity: 40,
            status: .insideTerminal
        )
    }

    func makeRoute(
        id: UUID = UUID()
    ) -> Route {

        Route(
            id: id,
            origin: "Medellin",
            destination: "Bogota",
            estimatedMinutes: 420,
            isActive: true
        )
    }

    func makeBay(
        id: UUID = UUID()
    ) -> Bay {

        Bay(
            id: id,
            code: "B01",
            active: true
        )
    }

    func makeDispatch(
        id: UUID = UUID(),
        vehicleId: UUID = UUID(),
        routeId: UUID = UUID(),
        bayId: UUID = UUID(),
        scheduledDeparture: Date = Date(),
        actualDeparture: Date? = nil,
        status: DispatchStatus = .scheduled
    ) -> Dispatch {

        Dispatch(
            id: id,
            vehicleId: vehicleId,
            routeId: routeId,
            bayId: bayId,
            scheduledDeparture: scheduledDeparture,
            actualDeparture: actualDeparture,
            status: status
        )
    }
}

private final class FakeDispatchDetailsDispatchRepository:
    DispatchRepository {

    private var dispatches: [Dispatch]

    init(dispatches: [Dispatch]) {
        self.dispatches = dispatches
    }

    func save(_ dispatch: Dispatch) async throws {
        dispatches.append(dispatch)
    }

    func getById(_ id: UUID) async throws -> Dispatch? {
        dispatches.first { $0.id == id }
    }

    func getActiveDispatches() async throws -> [Dispatch] {
        dispatches
    }

    func update(_ dispatch: Dispatch) async throws {}
}

private final class FakeDispatchDetailsVehicleRepository:
    VehicleRepository {

    private let vehicles: [Vehicle]

    init(vehicles: [Vehicle]) {
        self.vehicles = vehicles
    }

    func getAll() async throws -> [Vehicle] {
        vehicles
    }

    func getById(_ id: UUID) async throws -> Vehicle? {
        vehicles.first { $0.id == id }
    }

    func save(_ vehicle: Vehicle) async throws {}

    func update(_ vehicle: Vehicle) async throws {}
}

private final class FakeDispatchDetailsRouteRepository:
    RouteRepository {

    private let routes: [Route]

    init(routes: [Route]) {
        self.routes = routes
    }

    func getById(_ id: UUID) async throws -> Route? {
        routes.first { $0.id == id }
    }

    func getAll() async throws -> [Route] {
        routes
    }

    func save(_ route: Route) async throws {}
}

private final class FakeDispatchDetailsBayRepository:
    BayRepository {

    private let bays: [Bay]

    init(bays: [Bay]) {
        self.bays = bays
    }

    func getById(_ id: UUID) async throws -> Bay? {
        bays.first { $0.id == id }
    }

    func getAll() async throws -> [Bay] {
        bays
    }

    func save(_ bay: Bay) async throws {}
}
