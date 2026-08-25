//
//  InMemoryVehicleRepository.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 25/08/26.
//

import Foundation

public actor InMemoryVehicleRepository: VehicleRepository {
    private var vehicles: [Vehicle]

    public init(vehicles: [Vehicle] = []) {
        self.vehicles = vehicles
    }

    public func getAll() async throws -> [Vehicle] {
        vehicles
    }

    public func getById(_ id: UUID) async throws -> Vehicle? {
        vehicles.first { $0.id == id }
    }

    public func save(_ vehicle: Vehicle) async throws {
        vehicles.append(vehicle)
    }

    public func update(_ vehicle: Vehicle) async throws {
        guard let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) else {
            return
        }

        vehicles[index] = vehicle
    }
}
