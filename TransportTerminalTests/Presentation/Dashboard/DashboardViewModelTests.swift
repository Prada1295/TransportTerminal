//
//  DashboardViewModelTests.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//
import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct DashboardViewModelTests {

    @Test
    func loadDashboardLoadsVehiclesInsideTerminal() async {

        let insideVehicle = makeVehicle(
            plate: "ABC123",
            status: .insideTerminal
        )

        let insideUseCase = FakeGetVehiclesInsideTerminalUseCase(
            vehicles: [insideVehicle]
        )

        let allVehiclesUseCase = FakeGetVehiclesUseCase(
            vehicles: [insideVehicle]
        )

        let sut = makeSUT(
            getVehiclesInsideTerminalUseCase: insideUseCase,
            getVehiclesUseCase: allVehiclesUseCase
        )

        await sut.loadDashboard()

        #expect(
            sut.vehiclesInsideTerminal.count == 1
        )

        #expect(
            sut.vehiclesInsideTerminal.first?.id ==
            insideVehicle.id
        )

        #expect(sut.errorMessage == nil)
        #expect(sut.isLoading == false)
    }

    @Test
    func loadDashboardIdentifiesVehiclesAvailableForEntry() async {

        let outsideVehicle = makeVehicle(
            plate: "ABC123",
            status: .outsideTerminal
        )

        let insideVehicle = makeVehicle(
            plate: "DEF456",
            status: .insideTerminal
        )

        let maintenanceVehicle = makeVehicle(
            plate: "GHI789",
            status: .maintenance
        )

        let dispatchedVehicle = makeVehicle(
            plate: "JKL012",
            status: .dispatched
        )

        let allVehicles = [
            outsideVehicle,
            insideVehicle,
            maintenanceVehicle,
            dispatchedVehicle
        ]

        let sut = makeSUT(
            getVehiclesInsideTerminalUseCase:
                FakeGetVehiclesInsideTerminalUseCase(
                    vehicles: [insideVehicle]
                ),
            getVehiclesUseCase:
                FakeGetVehiclesUseCase(
                    vehicles: allVehicles
                )
        )

        await sut.loadDashboard()

        #expect(
            sut.vehiclesAvailableForEntry.count == 1
        )

        #expect(
            sut.vehiclesAvailableForEntry.first?.id ==
            outsideVehicle.id
        )
    }

    @Test
    func loadDashboardWhenUseCaseFailsShowsError() async {

        let sut = makeSUT(
            getVehiclesInsideTerminalUseCase:
                FakeGetVehiclesInsideTerminalUseCase(
                    error: TestError.failed
                ),
            getVehiclesUseCase:
                FakeGetVehiclesUseCase(
                    vehicles: []
                )
        )

        await sut.loadDashboard()

        #expect(
            sut.vehiclesInsideTerminal.isEmpty
        )

        #expect(
            sut.vehiclesAvailableForEntry.isEmpty
        )

        #expect(
            sut.errorMessage ==
            "Unable to load dashboard information."
        )

        #expect(sut.isLoading == false)
    }
}


// MARK: - Helpers

private extension DashboardViewModelTests {

    func makeSUT(
        getVehiclesInsideTerminalUseCase:
            GetVehiclesInsideTerminalUseCase,
        getVehiclesUseCase:
            GetVehiclesUseCase
    ) -> DashboardViewModel {

        DashboardViewModel(
            getVehiclesInsideTerminalUseCase:
                getVehiclesInsideTerminalUseCase,
            getVehiclesUseCase:
                getVehiclesUseCase
        )
    }

    func makeVehicle(
        id: UUID = UUID(),
        plate: String,
        companyId: UUID = UUID(),
        type: VehicleType = .bus,
        capacity: Int = 40,
        status: VehicleStatus
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


// MARK: - Fake Get Vehicles Inside Terminal

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


// MARK: - Fake Get Vehicles

private final class FakeGetVehiclesUseCase:
    GetVehiclesUseCase {

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


// MARK: - Test Error

private enum TestError: Error {
    case failed
}
