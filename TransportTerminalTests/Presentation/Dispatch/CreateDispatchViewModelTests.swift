//
//  CreateDispatchViewModelTests.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 20/09/26.
//

import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct CreateDispatchViewModelTests {

    // MARK: - Load Options

    @Test
    func loadOptionsLoadsVehiclesRoutesAndBays() async {
        let vehicle = makeVehicle()
        let route = makeRoute()
        let bay = makeBay()

        let vehicleRepository =
            CreateDispatchViewModelFakeVehicleRepository(
                vehicles: [vehicle]
            )

        let routeRepository =
            CreateDispatchViewModelFakeRouteRepository(
                routes: [route]
            )

        let bayRepository =
            CreateDispatchViewModelFakeBayRepository(
                bays: [bay]
            )

        let sut = makeSUT(
            vehicleRepository: vehicleRepository,
            routeRepository: routeRepository,
            bayRepository: bayRepository
        )

        await sut.loadOptions()

        #expect(sut.vehicles == [vehicle])
        #expect(sut.routes == [route])

        // Bay does not conform to Equatable.
        #expect(sut.bays.count == 1)
        #expect(sut.bays[0].id == bay.id)
        #expect(sut.bays[0].code == bay.code)
        #expect(sut.bays[0].active == bay.active)

        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
    }

    @Test
    func loadOptionsWhenRepositoryFailsClearsOptionsAndShowsError() async {
        let vehicleRepository =
            CreateDispatchViewModelFakeVehicleRepository(
                error: TerminalError.vehicleNotFound
            )

        let routeRepository =
            CreateDispatchViewModelFakeRouteRepository()

        let bayRepository =
            CreateDispatchViewModelFakeBayRepository()

        let sut = makeSUT(
            vehicleRepository: vehicleRepository,
            routeRepository: routeRepository,
            bayRepository: bayRepository
        )

        await sut.loadOptions()

        #expect(sut.vehicles.isEmpty)
        #expect(sut.routes.isEmpty)
        #expect(sut.bays.isEmpty)
        #expect(sut.isLoading == false)
        #expect(
            sut.errorMessage == "Unable to load dispatch options."
        )
    }

    // MARK: - Can Create Dispatch

    @Test
    func canCreateDispatchIsFalseWhenNoSelectionsExist() {
        let sut = makeSUT()

        #expect(sut.canCreateDispatch == false)
    }

    @Test
    func canCreateDispatchIsFalseWhenVehicleIsNotSelected() {
        let sut = makeSUT()

        sut.selectedRouteId = UUID()
        sut.selectedBayId = UUID()

        #expect(sut.canCreateDispatch == false)
    }

    @Test
    func canCreateDispatchIsFalseWhenRouteIsNotSelected() {
        let sut = makeSUT()

        sut.selectedVehicleId = UUID()
        sut.selectedBayId = UUID()

        #expect(sut.canCreateDispatch == false)
    }

    @Test
    func canCreateDispatchIsFalseWhenBayIsNotSelected() {
        let sut = makeSUT()

        sut.selectedVehicleId = UUID()
        sut.selectedRouteId = UUID()

        #expect(sut.canCreateDispatch == false)
    }

    @Test
    func canCreateDispatchIsTrueWhenAllSelectionsExist() {
        let sut = makeSUT()

        sut.selectedVehicleId = UUID()
        sut.selectedRouteId = UUID()
        sut.selectedBayId = UUID()

        #expect(sut.canCreateDispatch == true)
    }

    // MARK: - Create Dispatch

    @Test
    func createDispatchWhenSelectionsAreMissingDoesNotCallUseCase() async {
        let createUseCase =
            CreateDispatchViewModelFakeCreateDispatchUseCase()

        let sut = makeSUT(
            createDispatchUseCase: createUseCase
        )

        let result = await sut.createDispatch()

        #expect(result == nil)
        #expect(createUseCase.executions.isEmpty)
        #expect(
            sut.errorMessage == "Please complete all required fields."
        )
    }

    @Test
    func createDispatchCallsUseCaseWithSelectedValues() async {
        let vehicleId = UUID()
        let routeId = UUID()
        let bayId = UUID()
        let scheduledDeparture = Date()

        let expectedResult = makeCreateDispatchResult(
            vehicleId: vehicleId,
            routeId: routeId,
            bayId: bayId,
            scheduledDeparture: scheduledDeparture
        )

        let createUseCase =
            CreateDispatchViewModelFakeCreateDispatchUseCase(
                result: expectedResult
            )

        let sut = makeSUT(
            createDispatchUseCase: createUseCase
        )

        sut.selectedVehicleId = vehicleId
        sut.selectedRouteId = routeId
        sut.selectedBayId = bayId
        sut.scheduledDeparture = scheduledDeparture

        let result = await sut.createDispatch()

        #expect(result == expectedResult)

        #expect(
            createUseCase.executions == [
                .init(
                    vehicleId: vehicleId,
                    routeId: routeId,
                    bayId: bayId,
                    scheduledDeparture: scheduledDeparture
                )
            ]
        )

        #expect(sut.errorMessage == nil)
        #expect(sut.isCreating == false)
    }

    @Test
    func createDispatchWhenTerminalErrorShowsSpecificMessage() async {
        let createUseCase =
            CreateDispatchViewModelFakeCreateDispatchUseCase(
                error: TerminalError.vehicleInMaintenance
            )

        let sut = makeSUT(
            createDispatchUseCase: createUseCase
        )

        sut.selectedVehicleId = UUID()
        sut.selectedRouteId = UUID()
        sut.selectedBayId = UUID()

        let result = await sut.createDispatch()

        #expect(result == nil)

        #expect(
            sut.errorMessage ==
                "The selected vehicle is currently in maintenance."
        )

        #expect(sut.isCreating == false)
    }

    @Test
    func createDispatchWhenUnexpectedErrorShowsGenericMessage() async {
        let createUseCase =
            CreateDispatchViewModelFakeCreateDispatchUseCase(
                error: CreateDispatchViewModelTestError.unexpected
            )

        let sut = makeSUT(
            createDispatchUseCase: createUseCase
        )

        sut.selectedVehicleId = UUID()
        sut.selectedRouteId = UUID()
        sut.selectedBayId = UUID()

        let result = await sut.createDispatch()

        #expect(result == nil)
        #expect(
            sut.errorMessage == "Unable to create dispatch."
        )
        #expect(sut.isCreating == false)
    }

    // MARK: - Error

    @Test
    func clearErrorRemovesErrorMessage() async {
        let createUseCase =
            CreateDispatchViewModelFakeCreateDispatchUseCase(
                error: TerminalError.vehicleInMaintenance
            )

        let sut = makeSUT(
            createDispatchUseCase: createUseCase
        )

        sut.selectedVehicleId = UUID()
        sut.selectedRouteId = UUID()
        sut.selectedBayId = UUID()

        _ = await sut.createDispatch()

        #expect(sut.errorMessage != nil)

        sut.clearError()

        #expect(sut.errorMessage == nil)
    }
}

