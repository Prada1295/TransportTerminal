//
//  CreateDispatchUseCaseTests.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 24/08/26.
//

import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct CreateDispatchUseCaseTests {
    @Test func executeWhenVehicleDoesNotExistThrowsVehicleNotFound() async throws {
        let route = makeRoute()
        let bay = makeBay()
        let sut = makeSUT(routes: [route], bays: [bay])

        await expectTerminalError(.vehicleNotFound) {
            _ = try await sut.execute(
                vehicleId: UUID(),
                routeId: route.id,
                bayId: bay.id,
                scheduledDeparture: Date()
            )
        }
    }

    @Test func executeWhenVehicleIsInMaintenanceThrowsVehicleInMaintenance() async throws {
        let vehicle = makeVehicle(status: .maintenance)
        let route = makeRoute()
        let bay = makeBay()
        let sut = makeSUT(vehicles: [vehicle], routes: [route], bays: [bay])

        await expectTerminalError(.vehicleInMaintenance) {
            _ = try await sut.execute(
                vehicleId: vehicle.id,
                routeId: route.id,
                bayId: bay.id,
                scheduledDeparture: Date()
            )
        }
    }

    @Test func executeWhenVehicleIsNotInsideTerminalThrowsVehicleNotInsideTerminal() async throws {
        let vehicle = makeVehicle(status: .outsideTerminal)
        let route = makeRoute()
        let bay = makeBay()
        let sut = makeSUT(vehicles: [vehicle], routes: [route], bays: [bay])

        await expectTerminalError(.vehicleNotInsideTerminal) {
            _ = try await sut.execute(
                vehicleId: vehicle.id,
                routeId: route.id,
                bayId: bay.id,
                scheduledDeparture: Date()
            )
        }
    }

    @Test func executeWhenRouteDoesNotExistThrowsRouteNotFound() async throws {
        let vehicle = makeVehicle(status: .insideTerminal)
        let bay = makeBay()
        let sut = makeSUT(vehicles: [vehicle], bays: [bay])

        await expectTerminalError(.routeNotFound) {
            _ = try await sut.execute(
                vehicleId: vehicle.id,
                routeId: UUID(),
                bayId: bay.id,
                scheduledDeparture: Date()
            )
        }
    }

    @Test func executeWhenRouteIsInactiveThrowsRouteInactive() async throws {
        let vehicle = makeVehicle(status: .insideTerminal)
        let route = makeRoute(isActive: false)
        let bay = makeBay()
        let sut = makeSUT(vehicles: [vehicle], routes: [route], bays: [bay])

        await expectTerminalError(.routeInactive) {
            _ = try await sut.execute(
                vehicleId: vehicle.id,
                routeId: route.id,
                bayId: bay.id,
                scheduledDeparture: Date()
            )
        }
    }

    @Test func executeWhenBayDoesNotExistThrowsBayNotFound() async throws {
        let vehicle = makeVehicle(status: .insideTerminal)
        let route = makeRoute()
        let sut = makeSUT(vehicles: [vehicle], routes: [route])

        await expectTerminalError(.bayNotFound) {
            _ = try await sut.execute(
                vehicleId: vehicle.id,
                routeId: route.id,
                bayId: UUID(),
                scheduledDeparture: Date()
            )
        }
    }

    @Test func executeWhenBayIsInactiveThrowsBayInactive() async throws {
        let vehicle = makeVehicle(status: .insideTerminal)
        let route = makeRoute()
        let bay = makeBay(active: false)
        let sut = makeSUT(vehicles: [vehicle], routes: [route], bays: [bay])

        await expectTerminalError(.bayInactive) {
            _ = try await sut.execute(
                vehicleId: vehicle.id,
                routeId: route.id,
                bayId: bay.id,
                scheduledDeparture: Date()
            )
        }
    }

    @Test func executeWhenVehicleAlreadyHasActiveDispatchThrowsVehicleAlreadyHasActiveDispatch() async throws {
        let vehicle = makeVehicle(status: .insideTerminal)
        let route = makeRoute()
        let bay = makeBay()
        let existingDispatch = makeDispatch(vehicleId: vehicle.id, routeId: route.id, bayId: UUID())
        let sut = makeSUT(
            vehicles: [vehicle],
            routes: [route],
            bays: [bay],
            activeDispatches: [existingDispatch]
        )

        await expectTerminalError(.vehicleAlreadyHasActiveDispatch) {
            _ = try await sut.execute(
                vehicleId: vehicle.id,
                routeId: route.id,
                bayId: bay.id,
                scheduledDeparture: Date()
            )
        }
    }

    @Test func executeWhenBayAlreadyHasActiveDispatchThrowsBayAlreadyHasActiveDispatch() async throws {
        let vehicle = makeVehicle(status: .insideTerminal)
        let route = makeRoute()
        let bay = makeBay()
        let existingDispatch = makeDispatch(vehicleId: UUID(), routeId: route.id, bayId: bay.id)
        let sut = makeSUT(
            vehicles: [vehicle],
            routes: [route],
            bays: [bay],
            activeDispatches: [existingDispatch]
        )

        await expectTerminalError(.bayAlreadyHasActiveDispatch) {
            _ = try await sut.execute(
                vehicleId: vehicle.id,
                routeId: route.id,
                bayId: bay.id,
                scheduledDeparture: Date()
            )
        }
    }

    @Test func executeWhenValidDataCreatesScheduledDispatch() async throws {
        let vehicle = makeVehicle(status: .insideTerminal)
        let route = makeRoute()
        let bay = makeBay()
        let scheduledDeparture = Date()
        let repositories = makeRepositories(
            vehicles: [vehicle],
            routes: [route],
            bays: [bay]
        )
        let sut = makeSUT(
            vehicleRepository: repositories.vehicleRepository,
            routeRepository: repositories.routeRepository,
            bayRepository: repositories.bayRepository,
            dispatchRepository: repositories.dispatchRepository
        )

        let result = try await sut.execute(
            vehicleId: vehicle.id,
            routeId: route.id,
            bayId: bay.id,
            scheduledDeparture: scheduledDeparture
        )

        #expect(result.vehicleId == vehicle.id)
        #expect(result.routeId == route.id)
        #expect(result.bayId == bay.id)
        #expect(result.scheduledDeparture == scheduledDeparture)
        #expect(result.status == .scheduled)
        #expect(repositories.dispatchRepository.savedDispatches.count == 1)
        #expect(repositories.dispatchRepository.savedDispatches.first?.id == result.dispatchId)
        #expect(repositories.dispatchRepository.savedDispatches.first?.status == .scheduled)
    }
}

