//
//  RegisterVehicleEntryViewModelTests.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//
import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct RegisterVehicleEntryViewModelTests {

    @Test
    func registerEntryWhenUseCaseSucceedsStoresResult() async {

        let vehicleId = UUID()

        let expectedResult = VehicleEntryResult(
            vehicleId: vehicleId,
            plate: "ABC123",
            timestamp: Date()
        )

        let useCase = FakeRegisterVehicleEntryUseCase(
            result: expectedResult
        )

        let sut = RegisterVehicleEntryViewModel(
            registerVehicleEntryUseCase: useCase
        )

        await sut.registerEntry(vehicleId: vehicleId)

        #expect(sut.entryResult == expectedResult)
        #expect(sut.errorMessage == nil)
        #expect(sut.isLoading == false)
        #expect(useCase.requestedVehicleId == vehicleId)
    }

    @Test
    func registerEntryWhenUseCaseFailsShowsErrorMessage() async {

        let useCase = FakeRegisterVehicleEntryUseCase(
            error: TerminalError.vehicleAlreadyInside
        )

        let sut = RegisterVehicleEntryViewModel(
            registerVehicleEntryUseCase: useCase
        )

        await sut.registerEntry(vehicleId: UUID())

        #expect(
            sut.errorMessage ==
            "Vehicle is already inside the terminal."
        )

        #expect(sut.entryResult == nil)
        #expect(sut.isLoading == false)
    }

    @Test
    func registerEntryWhenCompanyIsInactiveShowsCompanyInactiveMessage() async {

        let useCase = FakeRegisterVehicleEntryUseCase(
            error: TerminalError.companyInactive
        )

        let sut = RegisterVehicleEntryViewModel(
            registerVehicleEntryUseCase: useCase
        )

        await sut.registerEntry(vehicleId: UUID())

        #expect(
            sut.errorMessage ==
            "Vehicle company is inactive."
        )

        #expect(sut.entryResult == nil)
        #expect(sut.isLoading == false)
    }

    @Test
    func registerEntryWhenVehicleIsInMaintenanceShowsMaintenanceMessage() async {

        let useCase = FakeRegisterVehicleEntryUseCase(
            error: TerminalError.vehicleInMaintenance
        )

        let sut = RegisterVehicleEntryViewModel(
            registerVehicleEntryUseCase: useCase
        )

        await sut.registerEntry(vehicleId: UUID())

        #expect(
            sut.errorMessage ==
            "Vehicle is currently in maintenance."
        )

        #expect(sut.entryResult == nil)
        #expect(sut.isLoading == false)
    }

    @Test
    func registerEntryWhenVehicleDoesNotExistShowsVehicleNotFoundMessage() async {

        let useCase = FakeRegisterVehicleEntryUseCase(
            error: TerminalError.vehicleNotFound
        )

        let sut = RegisterVehicleEntryViewModel(
            registerVehicleEntryUseCase: useCase
        )

        await sut.registerEntry(vehicleId: UUID())

        #expect(
            sut.errorMessage ==
            "Vehicle was not found."
        )

        #expect(sut.entryResult == nil)
        #expect(sut.isLoading == false)
    }

    @Test
    func registerEntryWhenCompanyDoesNotExistShowsCompanyNotFoundMessage() async {

        let useCase = FakeRegisterVehicleEntryUseCase(
            error: TerminalError.companyNotFound
        )

        let sut = RegisterVehicleEntryViewModel(
            registerVehicleEntryUseCase: useCase
        )

        await sut.registerEntry(vehicleId: UUID())

        #expect(
            sut.errorMessage ==
            "Vehicle company was not found."
        )

        #expect(sut.entryResult == nil)
        #expect(sut.isLoading == false)
    }
}


// MARK: - Fake Use Case

private final class FakeRegisterVehicleEntryUseCase:
    RegisterVehicleEntryUseCase {

    private let result: VehicleEntryResult?
    private let error: Error?

    private(set) var requestedVehicleId: UUID?

    init(
        result: VehicleEntryResult? = nil,
        error: Error? = nil
    ) {
        self.result = result
        self.error = error
    }

    func execute(
        vehicleId: UUID
    ) async throws -> VehicleEntryResult {

        requestedVehicleId = vehicleId

        if let error {
            throw error
        }

        guard let result else {
            fatalError("Fake must have either a result or an error.")
        }

        return result
    }
}