// MARK: - Test Helpers

private extension CreateDispatchViewModelTests {

    func makeSUT(
        vehicleRepository: VehicleRepository =
            CreateDispatchViewModelFakeVehicleRepository(),
        routeRepository: RouteRepository =
            CreateDispatchViewModelFakeRouteRepository(),
        bayRepository: BayRepository =
            CreateDispatchViewModelFakeBayRepository(),
        createDispatchUseCase: CreateDispatchUseCase =
            CreateDispatchViewModelFakeCreateDispatchUseCase()
    ) -> CreateDispatchViewModel {

        CreateDispatchViewModel(
            vehicleRepository: vehicleRepository,
            routeRepository: routeRepository,
            bayRepository: bayRepository,
            createDispatchUseCase: createDispatchUseCase
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
            origin: "Medellín",
            destination: "Bogotá",
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

    func makeCreateDispatchResult(
        dispatchId: UUID = UUID(),
        vehicleId: UUID,
        routeId: UUID,
        bayId: UUID,
        scheduledDeparture: Date,
        status: DispatchStatus = .scheduled
    ) -> CreateDispatchResult {

        CreateDispatchResult(
            dispatchId: dispatchId,
            vehicleId: vehicleId,
            routeId: routeId,
            bayId: bayId,
            scheduledDeparture: scheduledDeparture,
            status: status
        )
    }
}

// MARK: - Fakes

final class CreateDispatchViewModelFakeVehicleRepository:
    VehicleRepository {

    private let vehicles: [Vehicle]
    private let error: TerminalError?

    init(
        vehicles: [Vehicle] = [],
        error: TerminalError? = nil
    ) {
        self.vehicles = vehicles
        self.error = error
    }

    func getAll() async throws -> [Vehicle] {
        if let error {
            throw error
        }

        return vehicles
    }

    func getById(
        _ id: UUID
    ) async throws -> Vehicle? {
        vehicles.first { $0.id == id }
    }

    func save(
        _ vehicle: Vehicle
    ) async throws {}

    func update(
        _ vehicle: Vehicle
    ) async throws {}
}

final class CreateDispatchViewModelFakeRouteRepository:
    RouteRepository {

    private let routes: [Route]

    init(
        routes: [Route] = []
    ) {
        self.routes = routes
    }

    func getById(
        _ id: UUID
    ) async throws -> Route? {
        routes.first { $0.id == id }
    }

    func getAll() async throws -> [Route] {
        routes
    }

    func save(
        _ route: Route
    ) async throws {}
}

final class CreateDispatchViewModelFakeBayRepository:
    BayRepository {

    private let bays: [Bay]

    init(
        bays: [Bay] = []
    ) {
        self.bays = bays
    }

    func getById(
        _ id: UUID
    ) async throws -> Bay? {
        bays.first { $0.id == id }
    }

    func getAll() async throws -> [Bay] {
        bays
    }

    func save(
        _ bay: Bay
    ) async throws {}
}

final class CreateDispatchViewModelFakeCreateDispatchUseCase:
    CreateDispatchUseCase {

    struct Execution: Equatable {
        let vehicleId: UUID
        let routeId: UUID
        let bayId: UUID
        let scheduledDeparture: Date
    }

    private let result: CreateDispatchResult?
    private let error: Error?

    private(set) var executions: [Execution] = []

    init(
        result: CreateDispatchResult? = nil,
        error: Error? = nil
    ) {
        self.result = result
        self.error = error
    }

    func execute(
        vehicleId: UUID,
        routeId: UUID,
        bayId: UUID,
        scheduledDeparture: Date
    ) async throws -> CreateDispatchResult {

        executions.append(
            Execution(
                vehicleId: vehicleId,
                routeId: routeId,
                bayId: bayId,
                scheduledDeparture: scheduledDeparture
            )
        )

        if let error {
            throw error
        }

        guard let result else {
            fatalError(
                "CreateDispatchViewModelFakeCreateDispatchUseCase requires a result or error"
            )
        }

        return result
    }
}

// MARK: - Test Error

enum CreateDispatchViewModelTestError: Error {
    case unexpected
}
