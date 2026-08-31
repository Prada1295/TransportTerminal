//
//  GetVehiclesInsideTerminalUseCaseTests.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 24/08/26.
//

import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct GetVehiclesInsideTerminalUseCaseTests {
    @Test func executeWhenRepositoryIsEmptyReturnsEmptyList() async throws {
        let sut = makeSUT()

        let result = try await sut.execute()

        #expect(result.isEmpty)
    }

    @Test func executeWhenNoVehiclesAreInsideTerminalReturnsEmptyList() async throws {
        let vehicles = [
            makeVehicle(plate: "ABC123", status: .outsideTerminal),
            makeVehicle(plate: "DEF456", status: .maintenance),
            makeVehicle(plate: "GHI789", status: .dispatched)
        ]
        let sut = makeSUT(vehicles: vehicles)

        let result = try await sut.execute()

        #expect(result.isEmpty)
    }

    @Test func executeWhenVehiclesAreInsideTerminalReturnsOnlyInsideVehicles() async throws {
        let insideVehicle = makeVehicle(plate: "ABC123", status: .insideTerminal)
        let anotherInsideVehicle = makeVehicle(plate: "JKL012", status: .insideTerminal)
        let outsideVehicle = makeVehicle(plate: "DEF456", status: .outsideTerminal)
        let maintenanceVehicle = makeVehicle(plate: "GHI789", status: .maintenance)
        let sut = makeSUT(
            vehicles: [
                insideVehicle,
                outsideVehicle,
                maintenanceVehicle,
                anotherInsideVehicle
            ]
        )

        let result = try await sut.execute()

        #expect(result == [insideVehicle, anotherInsideVehicle])
    }
}

private extension GetVehiclesInsideTerminalUseCaseTests {
    func makeSUT(vehicles: [Vehicle] = []) -> GetVehiclesInsideTerminalUseCase {
        GetVehiclesInsideTerminal(
            vehicleRepository: FakeInsideTerminalVehicleRepository(vehicles: vehicles)
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

private final class FakeInsideTerminalVehicleRepository: VehicleRepository {
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