private extension CreateDispatchUseCaseTests {
    func makeSUT(
        vehicles: [Vehicle] = [],
        routes: [Route] = [],
        bays: [Bay] = [],
        activeDispatches: [Dispatch] = []
    ) -> CreateDispatchUseCase {
        let repositories = makeRepositories(
            vehicles: vehicles,
            routes: routes,
            bays: bays,
            activeDispatches: activeDispatches
        )

        return makeSUT(
            vehicleRepository: repositories.vehicleRepository,
            routeRepository: repositories.routeRepository,
            bayRepository: repositories.bayRepository,
            dispatchRepository: repositories.dispatchRepository
        )
    }

    func makeSUT(
        vehicleRepository: VehicleRepository,
        routeRepository: RouteRepository,
        bayRepository: BayRepository,
        dispatchRepository: DispatchRepository
    ) -> CreateDispatchUseCase {
        CreateDispatch(
            vehicleRepository: vehicleRepository,
            routeRepository: routeRepository,
            bayRepository: bayRepository,
            dispatchRepository: dispatchRepository
        )
    }

    func makeRepositories(
        vehicles: [Vehicle] = [],
        routes: [Route] = [],
        bays: [Bay] = [],
        activeDispatches: [Dispatch] = []
    ) -> (
        vehicleRepository: FakeCreateDispatchVehicleRepository,
        routeRepository: FakeCreateDispatchRouteRepository,
        bayRepository: FakeCreateDispatchBayRepository,
        dispatchRepository: FakeCreateDispatchDispatchRepository
    ) {
        (
            vehicleRepository: FakeCreateDispatchVehicleRepository(vehicles: vehicles),
            routeRepository: FakeCreateDispatchRouteRepository(routes: routes),
            bayRepository: FakeCreateDispatchBayRepository(bays: bays),
            dispatchRepository: FakeCreateDispatchDispatchRepository(activeDispatches: activeDispatches)
        )
    }

