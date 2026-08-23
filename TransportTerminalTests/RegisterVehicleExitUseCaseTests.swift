//
//  RegisterVehicleExitUseCaseTests.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 22/08/26.
//

import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct RegisterVehicleExitUseCaseTests {
    @Test func executeWhenVehicleDoesNotExistThrowsVehicleNotFound() async throws {
        let sut = makeSUT()

        await expectTerminalError(.vehicleNotFound) {
            _ = try await sut.execute(vehicleId: UUID())
        }
    }

    @Test func executeWhenVehicleIsInMaintenanceThrowsVehicleInMaintenance() async throws {
        let vehicle = makeVehicle(status: .maintenance)
        let sut = makeSUT(vehicles: [vehicle])

        await expectTerminalError(.vehicleInMaintenance) {
            _ = try await sut.execute(vehicleId: vehicle.id)
        }
    }

    @Test func executeWhenVehicleIsOutsideTerminalThrowsVehicleNotInsideTerminal() async throws {
        let vehicle = makeVehicle(status: .outsideTerminal)
        let sut = makeSUT(vehicles: [vehicle])

        await expectTerminalError(.vehicleNotInsideTerminal) {
            _ = try await sut.execute(vehicleId: vehicle.id)
        }
    }

    @Test func executeWhenVehicleIsDispatchedThrowsVehicleNotInsideTerminal() async throws {
        let vehicle = makeVehicle(status: .dispatched)
        let sut = makeSUT(vehicles: [vehicle])

        await expectTerminalError(.vehicleNotInsideTerminal) {
            _ = try await sut.execute(vehicleId: vehicle.id)
        }
    }

    @Test func executeWhenValidVehicleRegistersExit() async throws {
        let vehicle = makeVehicle(status: .insideTerminal)
        let repositories = makeRepositories(vehicles: [vehicle])
        let sut = makeSUT(
            vehicleRepository: repositories.vehicleRepository,
            movementRepository: repositories.movementRepository
        )

        let result = try await sut.execute(vehicleId: vehicle.id)

        #expect(result.vehicleId == vehicle.id)
        #expect(result.plate == vehicle.plate)
        #expect(repositories.movementRepository.savedMovements.count == 1)
        #expect(repositories.movementRepository.savedMovements.first?.vehicleId == vehicle.id)
        #expect(repositories.movementRepository.savedMovements.first?.type == .exit)
        #expect(repositories.vehicleRepository.updatedVehicles.first?.status == .outsideTerminal)
    }
}

private extension RegisterVehicleExitUseCaseTests {
    func makeSUT(
        vehicles: [Vehicle] = [],
        movements: [VehicleMovement] = []
    ) -> RegisterVehicleExitUseCase {
        let repositories = makeRepositories(
            vehicles: vehicles,
            movements: movements
        )

        return makeSUT(
            vehicleRepository: repositories.vehicleRepository,
            movementRepository: repositories.movementRepository
        )
    }

    func makeSUT(
        vehicleRepository: VehicleRepository,
        movementRepository: VehicleMovementRepository
    ) -> RegisterVehicleExitUseCase {
        RegisterVehicleExit(
            vehicleRepository: vehicleRepository,
            movementRepository: movementRepository
        )
    }

    func makeRepositories(
        vehicles: [Vehicle] = [],
        movements: [VehicleMovement] = []
    ) -> (
        vehicleRepository: FakeExitVehicleRepository,
        movementRepository: FakeExitVehicleMovementRepository
    ) {
        (
            vehicleRepository: FakeExitVehicleRepository(vehicles: vehicles),
            movementRepository: FakeExitVehicleMovementRepository(movements: movements)
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

private final class FakeExitVehicleRepository: VehicleRepository {
    private var vehicles: [Vehicle]
    private(set) var updatedVehicles: [Vehicle] = []

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
        updatedVehicles.append(vehicle)

        guard let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) else {
            return
        }

        vehicles[index] = vehicle
    }
}

private final class FakeExitVehicleMovementRepository: VehicleMovementRepository {
    private(set) var savedMovements: [VehicleMovement]

    init(movements: [VehicleMovement]) {
        self.savedMovements = movements
    }

    func save(_ movement: VehicleMovement) async throws {
        savedMovements.append(movement)
    }

    func getMovements(vehicleId: UUID) async throws -> [VehicleMovement] {
        savedMovements.filter { $0.vehicleId == vehicleId }
    }
}
