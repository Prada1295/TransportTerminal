//
//  RegisterVehicleExitViewModelTests.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 07/09/26.
//

import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct RegisterVehicleExitViewModelTests {

    // MARK: - Load Vehicles

    @Test
    func loadVehiclesInsideTerminalWhenUseCaseSucceedsLoadsVehicles() async {
        let vehicle = makeVehicle(status: .insideTerminal)
        let useCase = FakeGetVehiclesInsideTerminalUseCase(
            vehicles: [vehicle]
        )

        let viewModel = makeSUT(
            getVehiclesInsideTerminalUseCase: useCase
        )

        await viewModel.loadVehiclesInsideTerminal()

        #expect(viewModel.vehiclesInsideTerminal == [vehicle])
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test
    func loadVehiclesInsideTerminalWhenUseCaseFailsShowsError() async {
        let useCase = FakeGetVehiclesInsideTerminalUseCase(
            error: TestError.someError
        )

        let viewModel = makeSUT(
            getVehiclesInsideTerminalUseCase: useCase
        )

        await viewModel.loadVehiclesInsideTerminal()

        #expect(viewModel.vehiclesInsideTerminal.isEmpty)
        #expect(
            viewModel.errorMessage ==
                "Unable to load vehicles inside the terminal."
        )
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Register Exit

    @Test
    func registerExitWhenUseCaseSucceedsProducesExitResult() async {
        let vehicle = makeVehicle(status: .insideTerminal)

        let result = VehicleExitResult(
            vehicleId: vehicle.id,
            plate: vehicle.plate,
            timestamp: Date()
        )

        let useCase = FakeRegisterVehicleExitUseCase(
            result: result
        )

        let viewModel = makeSUT(
            registerVehicleExitUseCase: useCase
        )

        await viewModel.registerExit(vehicleId: vehicle.id)

        #expect(viewModel.exitResult == result)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
        #expect(useCase.receivedVehicleId == vehicle.id)
    }

    @Test
    func registerExitWhenVehicleIsNotFoundShowsError() async {
        let useCase = FakeRegisterVehicleExitUseCase(
            error: TerminalError.vehicleNotFound
        )

        let viewModel = makeSUT(
            registerVehicleExitUseCase: useCase
        )

        await viewModel.registerExit(vehicleId: UUID())

        #expect(
            viewModel.errorMessage ==
                "Vehicle was not found."
        )
        #expect(viewModel.exitResult == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test
    func registerExitWhenVehicleIsInMaintenanceShowsError() async {
        let useCase = FakeRegisterVehicleExitUseCase(
            error: TerminalError.vehicleInMaintenance
        )

        let viewModel = makeSUT(
            registerVehicleExitUseCase: useCase
        )

        await viewModel.registerExit(vehicleId: UUID())

        #expect(
            viewModel.errorMessage ==
                "Vehicle is currently in maintenance."
        )
        #expect(viewModel.exitResult == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test
    func registerExitWhenVehicleIsNotInsideTerminalShowsError() async {
        let useCase = FakeRegisterVehicleExitUseCase(
            error: TerminalError.vehicleNotInsideTerminal
        )

        let viewModel = makeSUT(
            registerVehicleExitUseCase: useCase
        )

        await viewModel.registerExit(vehicleId: UUID())

        #expect(
            viewModel.errorMessage ==
                "Vehicle is not inside the terminal."
        )
        #expect(viewModel.exitResult == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test
    func registerExitWhenUseCaseFailsWithUnexpectedErrorShowsGenericError() async {
        let useCase = FakeRegisterVehicleExitUseCase(
            error: TestError.someError
        )

        let viewModel = makeSUT(
            registerVehicleExitUseCase: useCase
        )

        await viewModel.registerExit(vehicleId: UUID())

        #expect(
            viewModel.errorMessage ==
                "Unable to register vehicle exit."
        )
        #expect(viewModel.exitResult == nil)
        #expect(viewModel.isLoading == false)
    }
}

// MARK: - SUT

private extension RegisterVehicleExitViewModelTests {

    func makeSUT(
        getVehiclesInsideTerminalUseCase:
            GetVehiclesInsideTerminalUseCase =
                FakeGetVehiclesInsideTerminalUseCase(),

        registerVehicleExitUseCase:
            RegisterVehicleExitUseCase =
                FakeRegisterVehicleExitUseCase()
    ) -> RegisterVehicleExitViewModel {

        RegisterVehicleExitViewModel(
            getVehiclesInsideTerminalUseCase:
                getVehiclesInsideTerminalUseCase,
            registerVehicleExitUseCase:
                registerVehicleExitUseCase
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
}

// MARK: - Fake Get Vehicles Inside Terminal Use Case

private final class FakeGetVehiclesInsideTerminalUseCase:
    GetVehiclesInsideTerminalUseCase {

    private let vehicles: [Vehicle]
    private let error: Error?

    init(
        vehicles: [Vehicle] = [],
        error: Error? = nil
    ) {
        self.vehicles = vehicles
        self.error = error
    }

    func execute() async throws -> [Vehicle] {
        if let error {
            throw error
        }

        return vehicles
    }
}

// MARK: - Fake Register Vehicle Exit Use Case

private final class FakeRegisterVehicleExitUseCase:
    RegisterVehicleExitUseCase {

    private let result: VehicleExitResult?
    private let error: Error?

    private(set) var receivedVehicleId: UUID?

    init(
        result: VehicleExitResult? = nil,
        error: Error? = nil
    ) {
        self.result = result
        self.error = error
    }

    func execute(
        vehicleId: UUID
    ) async throws -> VehicleExitResult {

        receivedVehicleId = vehicleId

        if let error {
            throw error
        }

        guard let result else {
            fatalError(
                "FakeRegisterVehicleExitUseCase requires a result."
            )
        }

        return result
    }
}

// MARK: - Test Error

private enum TestError: Error {
    case someError
}