    func makeVehicle(
        id: UUID = UUID(),
        plate: String = "ABC123",
        companyId: UUID = UUID(),
        type: VehicleType = .bus,
        capacity: Int = 40,
        status: VehicleStatus = .insideTerminal
    ) -> Vehicle {
        Vehicle(
            id: id,
            plate: plate,
            companyId: companyId,
            type: type,
            capacity: capacity,
            status: status
        )
    }

    func makeRoute(
        id: UUID = UUID(),
        origin: String = "Neiva",
        destination: String = "Bogota",
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

    func makeBay(
        id: UUID = UUID(),
        code: String = "A1",
        active: Bool = true
    ) -> Bay {
        Bay(id: id, code: code, active: active)
    }

    func makeDispatch(
        id: UUID = UUID(),
        vehicleId: UUID = UUID(),
        routeId: UUID = UUID(),
        bayId: UUID = UUID(),
        scheduledDeparture: Date = Date(),
        status: DispatchStatus = .scheduled
    ) -> Dispatch {
        Dispatch(
            id: id,
            vehicleId: vehicleId,
            routeId: routeId,
            bayId: bayId,
            scheduledDeparture: scheduledDeparture,
            status: status
        )
    }

    func expectTerminalError(
        _ expectedError: TerminalError,
        operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            Issue.record("Expected error: \(expectedError)")
        } catch let error as TerminalError {
            #expect(error == expectedError)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}

private final class FakeCreateDispatchVehicleRepository: VehicleRepository {
    private var vehicles: [Vehicle]

    init(vehicles: [Vehicle]) {
        self.vehicles = vehicles
    }

    func getAll() async throws -> [Vehicle] {
        vehicles
    }

    func getById(_ id: UUID) async throws -> Vehicle? {
        vehicles.first { $0.id == id }
    }

    func save(_ vehicle: Vehicle) async throws {
        vehicles.append(vehicle)
    }

    func update(_ vehicle: Vehicle) async throws {
        guard let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) else {
            return
        }

        vehicles[index] = vehicle
    }
}

private final class FakeCreateDispatchRouteRepository: RouteRepository {
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

private final class FakeCreateDispatchBayRepository: BayRepository {
    private var bays: [Bay]

    init(bays: [Bay]) {
        self.bays = bays
    }

    func getById(_ id: UUID) async throws -> Bay? {
        bays.first { $0.id == id }
    }

    func getAll() async throws -> [Bay] {
        bays
    }

    func save(_ bay: Bay) async throws {
        bays.append(bay)
    }
}

private final class FakeCreateDispatchDispatchRepository: DispatchRepository {
    private let activeDispatches: [Dispatch]
    private(set) var savedDispatches: [Dispatch] = []

    init(activeDispatches: [Dispatch]) {
        self.activeDispatches = activeDispatches
    }

    func save(_ dispatch: Dispatch) async throws {
        savedDispatches.append(dispatch)
    }

    func getById(_ id: UUID) async throws -> Dispatch? {
        (activeDispatches + savedDispatches).first { $0.id == id }
    }

    func getActiveDispatches() async throws -> [Dispatch] {
        activeDispatches
    }
}
