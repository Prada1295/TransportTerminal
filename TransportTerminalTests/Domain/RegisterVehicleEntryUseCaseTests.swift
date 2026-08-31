//
//  RegisterVehicleEntryUseCaseTests.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 22/08/26.
//

import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct RegisterVehicleEntryUseCaseTests {
    @Test func executeWhenVehicleDoesNotExistThrowsVehicleNotFound() async throws {
        let sut = makeSUT()

        await expectTerminalError(.vehicleNotFound) {
            _ = try await sut.execute(vehicleId: UUID())
        }
    }

    @Test func executeWhenCompanyDoesNotExistThrowsCompanyNotFound() async throws {
        let vehicle = makeVehicle(status: .outsideTerminal)
        let sut = makeSUT(vehicles: [vehicle])

        await expectTerminalError(.companyNotFound) {
            _ = try await sut.execute(vehicleId: vehicle.id)
        }
    }

    @Test func executeWhenCompanyIsInactiveThrowsCompanyInactive() async throws {
        let company = makeCompany(isActive: false)
        let vehicle = makeVehicle(companyId: company.id, status: .outsideTerminal)
        let sut = makeSUT(vehicles: [vehicle], companies: [company])

        await expectTerminalError(.companyInactive) {
            _ = try await sut.execute(vehicleId: vehicle.id)
        }
    }

    @Test func executeWhenVehicleIsInMaintenanceThrowsVehicleInMaintenance() async throws {
        let company = makeCompany()
        let vehicle = makeVehicle(companyId: company.id, status: .maintenance)
        let sut = makeSUT(vehicles: [vehicle], companies: [company])

        await expectTerminalError(.vehicleInMaintenance) {
            _ = try await sut.execute(vehicleId: vehicle.id)
        }
    }

    @Test func executeWhenVehicleIsAlreadyInsideThrowsVehicleAlreadyInside() async throws {
        let company = makeCompany()
        let vehicle = makeVehicle(companyId: company.id, status: .insideTerminal)
        let sut = makeSUT(vehicles: [vehicle], companies: [company])

        await expectTerminalError(.vehicleAlreadyInside) {
            _ = try await sut.execute(vehicleId: vehicle.id)
        }
    }

    @Test func executeWhenValidVehicleRegistersEntry() async throws {
        let company = makeCompany()
        let vehicle = makeVehicle(companyId: company.id, status: .outsideTerminal)
        let repositories = makeRepositories(vehicles: [vehicle], companies: [company])
        let sut = makeSUT(
            vehicleRepository: repositories.vehicleRepository,
            companyRepository: repositories.companyRepository,
            movementRepository: repositories.movementRepository
        )

        let result = try await sut.execute(vehicleId: vehicle.id)

        #expect(result.vehicleId == vehicle.id)
        #expect(result.plate == vehicle.plate)
        #expect(repositories.movementRepository.savedMovements.count == 1)
        #expect(repositories.movementRepository.savedMovements.first?.vehicleId == vehicle.id)
        #expect(repositories.movementRepository.savedMovements.first?.type == .entry)
        #expect(repositories.vehicleRepository.updatedVehicles.first?.status == .insideTerminal)
    }
}

private extension RegisterVehicleEntryUseCaseTests {
    func makeSUT(
        vehicles: [Vehicle] = [],
        companies: [Company] = [],
        movements: [VehicleMovement] = []
    ) -> RegisterVehicleEntryUseCase {
        let repositories = makeRepositories(
            vehicles: vehicles,
            companies: companies,
            movements: movements
        )

        return makeSUT(
            vehicleRepository: repositories.vehicleRepository,
            companyRepository: repositories.companyRepository,
            movementRepository: repositories.movementRepository
        )
    }

    func makeSUT(
        vehicleRepository: VehicleRepository,
        companyRepository: CompanyRepository,
        movementRepository: VehicleMovementRepository
    ) -> RegisterVehicleEntryUseCase {
        RegisterVehicleEntry(
            vehicleRepository: vehicleRepository,
            companyRepository: companyRepository,
            movementRepository: movementRepository
        )
    }

    func makeRepositories(
        vehicles: [Vehicle] = [],
        companies: [Company] = [],
        movements: [VehicleMovement] = []
    ) -> (
        vehicleRepository: FakeVehicleRepository,
        companyRepository: FakeCompanyRepository,
        movementRepository: FakeVehicleMovementRepository
    ) {
        (
            vehicleRepository: FakeVehicleRepository(vehicles: vehicles),
            companyRepository: FakeCompanyRepository(companies: companies),
            movementRepository: FakeVehicleMovementRepository(movements: movements)
        )
    }

    func makeCompany(
        id: UUID = UUID(),
        name: String = "Expreso Bolivariano",
        nit: String = "900123456",
        isActive: Bool = true
    ) -> Company {
        Company(
            id: id,
            name: name,
            nit: nit,
            isActive: isActive
        )
    }

    func makeVehicle(
        id: UUID = UUID(),
        plate: String = "ABC123",
        companyId: UUID = UUID(),
        type: VehicleType = .bus,
        capacity: Int = 40,
        status: VehicleStatus = .outsideTerminal
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

private final class FakeVehicleRepository: VehicleRepository {
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

private final class FakeCompanyRepository: CompanyRepository {
    private var companies: [Company]

    init(companies: [Company]) {
        self.companies = companies
    }

    func getById(_ id: UUID) async throws -> Company? {
        companies.first { $0.id == id }
    }

    func getAll() async throws -> [Company] {
        companies
    }

    func save(_ company: Company) async throws {
        companies.append(company)
    }
}

private final class FakeVehicleMovementRepository: VehicleMovementRepository {
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
