//
//  GetVehiclesUseCase.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//
import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct GetVehiclesUseCaseTests {

    @Test
    func executeReturnsAllVehicles() async throws {

        let vehicle1 = makeVehicle(
            plate: "ABC123"
        )

        let vehicle2 = makeVehicle(
            plate: "DEF456"
        )

        let sut = makeSUT(
            vehicles: [
                vehicle1,
                vehicle2
            ]
        )

        let result = try await sut.execute()

        #expect(result.count == 2)
        #expect(result.contains(where: { $0.id == vehicle1.id }))
        #expect(result.contains(where: { $0.id == vehicle2.id }))
    }

    @Test
    func executeWhenThereAreNoVehiclesReturnsEmptyArray() async throws {

        let sut = makeSUT()

        let result = try await sut.execute()

        #expect(result.isEmpty)
    }
}


// MARK: - Helpers

private extension GetVehiclesUseCaseTests {

    func makeSUT(
        vehicles: [Vehicle] = []
    ) -> GetVehiclesUseCase {

        GetVehicles(
            vehicleRepository:
                FakeVehicleRepository(
                    vehicles: vehicles
                )
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
}


// MARK: - Fake Repository

private final class FakeVehicleRepository: VehicleRepository {

    private let vehicles: [Vehicle]

    init(vehicles: [Vehicle]) {
        self.vehicles = vehicles
    }

    func getAll() async throws -> [Vehicle] {
        vehicles
    }

    func getById(_ id: UUID) async throws -> Vehicle? {
        vehicles.first {
            $0.id == id
        }
    }

    func save(_ vehicle: Vehicle) async throws {
        // Not required for these tests.
    }

    func update(_ vehicle: Vehicle) async throws {
        // Not required for these tests.
    }
}
